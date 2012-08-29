package sg.edu.smu.ksketch.operation
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.components.KObjectView;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.interactor.KSelection;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KMovieClip;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.implementations.KActivityOperation;
	import sg.edu.smu.ksketch.operation.implementations.KAddOperation;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KRemoveOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KClipBoard;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public class KObjectEditor
	{	
		private const _GHOST_ALPHA:Number = KObjectView.GHOST_ALPHA;
		private var _stroke:KStroke;
		private var _clipboard:KClipBoard;
		
		public function KObjectEditor()
		{
			_clipboard = new KClipBoard();
		}
		
		public function addMovieClip(model:KModel, movieClip:MovieClip, xPos:Number, yPos:Number, time:Number, centerOffsetX:Number = NaN, centerOffsetY:Number = NaN):IModelOperation
		{
			var kMovieClip:KMovieClip = new KMovieClip(model.nextID, movieClip, xPos, yPos, time);
			if(!isNaN(centerOffsetX) && !isNaN(centerOffsetY))
				kMovieClip.priorityCenter = new Point(xPos+centerOffsetX,yPos+centerOffsetY);
			model.add(kMovieClip);
			return _addObject(kMovieClip,model);
		}
		
		public function addImage(model:KModel,imageData:BitmapData,xPos:Number,yPos:Number,time:Number, centerOffsetX:Number = NaN, centerOffsetY:Number = NaN):IModelOperation
		{
			var image:KImage = new KImage(model.nextID, xPos, yPos, time);
			if (imageData)
				image.imageData = imageData;
			if(!isNaN(centerOffsetX) && !isNaN(centerOffsetY))
				image.priorityCenter = new Point(xPos+centerOffsetX,yPos+centerOffsetY);
			model.add(image);
			return _addObject(image,model);
		}
		
		public function beginStroke(model:KModel,color:uint,thickness:uint,time:Number):int
		{
			_stroke = new KStroke(model.nextID,time);
			_stroke.color = color; 
			_stroke.thickness = thickness;
			model.add(_stroke);
			return _stroke.id;
		}
		
		public function addToStroke(x:Number,y:Number):void
		{
			if (_stroke == null)
				throw new Error("Stroke not initialised");
			_stroke.addPoint(x,y);
		}
		
		public function endStroke(model:KModel):IModelOperation
		{
			if (_stroke == null)
				throw new Error("Stroke not initialised");
			_stroke.endAddingPoint();
			return _addObject(_stroke,model);
		}
		
		private function _addObject(object:KObject,model:KModel):IModelOperation
		{
			object.addParentKey(object.createdTime, model.root);
			object.transformMgr.addInitialKeys(object.createdTime);
			return new KAddOperation(model,object);
		}
		
		public function clearClipBoard():void
		{
			_clipboard.clear();
		}
		
		public function copy(objs:KModelObjectList,time:Number):void
		{
			_clipboard.clear();
			_clipboard.put(objs,time);
		}
		
		public function cut(facade:KModelFacade,objs:KModelObjectList,time:Number):IModelOperation
		{
			if(objs.length() ==0)
				return null;
			
			_clipboard.clear();
			_clipboard.put(objs,time);
			return _removeAll(facade,objs);
		}
		
		public function paste(model:KModel, appState:KAppState, time:Number,  
							  includeMotion:Boolean):IModelOperation
		{
			var objs:KModelObjectList = _clipboard.get(model,time,includeMotion);
			var op:IModelOperation = objs.length()>0 ? _pasteAll(model,objs,time):null;
			appState.selection = op ? new KSelection(objs,time) : appState.selection;
			return op;
		}
		
		public function erase(facade:KModelFacade, model:KModel,
							  object:KObject,kskTime:Number):IModelOperation
		{
			var op:IModelOperation = object.createdTime == kskTime ? 
				_remove(facade,object,kskTime) : _erase(model,object,kskTime);
			var ops:KCompositeOperation = new KCompositeOperation();
			ops.addOperation(op);
			var parent:KGroup = object.getParent(kskTime);
			if (object.createdTime == kskTime && parent != model.root && 
				_noVisibleChild(parent,kskTime))
				ops.addOperation(_remove(facade,parent,kskTime));
			return ops.length > 0 ? ops : null;
		}	
		
		public function toggleVisibility(object:KObject,time:Number):IModelOperation
		{
			var alpha:Number = object.getVisibility(time) == 1 ? 0 : 1;
			object.addActivityKey(time,alpha);
			return new KActivityOperation(object,alpha,time);
			
		}
		
		// Erase obj from the model by adding a GHOST_ALPHA alpha at time,
		// 0 alpha at the next keyframe time, and return the erase operation.
		private function _erase(model:KModel,obj:KObject,time:Number):IModelOperation
		{
			obj.addActivityKey(time,_GHOST_ALPHA);
			obj.addActivityKey(KAppState.nextKey(time),0);
			var ops:KCompositeOperation = new KCompositeOperation();
			ops.addOperation(new KActivityOperation(obj,_GHOST_ALPHA,time));
			ops.addOperation(new KActivityOperation(obj,0,KAppState.nextKey(time)));
			var parent:KGroup = obj.getParent(time);
			if (parent != model.root && _noVisibleChild(parent,time))
			{
				parent.addActivityKey(time,_GHOST_ALPHA);
				ops.addOperation(new KActivityOperation(parent,_GHOST_ALPHA,time));
			}
			return ops;
		}		
		
		private function _removeAll(facade:KModelFacade,objects:KModelObjectList):IModelOperation
		{
			var op:KCompositeOperation = new KCompositeOperation();
			var it:IIterator = objects.iterator;
			while(it.hasNext())
			{
				var obj:KObject = it.next();
				op.addOperation(_remove(facade,obj,obj.createdTime));
			}
			return op.length > 0 ? op : null;
		}		
		
		// Remove the object obj from its parent at time, and return a KRemoveOperation.
		// A EVENT_OBJECT_REMOVED is also dispatched by the facade after the removal.
		private function _remove(facade:KModelFacade,obj:KObject,
								 time:Number):IModelOperation
		{
			obj.getParent(time).remove(obj);
			facade.dispatchEvent(new KObjectEvent(obj,KObjectEvent.EVENT_OBJECT_REMOVED));
			return new KRemoveOperation(facade,obj,time);
		}
		
		private function _pasteAll(model:KModel, objects:KModelObjectList, 
								   time:Number):IModelOperation
		{
			var op:KCompositeOperation = new KCompositeOperation();
			for (var i:int=0; i < objects.length(); i++)
				op.addOperation(_paste(model,model.root,objects.getObjectAt(i),time));
			return op.length > 0 ? op : null;
		}
		
		private function _paste(model:KModel, parent:KGroup, 
								object:KObject, time:Number):IModelOperation
		{
			var op:KCompositeOperation = new KCompositeOperation();
			object.addParentKey(time,parent);
			model.add(object);
			op.addOperation(new KAddOperation(model, object));
			
			if (object is KGroup)
			{
				var it:IIterator = (object as KGroup).directChildIterator(time);
				while (it.hasNext())
					op.addOperation(_paste(model,object as KGroup,it.next(),time));
			}
			return op.length > 0 ? op : null;
		}
		
		// Determine the visibility of parent at time by checking if any 
		// of the child at time has alpha greater that GHOST_ALPHA.
		private function _noVisibleChild(parent:KGroup,time:Number):Boolean
		{
			var it:IIterator = parent.iterator;
			while (it.hasNext())
				if (it.next().getVisibility(time) > _GHOST_ALPHA)
					return false;
			return true;
		}		
	}
}
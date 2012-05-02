/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.operation
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.event.KModelEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.event.KTimeChangedEvent;
	import sg.edu.smu.ksketch.interactor.KSelection;
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.implementations.KActivityOperation;
	import sg.edu.smu.ksketch.operation.implementations.KAddOperation;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KGroupOperation;
	import sg.edu.smu.ksketch.operation.implementations.KInteractionOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	/**
	 * Subclass of KModelFacade with public functions and Event handling implementation.
	 * Sets policies for how each user operation is carried out. 
	 * This class should avoid implementing a mechanism for carrying out operations.
	 */	
	public class KModelFacade implements IEventDispatcher
	{	
		public static const ERASE_SAME:String = "Erase-Same";
		public static const KEEP_THRESHOLD:String = "Keep-Threshold";
		private var _appState:KAppState;
		private var _model:KModel;
		private var _editor:KObjectEditor;
		private var _keyTimeOperator:KKeyTimeOperator;
		
		public function KModelFacade(appState:KAppState)
		{
			_appState = appState;
			_model = new KModel();
			_editor = new KObjectEditor();
			_keyTimeOperator = new KKeyTimeOperator(_appState, _model);
		}
		
		// ------------------ Edit Operation ------------------- //	
		public function addKImage(imageData:BitmapData, time:Number, xPos:Number, yPos:Number):void
		{			
			_appState.addOperation(_editor.addImage(_model,imageData,xPos,yPos,time));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
		}		
		public function beginKStrokePoint():void
		{			
			_editor.beginStroke(_model, _appState.penColor, 
				_appState.penThickness, _appState.time);
		}
		public function addKStrokePoint(x:Number, y:Number):void
		{			
			_editor.addToStroke(x, y);
		}
		public function endKStrokePoint():IModelOperation
		{			
			var op:IModelOperation = _editor.endStroke(_model);
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
			return op;
		}
		public function erase(object:KObject, kskTime:Number):IModelOperation
		{
			return _editor.erase(this,_model,object,kskTime);
		}
		public function copy():void
		{
			if (_appState.selection == null) 
				return;
			_editor.copy(_appState.selection.objects,_appState.time);
			_appState.pasteEnabled = true;
			_appState.fireEditEnabledChangedEvent();
		}
		public function cut():IModelOperation
		{
			var op:IModelOperation = _editor.cut(this,_appState.selection.objects,_appState.time);
			_appState.selection = null;
			_appState.pasteEnabled = true;
			_appState.fireEditEnabledChangedEvent();
			dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
			return op;
		}
		public function paste():IModelOperation
		{
			return _editor.paste(_model, _appState);
		}
		public function clearClipBoard():void
		{
			_editor.clearClipBoard();
			_appState.pasteEnabled = false;
			_appState.fireEditEnabledChangedEvent();
		}
		public function toggleVisibility(objects:KModelObjectList,time:Number):IModelOperation
		{
			var ops:KCompositeOperation = new KCompositeOperation();
			for (var i:int = 0; i < objects.length(); i++)
				ops.addOperation(_editor.toggleVisibility(objects.getObjectAt(i),time));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			return ops.length>0 ? new KInteractionOperation(_appState,time,time,null,null,ops):null;
		}
		
		// ------------------ Grouping Operation ------------------- //
		public function group(objs:KModelObjectList):IModelOperation
		{	
			var time:Number = _appState.time;
			var type:String = _appState.transitionType;
			var mode:String = _appState.groupingMode;
			var interpMode:Boolean = type == KAppState.TRANSITION_INTERPOLATED;
			var staticMode:Boolean = mode == KAppState.GROUPING_EXPLICIT_STATIC;
			var implicitMode:Boolean = mode == KAppState.GROUPING_IMPLICIT_DYNAMIC;
			var centerOffset:Point = _appState.userSetCenterOffset;
			var ops:KCompositeOperation = new KCompositeOperation();
			
			var it:IIterator = objs.iterator;
			while (it.hasNext())
			{
				var rmKeyOp:IModelOperation = KUngroupUtil.removeFutureParentKeys(it.next(),time);
				if (rmKeyOp != null)
					ops.addOperation(rmKeyOp);
			}
			
			var gpOp:IModelOperation = staticMode || (interpMode && implicitMode) ? 
				KGroupUtil.groupStatic(_model,objs):KGroupUtil.groupDynamic(_model,objs,time);
			ops.addOperation(gpOp);
			
			var rmOp:IModelOperation = KUngroupUtil.removeSingletonGroups(_model,_model.root,time);
			if (rmOp != null)
				ops.addOperation(rmOp);
			
			var list:KModelObjectList = new KModelObjectList();
			list.add((gpOp as KGroupOperation).group);
			_appState.selection = new KSelection(list,time);
			
			if(centerOffset)
				_appState.userSetCenterOffset = centerOffset.clone();
			_appState.ungroupEnabled = KUngroupUtil.ungroupEnable(_model.root,_appState);
			_appState.fireGroupingEnabledChangedEvent();
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
			return ops.length > 0 ? ops : null;
		}
		public function ungroup(objs:KModelObjectList):IModelOperation
		{	
			var time:Number = _appState.time;
			var strokes:KModelObjectList = KUngroupUtil.selectedStrokes(_model.root,objs,time);
			var mode:String = _appState.groupingMode;
			var ops:KCompositeOperation = new KCompositeOperation();
			
			var ungpOp:IModelOperation = mode == KAppState.GROUPING_EXPLICIT_STATIC ? 
				KUngroupUtil.ungroupStatic(_model,_model.root,objs):
				KUngroupUtil.ungroupDynamic(_model,_model.root,objs, time);
			if (ungpOp != null)
				ops.addOperation(ungpOp);
			
			var rmOp:IModelOperation = KUngroupUtil.removeSingletonGroups(_model,_model.root,time);
			if (rmOp != null)
				ops.addOperation(rmOp);
			
			_appState.selection = strokes.length()>0 ? new KSelection(strokes,time):_appState.selection;
			_appState.ungroupEnabled = KUngroupUtil.ungroupEnable(_model.root,_appState);
			_appState.fireGroupingEnabledChangedEvent();
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
			return ops.length > 0 ? ops : null;
		}
		
		// ------------------ Transform Operation ------------------- //		
		public function beginTranslation(object:KObject, kskTime:int, transitionType:String):void
		{
			object.transformMgr.beginTranslation(kskTime, transitionType);
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATING));
		}		
		public function addToTranslation(object:KObject, translateX:Number, translateY:Number, 
										 kskTime:Number,cursorPoint:Point = null):void
		{
			object.transformMgr.addToTranslation(translateX,translateY,kskTime,cursorPoint);
			object.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
		public function endTranslation(object:KObject, kskTime:Number):IModelOperation
		{	
			var op:IModelOperation = object.transformMgr.endTranslation(kskTime);
			object.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_TRANSFORM_CHANGED));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
			return op;
		}
		public function beginRotation(object:KObject, canvasCenter:Point, 
									  kskTime:Number, transitionType:String):void
		{
			object.transformMgr.beginRotation(canvasCenter, kskTime, transitionType);
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATING));
		}		
		public function addToRotation(object:KObject, angle:Number, 
									  cursorPoint:Point, kskTime:Number):void
		{
			object.transformMgr.addToRotation(angle, cursorPoint,kskTime);
			object.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
		public function endRotation(object:KObject, kskTime:Number):IModelOperation
		{
			var op:IModelOperation = object.transformMgr.endRotation(kskTime);
			object.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_TRANSFORM_CHANGED));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
			return op;
		}
		public function beginScale(object:KObject, canvasCenter:Point, 
								   kskTime:Number, transitionType:String):void
		{
			object.transformMgr.beginScale(canvasCenter,kskTime, transitionType);
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATING));
		}		
		public function addToScale(object:KObject, scale:Number, 
								   cursorPoint:Point, kskTime:Number):void
		{
			object.transformMgr.addToScale(scale, cursorPoint,kskTime);
			object.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
		public function endScale(object:KObject, kskTime:Number):IModelOperation
		{		
			var op:IModelOperation = object.transformMgr.endScale(kskTime);
			object.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_TRANSFORM_CHANGED));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
			return op;
		}
		
		// ------------------ IEventDispatcher Functions ------------------- //				
		public function addEventListener(type:String, listener:Function,useCapture:Boolean=false,
										 priority:int=0, useWeakReference:Boolean=false):void
		{
			_model.addEventListener(type, listener);
		}
		public function removeEventListener(type:String, listener:Function, 
											useCapture:Boolean=false):void
		{
			_model.removeEventListener(type, listener);
		}		
		public function dispatchEvent(event:Event):Boolean
		{
			return _model.dispatchEvent(event);
		}
		public function hasEventListener(type:String):Boolean
		{
			return _model.hasEventListener(type);
		}
		public function willTrigger(type:String):Boolean
		{
			return _model.willTrigger(type);
		}
		
		// ------------------ File Functions ------------------- //						
		public function newFile():void
		{
			_model.resetModel();
			dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
		}
		public function loadFile(xml:XML):void
		{
			_model.addToModel(xml);
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATE_COMPLETE));
		}
		public function saveFile():XML
		{
			return _model.saveModel();
		}
		
		// -------------- Model Access Functions --------------- //						
		public function get root():KGroup
		{	
			return _model.root;
		}
		public function length():int
		{
			return _model.length();
		}
		public function getObjectByID(id:int):KObject
		{
			return _model.getObjectByID(id);
		}
		public function getObjectByName(name:String):KObject
		{
			return _model.getObjectByName(name);
		}
		public function setObjectName(object:KObject, name:String):void
		{
			_model.setObjectName(object, name);
		}	
		
		// -------------- Time Widget Functions --------------- //						
		public function retimeKeys(keys:Vector.<IKeyFrame>, times:Vector.<Number>, 
								   appTime:Number):IModelOperation
		{
			var op:IModelOperation = _keyTimeOperator.retimeKeys(_appState,_model,keys,times);
			_appState.dispatchEvent(new KTimeChangedEvent(-1, _appState.time));
			return op;
		}
		
		public function getMarkerInfo():Vector.<Object>
		{
			return _keyTimeOperator.getTimeLineInformation();
		}
	}
}
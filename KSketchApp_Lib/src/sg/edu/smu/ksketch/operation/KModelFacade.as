/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.operation
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.event.KModelEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.event.KTimeChangedEvent;
	import sg.edu.smu.ksketch.interactor.KSelection;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.operation.implementations.KGroupOperation;
	import sg.edu.smu.ksketch.operation.implementations.KInteractionOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
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
		
		// Switches the old object root of the model with the new object root of the model //
		public function switchContent(newContent:KModelObjectList):KModelObjectList
		{
			var oldContent:KModelObjectList = _model.switchContent(newContent);
			dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			return oldContent;
		}
		
		// ------------------ Edit Operation ------------------- //	
		public function addKImage(imageData:BitmapData, time:Number, xPos:Number, yPos:Number, centerX:Number = NaN , centerY:Number = NaN ):IModelOperation
		{
			KLogger.logAddKImage(imageData,time,xPos,yPos);
			var op:IModelOperation = _editor.addImage(_model,imageData,xPos,yPos,time,centerX,centerY)
			dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			return op;
		}
		public function  addKMovieClip(movieClip:MovieClip, time:Number, xPos:Number, yPos:Number, centerX:Number = NaN , centerY:Number = NaN ):IModelOperation
		{
			KLogger.logAddKMovieClip(movieClip,time,xPos,yPos);
			var op:IModelOperation = _editor.addMovieClip(_model,movieClip ,xPos,yPos,time,centerX,centerY);
			dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			return op;
		}
		public function beginKStrokePoint(color:uint,thickness:Number,time:Number):int
		{			
			KLogger.logBeginKStrokePoint(color,thickness,time);
			return _editor.beginStroke(_model, color, thickness, time);
		}
		public function addKStrokePoint(x:Number, y:Number):void
		{			
			KLogger.logAddKStrokePoint(new Point(x,y));
			_editor.addToStroke(x, y);
		}
		public function endKStrokePoint():IModelOperation
		{
			KLogger.logEndKStrokePoint();
			var op:IModelOperation = _editor.endStroke(_model);
			dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			return op;
		}
		public function erase(object:KObject, time:Number):IModelOperation
		{
			KLogger.logErase(object.id,time);
			return _editor.erase(this,_model,object,time);
		}
		public function copy(objects:KModelObjectList,time:Number):void
		{
			KLogger.logCopy(objects.toIDs(),time);
			_editor.copy(objects,time);
			_appState.pasteEnabled = true;
			_appState.fireEditEnabledChangedEvent();
		}
		public function cut(objects:KModelObjectList,time:Number):IModelOperation
		{
			KLogger.logCut(objects.toIDs(),time);
			var op:IModelOperation = _editor.cut(this,objects,time);
			_appState.selection = null;
			_appState.pasteEnabled = true;
			_appState.fireEditEnabledChangedEvent();
			dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
			return op;
		}
		public function paste(includeMotion:Boolean,time:Number):IModelOperation
		{
			KLogger.logPaste(includeMotion,time);
			return _editor.paste(_model, _appState, time, includeMotion);
		}
		public function clearClipBoard():void
		{
			KLogger.logClearClipBoard();
			_editor.clearClipBoard();
			_appState.pasteEnabled = false;
			_appState.fireEditEnabledChangedEvent();
		}
		public function toggleVisibility(objects:KModelObjectList,time:Number):IModelOperation
		{
			var ops:KCompositeOperation = new KCompositeOperation();
			for (var i:int = 0; i < objects.length(); i++)
			{
				var obj:KObject = objects.getObjectAt(i);
				ops.addOperation(_editor.toggleVisibility(obj,time));
				dispatchEvent(new KObjectEvent(obj,KObjectEvent.EVENT_VISIBILITY_CHANGED));
			}
			if (ops.length > 0)
			{
				KLogger.logToggleVisibility(objects.toIDs(),time);
				_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
				return new KInteractionOperation(_appState,time,time,null,null,ops);
			}
			return null
		}
		
		public function regroup(objs:KModelObjectList, mode:String, transitionType:int, appTime:Number, 
								isRealTimeTranslation:Boolean = false):IModelOperation
		{
			return null;
		}
		
		public function group(objs:KModelObjectList, mode:String, transitionType:int, groupTime:Number=-2, 
							  isRealTimeTranslation:Boolean = false):IModelOperation
		{	
			var ops:KCompositeOperation = new KCompositeOperation();

			//Do static grouping first
			var groupResult:KObject = KGroupUtil.groupStatic(_model, objs, groupTime, ops);
			
			//Dispatch events to signify changes in hierachy and transforms 
			
			KGroupUtil.removeStaticSingletonGroup(_model.root, _model, ops);
			
			if (ops.length > 0)
			{
				KLogger.logGroup(objs.toIDs(), mode, transitionType, groupTime);
				var list:KModelObjectList = new KModelObjectList();
				
				if(groupResult)
				{
					list.add(groupResult);	
					_appState.selection = new KSelection(list,_appState.time);

					if(_appState.userSetCenterOffset)
						_appState.userSetCenterOffset = _appState.userSetCenterOffset.clone();
				}
				
				_appState.ungroupEnabled = KGroupUtil.ungroupEnable(_model.root,_appState);
				_appState.fireGroupingEnabledChangedEvent();
				dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
				return ops;
			}
			return null;
		}
		public function ungroup(objs:KModelObjectList,mode:String,appTime:Number):IModelOperation
		{	
			return null;
		}
		
		// ------------------ Transform Operation ------------------- //		
		public function beginTranslation(object:KObject, time:Number, transitionType:int):void
		{
			KLogger.logBeginTranslation(object.id, time, transitionType);
			object.transformMgr.beginTranslation(time, transitionType);
		}		
		public function addToTranslation(object:KObject, translateX:Number, translateY:Number,
										 time:Number, cursorPoint:Point = null):void
		{
			KLogger.logAddToTranslation(translateX, translateY,time, cursorPoint);
			object.transformMgr.addToTranslation(translateX,translateY, time, cursorPoint);
			_dispatchObjectTransformChanged(object);
		}
		public function endTranslation(object:KObject, time:Number):IModelOperation
		{	
			KLogger.logEndTranslation(time);
			var op:IModelOperation = object.transformMgr.endTranslation(time);
			_dispatchObjectChangeAndModelUpdateEvent(object);
			return op;
		}
		public function beginRotation(object:KObject, canvasCenter:Point, 
									  time:Number, transitionType:int):void
		{
			KLogger.logBeginRotation(object.id, canvasCenter, time, transitionType);
			object.transformMgr.beginRotation(canvasCenter, time, transitionType);
		}		
		public function addToRotation(object:KObject, angle:Number, 
									  cursorPoint:Point, time:Number):void
		{
			KLogger.logAddToRotation(angle, cursorPoint, time);
			object.transformMgr.addToRotation(angle, cursorPoint, time);
			_dispatchObjectTransformChanged(object);
		}
		public function endRotation(object:KObject, time:Number):IModelOperation
		{
			KLogger.logEndRotation(time);
			var op:IModelOperation = object.transformMgr.endRotation(time);
			_dispatchObjectChangeAndModelUpdateEvent(object);
			return op;
		}
		public function beginScale(object:KObject, canvasCenter:Point, 
								   time:Number, transitionType:int):void
		{
			KLogger.logBeginScale(object.id, canvasCenter, time, transitionType);
			object.transformMgr.beginScale(canvasCenter, time, transitionType);
		}		
		public function addToScale(object:KObject, scale:Number, 
								   cursorPoint:Point, time:Number):void
		{
			KLogger.logAddToScale(scale, cursorPoint, time);
			object.transformMgr.addToScale(scale, cursorPoint, time);
			_dispatchObjectTransformChanged(object);
		}
		public function endScale(object:KObject, time:Number):IModelOperation
		{
			KLogger.logEndScale(time);
			var op:IModelOperation = object.transformMgr.endScale(time);
			_dispatchObjectChangeAndModelUpdateEvent(object);
			return op;
		}
		public function insertKeyFrames(objects:IModelObjectList):IModelOperation
		{
			if(!objects)
			{
				if(_appState.targetTrackBox != KTransformMgr.ALL_REF)
					return null;
				
				objects = _model.allChildren();
				
				var allIt:IIterator = objects.iterator;
				var currentObj:KObject;
				
				while(allIt.hasNext())
				{
					currentObj = allIt.next();
					
					if(currentObj.getVisibility(_appState.trackTapTime) <= 0)
						objects.remove(currentObj);
				}
			}
			if(objects && objects.length()>0)
			{
				KLogger.logInsertKeyFrames(objects.toIDs());
				_appState.time = _appState.trackTapTime;
				var it:IIterator = objects.iterator;
				var insertKeyOp:KCompositeOperation = new KCompositeOperation();
				while(it.hasNext())
					insertKeyOp.addOperation(it.next().insertBlankKey(
						_appState.targetTrackBox,_appState.time));
				
				dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
				return insertKeyOp;
			}			
			return null;
		}
		public function clearMotions(objects:IModelObjectList):IModelOperation
		{
			var clearMotionsOp:KCompositeOperation = new KCompositeOperation();
			if(objects && objects.length() > 0)
			{
				var it:IIterator = objects.iterator;
				while(it.hasNext())
				{
					var object:KObject = it.next();
					var clearKeyOp:IModelOperation = object.transformMgr.clearTransforms();
					if(clearKeyOp)
					{
						clearMotionsOp.addOperation(clearKeyOp);
						_dispatchObjectTransformChanged(object);
					}
				}
			}
			if (clearMotionsOp.length > 0)
			{
				KLogger.logClearMotions(objects.toIDs());
				return clearMotionsOp;
			}
			return null;
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
		}
		public function loadFile(xml:XML):void
		{
			_model.addToModel(xml);
			_model.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
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
			KLogger.logSetObjectName(object.id,name);
			_model.setObjectName(object, name);
		}
		
		// -------------- Time Widget Functions --------------- //						
		public function retimeKeys(keys:Vector.<IKeyFrame>, times:Vector.<Number>, 
								   appTime:Number):IModelOperation
		{
			// !! Logging is currently done outside of facade as there is some operation issue !! //
			var op:IModelOperation = _keyTimeOperator.retimeKeys(_appState,_model,keys,times);
			_appState.dispatchEvent(new KTimeChangedEvent(-1, _appState.time));
			return op;
		}
		public function getMarkerInfo():Vector.<Object>
		{
			return _keyTimeOperator.getTimeLineInformation();
		}
		
		private function _dispatchObjectChangeAndModelUpdateEvent(object:KObject):void
		{
			object.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_TRANSFORM_CHANGED));
			dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
		}
		private function _dispatchObjectTransformChanged(object:KObject):void
		{
			object.dispatchEvent(new KObjectEvent(object, KObjectEvent.EVENT_TRANSFORM_CHANGED));
		}
	}
}
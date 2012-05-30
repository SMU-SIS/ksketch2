/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model
{
	import flash.display.Shape;
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.implementations.KActivityKeyFrame;
	import sg.edu.smu.ksketch.model.implementations.KKeyFrame;
	import sg.edu.smu.ksketch.model.implementations.KKeyFrameList;
	import sg.edu.smu.ksketch.model.implementations.KParentKeyFrameList;
	import sg.edu.smu.ksketch.model.implementations.KParentKeyframe;
	import sg.edu.smu.ksketch.model.implementations.KReferenceFrame;
	import sg.edu.smu.ksketch.model.implementations.KReferenceFrameList;
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KGroupUtil;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.utilities.ErrorMessage;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KObject extends EventDispatcher 
	{
		private const TRANSLATION_REFERENCE_NUMBER:int = KTransformMgr.TRANSLATION_REF;
		private const ROTATION_REFERENCE_NUMBER:int = KTransformMgr.ROTATION_REF;
		private const SCALE_REFERENCE_NUMBER:int = KTransformMgr.SCALE_REF;
		private var _id:int;
		private var _name:String;
		private var _defaultBoundingBox:Rectangle;
		private var _parentFrameList:IParentKeyFrameList;
		private var _activityFrameList:KKeyFrameList;
		private var _referenceFrameList:KReferenceFrameList;
		private var _transformMgr:KTransformMgr;
		private var _positionMatrix:Matrix;
		
		public function KObject(id:int,createdTime:Number=0)
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch.model::KObject")
				throw new IllegalOperationError(ErrorMessage.ABSTRACT_CLASS_INSTANTIATED);
			_id = id;
			_defaultBoundingBox = new Rectangle();
			_referenceFrameList = new KReferenceFrameList();
			_referenceFrameList.insert(TRANSLATION_REFERENCE_NUMBER);
			_referenceFrameList.insert(ROTATION_REFERENCE_NUMBER);
			_referenceFrameList.insert(SCALE_REFERENCE_NUMBER);
			_parentFrameList = new KParentKeyFrameList();
			(_parentFrameList as KParentKeyFrameList).debugID = id;
			_activityFrameList = new KKeyFrameList();
			_transformMgr = new KTransformMgr(this,_referenceFrameList);
			_positionMatrix = new Matrix();
			addActivityKey(createdTime,1);
		}
		
		public function get transformMgr():KTransformMgr
		{
			return _transformMgr;
		}
			
		public function get id():int
		{
			return _id;
		}
			
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get createdTime():Number
		{
			if(isNaN(_activityFrameList.earliestTime()))
				return 0;
			else
				return _activityFrameList.earliestTime();
		}
		
		public function handleCenter(kskTime:Number):Point
		{
			var refFrame:KReferenceFrame = _referenceFrameList.getReferenceFrameAt(
				KTransformMgr.ROTATION_REF) as KReferenceFrame; 
			
			var rotationKey:ISpatialKeyframe = refFrame.getAtOrAfter(kskTime) as ISpatialKeyframe;
			
			if(!rotationKey)
				rotationKey = refFrame.getAtOrBeforeTime(kskTime) as ISpatialKeyframe;
			
			if(rotationKey)
				return rotationKey.center.clone();
			
			return defaultCenter;
		}

		public function transformChanged(from:int, to:int):Matrix
		{
			if(from == to)
				return null;
			
			var fromMatrix:Matrix = getFullMatrix(from);
			var toMatrix:Matrix = getFullMatrix(to);
			if(fromMatrix.tx != toMatrix.tx || fromMatrix.ty != toMatrix.ty
				|| fromMatrix.a != toMatrix.a || fromMatrix.b != toMatrix.b
				|| fromMatrix.c != toMatrix.c || fromMatrix.d != toMatrix.d)
			{
				return toMatrix;
			}
			
			return null;
		}
		
		public function getFullPathMatrix(time:Number):Matrix
		{
			var parentKey:IParentKeyFrame = _parentFrameList.getAtOrBeforeTime(time) as IParentKeyFrame;
			
			if(parentKey)
			{
				var result:Matrix = new Matrix();
				result.concat(getFullMatrix(time));
				result.concat(parentKey.parent.getFullPathMatrix(time));
				return result;
			}
			else
			{
				return getFullMatrix(time);
			}
		}
		
		public function getPositionMatrix(time:Number):Matrix
		{
			var parentKey:IParentKeyFrame = _parentFrameList.getAtOrBeforeTime(time) as IParentKeyFrame;
			
			if(parentKey)
				return parentKey.positionMatrix;
			else
				return new Matrix();
		}
				
		public function getFullMatrix(kskTime:Number):Matrix
		{
			var result:Matrix = getPositionMatrix(kskTime);
			result.concat(_referenceFrameList.getMatrix(kskTime));
			return result;
		}
						
		public function get defaultCenter():Point
		{
			return null;
		}
		
		public function getBoundingRect(kskTime:Number = 0):Rectangle
		{
			return null;
		}
		
		public function get defaultBoundingBox():Rectangle
		{
			return _defaultBoundingBox;
		}
		
		public function set defaultBoundingBox(boundingBox:Rectangle):void
		{
			_defaultBoundingBox = boundingBox;
		}

		public function addActivityKey(time:Number, alpha:Number):IActivityKeyFrame
		{
			var key:KActivityKeyFrame = _activityFrameList.lookUp(time) as KActivityKeyFrame;
			
			if(key != null && key.endTime == time)
				key.alpha = alpha;
			else
			{
				key = _activityFrameList.createActivityKey(time,alpha) as KActivityKeyFrame;
				key.endTime = time;
				_activityFrameList.insertKey(key);
			}
			this.dispatchEvent(new KObjectEvent(this, KObjectEvent.EVENT_VISIBILITY_CHANGED));
			return key;
		}
				
		public function removeActivityKey(time:Number):IKeyFrame
		{
			var key:KKeyFrame = _activityFrameList.lookUp(time) as KKeyFrame;
			if (key != null)
				_activityFrameList.remove(key);
			return key;	
		}					

		public function visibilityChanged(from:Number, to:Number):Number
		{
			var fromAlpha:Number = getVisibility(from);
			var toAlpha:Number = getVisibility(to);
			if(fromAlpha != toAlpha)
				return toAlpha;
			else
				return -1;
		}
		
		public function getVisibility(time:Number):Number
		{
			var key:KActivityKeyFrame = _activityFrameList.getAtOrBeforeTime(time) as KActivityKeyFrame;
			var minimumVisibleTime:Number = createdTime - 1;
			return key != null && time >= minimumVisibleTime ? key.alpha : 0;
		}
		
		public function getActivityKeys():Vector.<IKeyFrame>
		{
			return _getAllKeys(_activityFrameList);
		}
		
		public function getActivityKey(time:Number):IKeyFrame
		{
			return _activityFrameList.getAtTime(time);
		}
		
		public function getActivityKeyBeforeAt(time:Number):IKeyFrame
		{
			return _activityFrameList.getAtOrBeforeTime(time);
		}
		
		public function addParentKey(time:Number, parent:KGroup):IParentKeyFrame
		{
			var key:KParentKeyframe = _parentFrameList.lookUp(time) as KParentKeyframe;
			if(key != null && key.endTime == time)
				key.endTime = key.endTime - KAppState.ANIMATION_INTERVAL;
			key = _parentFrameList.createParentKey(time,parent) as KParentKeyframe;
			key.debugID = id;
			key.endTime = time;
			_parentFrameList.insertKey(key);
			this.dispatchEvent(new KObjectEvent(this, KObjectEvent.EVENT_PARENT_CHANGED));
			return key;
		}

		public function removeParentKey(time:Number):IKeyFrame
		{
			var key:KKeyFrame = _parentFrameList.lookUp(time) as KKeyFrame;
			if (key != null)
				_parentFrameList.remove(key);
			return key;	
		}
		
		public function parentChanged(from:Number, to:Number):KGroup
		{
			var fromParent:KGroup = getParent(from);
			var toParent:KGroup = getParent(to);
			if(fromParent.id != toParent.id)
			{
				return toParent;
			}
			return null;
		}
		
		public function getParent(time:Number):KGroup
		{
			var key:KParentKeyframe = _parentFrameList.lookUp(time) as KParentKeyframe;
			
			if(key != null)
				return key.getParent(time);
			else
				return null;
		}
		
		public function getParentKeys():Vector.<IKeyFrame>
		{
			return _getAllKeys(_parentFrameList as KKeyFrameList);
		}
		
		public function getParentKey(time:Number):IKeyFrame
		{
			return _parentFrameList.getAtTime(time);
		}
		
		public function getParentKeyAtOrBefore(time:Number):KParentKeyframe
		{
			return _parentFrameList.getAtOrBeforeTime(time) as KParentKeyframe;
		}
		
		public function getParentKeyAtOrAfter(time:Number):KParentKeyframe
		{
			return _parentFrameList.getAtOrAfter(time) as KParentKeyframe;
		}
		
		public function hasParent(parent:KGroup):Boolean
		{
			var key:KParentKeyframe = _parentFrameList.lookUp(createdTime) as KParentKeyframe;
			while(key != null)
			{
				if(key.parent == parent)
					return true;
				key = key.next as KParentKeyframe;
			}
			return false;
		}

		public function getSpatialKeyAt(time:Number, type:int):ISpatialKeyframe
		{
			return _getAtTime(time, type);			
		}
		
		
		public function getSpatialKeyAtOfAfter(time:Number, type:int):ISpatialKeyframe
		{
			var refFrame:KReferenceFrame = _referenceFrameList.getReferenceFrameAt(
				type) as KReferenceFrame; 
			return refFrame.getAtOrAfter(time) as ISpatialKeyframe;
		}
		
		public function getSpatialKeys(type:int):Vector.<IKeyFrame>
		{
			return _getAllKeys(_referenceFrameList.getReferenceFrameAt(type) as KKeyFrameList);
		}
		
		public function getSpatialKey(time:Number, type:int):ISpatialKeyframe
		{
			return _lookUp(time, type);			
		}
		
		public function removeSpatialKey(time:Number, type:int):KKeyFrame
		{
			var key:KKeyFrame = _lookUp(time,type);
			var refFrame:KReferenceFrame = _referenceFrameList.getReferenceFrameAt(
				type) as KReferenceFrame; 
			if (key != null)
				refFrame.remove(key);
			return key;
		}
		
		public function shiftTransformKeys(dt:Number):void
		{
			_referenceFrameList.getReferenceFrameAt(TRANSLATION_REFERENCE_NUMBER).shiftKeys(0,dt);
			_referenceFrameList.getReferenceFrameAt(ROTATION_REFERENCE_NUMBER).shiftKeys(0,dt);
			_referenceFrameList.getReferenceFrameAt(SCALE_REFERENCE_NUMBER).shiftKeys(0,dt);
		}

		public function shiftActivityKeys(dt:Number):void
		{
			_activityFrameList.shiftKeys(0,dt);
		}
		
		public function shiftParentKeys(dt:Number):void
		{
			_parentFrameList.shiftKeys(0,dt);
		}
		
		private function _getAtTime(time:Number, type:int):KSpatialKeyFrame
		{
			var refFrame:KReferenceFrame = _referenceFrameList.getReferenceFrameAt(
				type) as KReferenceFrame; 
			return refFrame.getAtTime(time) as KSpatialKeyFrame;
		}
		
		private function _lookUp(time:Number, type:int):KSpatialKeyFrame
		{
			var refFrame:KReferenceFrame = _referenceFrameList.getReferenceFrameAt(
				type) as KReferenceFrame; 
			return refFrame.lookUp(time) as KSpatialKeyFrame;
		}
		
		private function _getAllKeys(list:KKeyFrameList):Vector.<IKeyFrame>
		{
			var keys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			var key:IKeyFrame = list.getAtOrAfter(0);
			while (key != null)
			{
				keys.push(key);
				key = key.next;
			}
			return keys;
		}
		
		public function insertBlankKey(type:int, time:Number):IModelOperation
		{
			var operation:KCompositeOperation = new KCompositeOperation();
			var refFrame:IReferenceFrame;
			
			if(type == KTransformMgr.ALL_REF)
			{
				refFrame = _referenceFrameList.getReferenceFrameAt(TRANSLATION_REFERENCE_NUMBER);
				_transformMgr.forceKeyAtTime(time, refFrame, operation);
				refFrame = _referenceFrameList.getReferenceFrameAt(ROTATION_REFERENCE_NUMBER);
				_transformMgr.forceKeyAtTime(time, refFrame, operation);
				refFrame = _referenceFrameList.getReferenceFrameAt(SCALE_REFERENCE_NUMBER);
				_transformMgr.forceKeyAtTime(time, refFrame, operation);
			}
			else
			{
				refFrame = _referenceFrameList.getReferenceFrameAt(type);
				_transformMgr.forceKeyAtTime(time, refFrame, operation);
			}

			return operation;
		}
	}
}
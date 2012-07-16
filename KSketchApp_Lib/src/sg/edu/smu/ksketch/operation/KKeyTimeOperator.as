/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.operation
{
	import sg.edu.smu.ksketch.interactor.KSelection;
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.IKeyFrameList;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.implementations.KReferenceFrame;
	import sg.edu.smu.ksketch.operation.implementations.KRetimeKeyFrameOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public class KKeyTimeOperator
	{
		public static const TRANSLATE_KEY:int = KTransformMgr.TRANSLATION_REF;
		public static const ROTATE_KEY:int = KTransformMgr.ROTATION_REF;
		public static const SCALE_KEY:int = KTransformMgr.SCALE_REF;
		public static const ACTIVITY_KEY:int = 3;
		public static const PARENT_KEY:int = 4;
		
		private var _appState:KAppState;
		private var _model:KModel;
		
		public function KKeyTimeOperator(appState:KAppState, model:KModel):void
		{
			_appState = appState;
			_model = model;
		}
		
		/**
		 * Returns a vector of objects containing time and the keys(and their information) that can be
		 * found at those times. A returned time may have more than one keys associated with it. 
		 * 
		 * The object will have these properties
		 * +time:Number
		 * +keyInfo:Object
		 * 		+key:KKeyFrame
		 * 		+type:int
		 * 		+selected:boolean
		 * 
		 * Keys that are within within mergeTime of each other will be grouped with the keys at the earlier time.
		 */
		public function getTimeLineInformation():Vector.<Object>
		{
			var mergeThreshold:Number = KAppState.ANIMATION_INTERVAL*0.2;
			
			var frameHeaderInfo:Vector.<Object> = _getKeyFrameHeaderInformation();
			var sortedFrameInfo:Vector.<Object> = _getSortedKeyFrameInfo(frameHeaderInfo);
			var clusteredFrameInfo:Vector.<Object> = clusterKeyFrameTime(sortedFrameInfo, mergeThreshold);
			
			return clusteredFrameInfo;
		}
		
		public function retimeKeys(appState:KAppState,model:KModel, keys:Vector.<IKeyFrame>, 
								   times:Vector.<Number>):IModelOperation
		{
			var oldTimes:Vector.<Number> = new Vector.<Number>();
			for(var i:int = 0; i< keys.length; i++)
			{
				//if there are keys that do not exist, then create new key at that time. add the new keys after this loop.
				oldTimes.push(keys[i].endTime);
				keys[i].retimeKeyframe(times[i]);
			}
			return new KRetimeKeyFrameOperation(appState,model,keys,oldTimes,times);
		}
		
		/**
		 * Retrieves the header key frames for translate scale rotate and activity key frame lists
		 * for all objects in the model
		 */
		private function _getKeyFrameHeaderInformation():Vector.<Object>
		{
			//Create an iterator that will go through all objects in the model
			var allModelObjects:IModelObjectList = _model.allChildren();
			var it:IIterator = allModelObjects.iterator;
			
			var keyFrameInfoVector:Vector.<Object> = new Vector.<Object>();
			var currentObject:KObject;
			var keyFrameInfo:Object;
			var selected:Boolean;
			
			var translateKeys:IKeyFrame;
			var rotateKeys:IKeyFrame;
			var scaleKeys:IKeyFrame;
			var activityKeys:IKeyFrame;
			
			//Iterate through all model objects
			while(it.hasNext())
			{
				currentObject = it.next();
				if(_appState.selection)
					selected = _appState.selection.contains(currentObject);
				else
					selected = false;
					
				//Find their key headers
				var createdTime:Number = currentObject.createdTime;
				translateKeys = currentObject.getSpatialKeyAtOfAfter(createdTime,KTransformMgr.TRANSLATION_REF);
				rotateKeys = currentObject.getSpatialKeyAtOfAfter(createdTime,KTransformMgr.ROTATION_REF);
				scaleKeys = currentObject.getSpatialKeyAtOfAfter(createdTime,KTransformMgr.SCALE_REF);
				activityKeys = currentObject.getActivityKey(createdTime);
				
				//Create key frame information OBJECTS using these key and available information.
				keyFrameInfo = new Object();
				keyFrameInfo.objectID = currentObject.id;
				keyFrameInfo.key = translateKeys;
				keyFrameInfo.selected = selected;
				keyFrameInfo.type = TRANSLATE_KEY;
				keyFrameInfo.hasTransform = (translateKeys as ISpatialKeyframe).hasTransform();
				keyFrameInfoVector.push(keyFrameInfo);
				
				keyFrameInfo = new Object();
				keyFrameInfo.objectID = currentObject.id;
				keyFrameInfo.key = rotateKeys;
				keyFrameInfo.selected = selected;
				keyFrameInfo.type = ROTATE_KEY;
				keyFrameInfo.hasTransform = (rotateKeys as ISpatialKeyframe).hasTransform();
				keyFrameInfoVector.push(keyFrameInfo);
				
				keyFrameInfo = new Object();
				keyFrameInfo.objectID = currentObject.id;
				keyFrameInfo.key = scaleKeys;
				keyFrameInfo.selected = selected;
				keyFrameInfo.type = SCALE_KEY;
				keyFrameInfo.hasTransform = (scaleKeys as ISpatialKeyframe).hasTransform();
				keyFrameInfoVector.push(keyFrameInfo);
				
				keyFrameInfo = new Object();
				keyFrameInfo.objectID = currentObject.id;
				keyFrameInfo.key = activityKeys;
				keyFrameInfo.selected = selected;
				keyFrameInfo.type = ACTIVITY_KEY;
				keyFrameInfo.hasTransform = false;
				keyFrameInfoVector.push(keyFrameInfo);
			}
			
			return keyFrameInfoVector;
		}
		
		
		/**
		 * Generates a sorted vector of key frame information objects
		 */
		private function _getSortedKeyFrameInfo(headerInfos:Vector.<Object>):Vector.<Object>
		{
			var i:int;
			var sortedInfoVector:Vector.<Object> = new Vector.<Object>();
			var minimumTimeObject:Object;
			var newKeyInfoObject:Object;
			var currentObject:Object
			var minimumTimeIndex:int;
			
			while(headerInfos.length != 0)
			{
				for(i=0; i<headerInfos.length; i++)
				{
					currentObject = headerInfos[i];
					
					if(!minimumTimeObject || currentObject.key.endTime < minimumTimeObject.key.endTime)
					{
						minimumTimeIndex = i;
						minimumTimeObject = currentObject;
					}
				}
				
				currentObject = headerInfos[minimumTimeIndex];
				sortedInfoVector.push(currentObject);
				
				if(currentObject.key.next)
				{
					newKeyInfoObject = new Object();
					newKeyInfoObject.objectID = currentObject.objectID;
					newKeyInfoObject.key = currentObject.key.next;
					newKeyInfoObject.time = newKeyInfoObject.key.endTime;
					newKeyInfoObject.selected = currentObject.selected;
					newKeyInfoObject.type = currentObject.type;
					
					if(newKeyInfoObject.key is ISpatialKeyframe)
						newKeyInfoObject.hasTransform = 
							(newKeyInfoObject.key as ISpatialKeyframe).hasTransform();
					else
						newKeyInfoObject.hasTransform = false;
					
					headerInfos[minimumTimeIndex] = newKeyInfoObject;
				}
				else
					headerInfos.splice(minimumTimeIndex,1);
				
				minimumTimeObject = null;
			}
			
			return sortedInfoVector;
		}
		
		/**
		 * Clusters key frame information objects of similar time together
		 */
		private function clusterKeyFrameTime(sortedKeyInfo:Vector.<Object>, 
											 mergeThreshold:Number = 0):Vector.<Object>
		{
			var clusteredFrameInfo:Vector.<Object> = new Vector.<Object>();
			var currentCluster:Object;
			var currentSelectedCluster:Object;
			var currentFrameInfo:Object;
			var clusterTime:Number;
			var i:int;
			
			while(sortedKeyInfo.length !=0)
			{
				clusterTime = sortedKeyInfo[0].key.endTime;

				currentCluster = new Object();
				currentCluster.keyList = new Vector.<Object>();
				currentCluster.selected = false;
				currentCluster.hasTransform = false;
				currentCluster.time = clusterTime;
				
				currentSelectedCluster = new Object();
				currentSelectedCluster.keyList = new Vector.<Object>();
				currentSelectedCluster.selected = true;
				currentCluster.hasTransform = false;
				currentSelectedCluster.time = clusterTime;
				
				for(i = 0; i < sortedKeyInfo.length; i++) 
				{
					currentFrameInfo = sortedKeyInfo[i];
					
					if(currentFrameInfo.key.endTime - clusterTime <= mergeThreshold)
					{
						if(currentFrameInfo.selected)
						{
							currentSelectedCluster.keyList.push(currentFrameInfo);
							if(currentFrameInfo.hasTransform)
								currentSelectedCluster.hasTransform = true;
						}
						else
						{
							currentCluster.keyList.push(currentFrameInfo);
							if(currentFrameInfo.hasTransform)
								currentSelectedCluster.hasTransform = true;
						}

						sortedKeyInfo.splice(i,1);
						i-=1;
					}
					else
						i=sortedKeyInfo.length;
				}
				if(currentCluster.keyList.length != 0)
					clusteredFrameInfo.push(currentCluster);
				if(currentSelectedCluster.keyList.length != 0)
					clusteredFrameInfo.push(currentSelectedCluster);	
			}
			
			return clusteredFrameInfo;
		}
	}
}
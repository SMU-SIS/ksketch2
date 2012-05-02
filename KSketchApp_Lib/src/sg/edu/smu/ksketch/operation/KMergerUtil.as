/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.operation
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.model.geom.KTranslation;
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;

	public class KMergerUtil
	{
		/**
		 * Merge the keys from source to target of the type at the specific time.
		 */
		public static function mergeKeys(target:KObject,source:KObject,time:Number, 
										 ops:KCompositeOperation, type:int):void
		{
			var center:Point = target.defaultCenter;
			var targetKeys:Vector.<IKeyFrame> = target.getSpatialKeys(type);
			var sourceKeys:Vector.<IKeyFrame> = _cloneKeys(source.getSpatialKeys(type));
			_splitKeys(targetKeys,time,ops);
			_splitKeys(sourceKeys,time,new KCompositeOperation());
			for (var i:int=0; i < targetKeys.length; i++)
				_splitKeys(sourceKeys,targetKeys[i].endTime,new KCompositeOperation());
			for (var j:int=0; j < sourceKeys.length; j++)
			{
				var sourceKey:ISpatialKeyframe = sourceKeys[j] as ISpatialKeyframe;
				var sourceTime:Number = sourceKey.endTime;
				if (sourceTime < time) 
					continue;			
				_splitKeys(targetKeys,sourceTime,ops);
				if (target.getSpatialKeyAt(sourceTime,type) == null)
					target.transformMgr.addKeyFrame(type,sourceTime,center.x,center.y,ops);
				var targetKey:ISpatialKeyframe = target.getSpatialKeyAt(sourceTime,type);
				var op:IModelOperation = targetKey.mergeKey(sourceKey, type);
				if (op != null)
					ops.addOperation(op);
			}
		}

		/**
		 * Add interpolated translation to the object fromPoint toPoint, fromTime toTime.
		 */
		public static function addInterpolatedTranslation(object:KObject,fromPoint:Point,
														  toPoint:Point,fromTime:Number,
														  toTime:Number):IModelOperation
		{
			const translateRef:int = KTransformMgr.TRANSLATION_REF;			
			var ops:KCompositeOperation = new KCompositeOperation();
			var center:Point = object.defaultCenter;
			var toKeys:Vector.<IKeyFrame> = object.getSpatialKeys(translateRef);			
			var fmKeys:Vector.<IKeyFrame> = new Vector.<IKeyFrame>();
			var key:ISpatialKeyframe = new KSpatialKeyFrame(toTime,center);
			key.translate = _getInterpolatedTranslation(fromPoint,toPoint,toTime-fromTime);
			fmKeys.push(key);
			for (var i:int = 0; i < toKeys.length; i++)
				_splitKeys(fmKeys,toKeys[i].endTime,new KCompositeOperation());
			for (var j:int = 0; j < fmKeys.length; j++)
			{
				var endTime:Number = fmKeys[j].endTime;
				key = object.getSpatialKey(endTime,translateRef);
				if (endTime < key.endTime)
					key.splitKey(endTime,ops,center);
				else if (endTime > key.endTime)
					object.transformMgr.addKeyFrame(
						translateRef,endTime,center.x,center.y,ops);
				key = object.getSpatialKeyAt(endTime,translateRef);
				var op:IModelOperation = key.mergeKey(fmKeys[j] as ISpatialKeyframe,translateRef);
				if (op != null)
					ops.addOperation(op);
			}
			return ops.length > 0 ? ops : null;
		}
		
		// Split the key in keys, where key.startTime() < time < key.endTime. 
		private static function _splitKeys(keys:Vector.<IKeyFrame>,time:Number, 
										   ops:KCompositeOperation):void
		{
			for (var i:int=0; i < keys.length; i++)
			{
				if (keys[i].startTime() < time && time < keys[i].endTime)
				{
					var key:ISpatialKeyframe = keys[i] as ISpatialKeyframe; 
					var key01:Vector.<IKeyFrame> = key.splitKey(time,ops,key.center);
					keys.splice(i,1,key01[0],key01[1]);
					return;
				}
			}
		}
		
		// Clone all entries of keys and return the cloned keys as a new Vector.
		private static function _cloneKeys(keys:Vector.<IKeyFrame>):Vector.<IKeyFrame>
		{
			var clones:Vector.<IKeyFrame> = new Vector.<IKeyFrame>;
			for (var i:int=0; i < keys.length; i++)
				clones.push(keys[i].clone());
			return clones;
		}
		
		// Obtain the translation from fromPoint to toPoint, interpolated across duration.
		private static function _getInterpolatedTranslation(fromPoint:Point,toPoint:Point,
															duration:Number):KTranslation
		{
			const translateRef:int = KTransformMgr.TRANSLATION_REF;			
			var offset:Point = toPoint.subtract(fromPoint);
			var result:KTranslation = new KTranslation();
			for (var i:int=0; i <= duration; i++)
			{
				var xi:Number = i*offset.x/duration;
				var yi:Number = i*offset.y/duration;
				var point:Point = new Point(fromPoint.x+xi,fromPoint.y+yi);
				result.path.addPoint(xi,yi,i);
				result.transitionPath.push(xi,yi,i);
			}
			return result;
		}
		
	}
}
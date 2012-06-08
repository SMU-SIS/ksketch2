/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.utilities
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.IActivityKeyFrame;
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.KMergerUtil;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	
	import spark.components.IItemRenderer;
		
	public class KClipBoard
	{	
		public static const OFFSET_INCREMENT:int = 20;
		private var _template_objects:KModelObjectList;
		private var _offset:int = 0;
		private var _copyTime:Number = 0;

		public function KClipBoard()
		{
			_template_objects = new KModelObjectList();
		}
		
		public function clear():void
		{
			_template_objects = new KModelObjectList();
		}
		
		public function put(objects:KModelObjectList, time:Number):void
		{
			_offset = 0;
			_copyTime = time;
			_template_objects = _copyObjects(null,objects,time,true);
		}
		
		public function get(model:KModel, time:Number, 
							includeMotion:Boolean):KModelObjectList
		{
			_offset+=OFFSET_INCREMENT;
			return _copyObjects(model,_template_objects, time, includeMotion);
		}
		
		// Return a clone of the objects at time. 
		// If model is null, it will store the object together with the motion from 
		// time of copy to the local template, else it will return a clone from the 
		// template (includeMotion will determine if keyframe is included).
		private function _copyObjects(model:KModel,objects:KModelObjectList,
									  time:Number, includeMotion:Boolean):KModelObjectList
		{
			var cloned:KModelObjectList = new KModelObjectList();
			for (var i:int=0; i < objects.length(); i++)
			{
				var tempObj:KObject = objects.getObjectAt(i);
				var cloneObj:KObject = _copyObject(model,tempObj,_offset);
				if (model == null || includeMotion)
				{
					_copyMotion(cloneObj, tempObj);
					_copyActivity(cloneObj, tempObj);
					if (model && time-_copyTime != 0)
						_shiftKeys(cloneObj,time-_copyTime);
				}
				else if (model && !includeMotion)
					cloneObj = _copyInstant(model, tempObj,time);
				if (model == null && tempObj.createdTime < time)
				{
					cloneObj.addActivityKey(tempObj.createdTime,0);
					cloneObj.addActivityKey(time,1);
				}
				
				cloned.add(cloneObj);
			}
			return cloned;
		}
		
		private function _shiftKeys(obj:KObject,dt:Number):void
		{
			obj.shiftTransformKeys(dt);
			obj.shiftActivityKeys(dt);
			obj.shiftParentKeys(dt);
		}
				
		private function _copyObject(model:KModel, source:KObject, offset:int):KObject
		{
			var id:int = model == null ? source.id : model.nextID;
			var obj:KObject = null;
			if (source is KGroup)
				obj = _copyGroup(id, _offset, source as KGroup, model);
			else if (source is KStroke)
				obj = _copyStroke(id, _offset, source as KStroke);
			else if(source is KImage)
				obj = _copyImage(id, _offset, source as KImage);
			obj.transformMgr.addInitialKeys(source.createdTime);
			return obj;
		}		

		private function _copyGroup(id:int, offset:int, source:KGroup, model:KModel):KGroup
		{
			var pt:Point = source.defaultCenter.add(new Point(offset,offset));
			var time:Number = source.createdTime;
			var group:KGroup = new KGroup(id,time,new KModelObjectList(),pt);
			var it:IIterator = source.directChildIterator(source.createdTime);
			while (it.hasNext())
			{
				var obj:KObject = _copyObject(model,it.next(),offset);
				obj.addParentKey(time,group);
				group.add(obj);
			}
			group.updateCenter();
			return group;
		}
		
		private function _copyStroke(id:int,offset:int,source:KStroke):KStroke
		{
			return _createStroke(id,source.createdTime,
				_clonePoints(source.points,_offset),source.color,source.thickness);
		}
		
		private function _copyImage(id:int,offset:int,source:KImage):KImage
		{
			var pt:Point = source.imagePosition.add(new Point(offset,offset));
			var time:Number = source.createdTime;
			var image:KImage = new KImage(id,pt.x,pt.y,time);
			image.imageData = source.imageData.clone();
			return image;
		}
		
		private function _copyMotion(target:KObject, source:KObject):void
		{
			var time:Number = source.createdTime;
			var op:KCompositeOperation = new KCompositeOperation();
			KMergerUtil.mergeKeys(target,source,time,op,KTransformMgr.TRANSLATION_REF);
			KMergerUtil.mergeKeys(target,source,time,op,KTransformMgr.ROTATION_REF);
			KMergerUtil.mergeKeys(target,source,time,op,KTransformMgr.SCALE_REF);
		}
		
		private function _copyActivity(target:KObject, source:KObject):void
		{
			var keys:Vector.<IKeyFrame> = source.getActivityKeys();
			for (var i:int = 0; i < keys.length; i++)
				target.addActivityKey(keys[i].endTime,
					(keys[i] as IActivityKeyFrame).alpha);
		}

		private function _copyInstant(model:KModel, obj:KObject, time:Number):KObject
		{
			var clonedObj:KObject = obj;
			var matrix:Matrix = obj.getFullPathMatrix(_copyTime);
			if (obj is KGroup)
			{
				var gp:KGroup = obj as KGroup;
				var list:KModelObjectList = new KModelObjectList();
				var it:IIterator = gp.directChildIterator(time);
				while (it.hasNext())
					list.add(_copyInstant(model, it.next(),time));
				clonedObj = new KGroup(model.nextID,time,list,
					gp.getFullPathMatrix(time).transformPoint(gp.defaultCenter));
				for (var i:int; i < list.length(); i++)
					list.getObjectAt(i).addParentKey(time,clonedObj as KGroup);
				(clonedObj as KGroup).updateCenter();
			}
			else if (obj is KStroke)
			{
				var stroke:KStroke = obj as KStroke;
				var pts:Vector.<Point> = _transformPoints(stroke.points,matrix);
				pts = _clonePoints(pts,_offset);
				clonedObj = _createStroke(model.nextID,time,pts,stroke.color,stroke.thickness);
			}
			else if (obj is KImage)
			{	
				var image:KImage = obj as KImage;
				var pt:Point = matrix.transformPoint(image.imagePosition);
				pt = pt.add(new Point(_offset,_offset));
				clonedObj = _createImage(model.nextID,time,pt,image.imageData);
			}
			clonedObj.transformMgr.addInitialKeys(time);
			return clonedObj;
		}
		
		private function _createStroke(id:int,time:Number,pts:Vector.<Point>,
									   color:uint,thickness:Number):KStroke
		{
			var stroke:KStroke = new KStroke(id,time,pts);
			stroke.thickness = thickness;
			stroke.color = color;
			return stroke;
		}
		
		private function _createImage(id:int,time:Number,center:Point,data:BitmapData):KImage
		{
			var image:KImage = new KImage(id,center.x,center.y,time);
			image.imageData = data;
			return image;
		}
				
		private function _clonePoints(points:Vector.<Point>,offset:int):Vector.<Point>
		{
			var pts:Vector.<Point> = new Vector.<Point>();
			for (var i:int = 0; i < points.length; i++)
				pts.push(points[i].clone().add(new Point(offset,offset)));
			return pts;
		}
		
		private function _transformPoints(points:Vector.<Point>,matrix:Matrix):Vector.<Point>
		{
			var pts:Vector.<Point> = new Vector.<Point>();
			for (var i:int = 0; i < points.length; i++)
				pts.push(matrix.transformPoint(points[i].clone()));
			return pts;
		}		
	}
}
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
	
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.KMergerUtil;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
		
	public class KClipBoard
	{	
		public static const OFFSET_INCREMENT:int = 20;
		private var _template_objects:KModelObjectList;
		private var _offset:int = 0;

		public function KClipBoard()
		{
			_template_objects = new KModelObjectList();
		}
		
		public function clear():void
		{
			_template_objects = new KModelObjectList();
		}
		
		public function put(objects:KModelObjectList, kskTime:Number):void
		{
			_offset = 0;
			_template_objects = _copyObjects(null,objects,kskTime,true);
		}
		
		public function get(model:KModel, kskTime:Number, 
							includeMotion:Boolean=true):KModelObjectList
		{
			_offset+=OFFSET_INCREMENT;
			return _copyObjects(model,_template_objects,kskTime,includeMotion);
		}
		
		private function _copyObjects(model:KModel,objects:KModelObjectList,
									time:Number,includeMotion:Boolean):KModelObjectList
		{
			var cloned:KModelObjectList = new KModelObjectList();
			for (var i:int=0; i < objects.length(); i++)
			{
				var tempObj:KObject = objects.getObjectAt(i);
				var cloneObj:KObject = _copyObject(model,tempObj,time,_offset);
				if (includeMotion)
					_cloneKeys(cloneObj,tempObj,time);
				cloned.add(cloneObj);
			}
			return cloned;
		}

		private function _copyObject(model:KModel, source:KObject, time:Number, offset:int):KObject
		{
			var id:int = model == null ? source.id : model.nextID;
			var obj:KObject = null;
			if (source is KGroup)
				obj = _copyGroup(id, time, _offset, source as KGroup, model);
			else if (source is KStroke)
				obj = _copyStroke(id, time, _offset, source as KStroke);
			else if(source is KImage)
				obj = _copyImage(id, time, _offset, source as KImage);
			obj.transformMgr.addInitialKeys(time);
			return obj;
		}		

		private function _copyGroup(id:int, time:Number, offset:int, 
									source:KGroup, model:KModel):KGroup
		{
			var pt:Point = source.defaultCenter.add(new Point(offset,offset)); 
			var group:KGroup = new KGroup(id,time,new KModelObjectList(),pt);
			var it:IIterator = source.directChildIterator(source.createdTime);
			while (it.hasNext())
			{
				var obj:KObject = _copyObject(model,it.next(),time,offset);
				obj.addParentKey(time,group);
				group.add(obj);
			}
			group.updateCenter();
			return group;
		}
		
		private function _copyStroke(id:int,time:Number,offset:int,source:KStroke):KStroke
		{
			var pts:Vector.<Point> = _clonePoints(source.points,_offset);
			var stroke:KStroke = new KStroke(id,time,pts);
			stroke.thickness = source.thickness;
			stroke.color = source.color;
			return stroke;
		}
		
		private function _copyImage(id:int,time:Number,offset:int,source:KImage):KImage
		{
			var pt:Point = source.imagePosition.add(new Point(offset,offset));
			var image:KImage = new KImage(id,pt.x,pt.y,time);
			image.imageData = source.imageData.clone();
			return image;
		}
						
		private function _clonePoints(points:Vector.<Point>,offset:int):Vector.<Point>
		{
			var pts:Vector.<Point> = new Vector.<Point>();
			for (var i:int = 0; i < points.length; i++)
				pts.push(points[i].clone().add(new Point(offset,offset)));
			return pts;
		}
		
		private function _cloneKeys(target:KObject, source:KObject, time:Number):void
		{
			KMergerUtil.mergeKeys(target,source,time,new KCompositeOperation(),KTransformMgr.TRANSLATION_REF);
			KMergerUtil.mergeKeys(target,source,time,new KCompositeOperation(),KTransformMgr.ROTATION_REF);
			KMergerUtil.mergeKeys(target,source,time,new KCompositeOperation(),KTransformMgr.SCALE_REF);
		}
/*
		private function _cloneKeys(target:KObject, source:KObject, time:Number):void
		{
			KMergerUtil.mergeKeys(target,source,time,new KCompositeOperation(),KTransformMgr.TRANSLATION_REF);
			KMergerUtil.mergeKeys(target,source,time,new KCompositeOperation(),KTransformMgr.ROTATION_REF);
			KMergerUtil.mergeKeys(target,source,time,new KCompositeOperation(),KTransformMgr.SCALE_REF);
		}
*/
	}
}
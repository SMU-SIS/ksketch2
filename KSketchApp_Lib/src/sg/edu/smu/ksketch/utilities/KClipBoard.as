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
			_template_objects = copyObjects(null,objects,kskTime);
		}
		
		public function get(model:KModel, kskTime:Number):KModelObjectList
		{
			_offset+=OFFSET_INCREMENT;
			return copyObjects(model,_template_objects,kskTime);
		}
		
		public function copyObjects(model:KModel,objects:KModelObjectList,
									kskTime:Number):KModelObjectList
		{
			var cloned:KModelObjectList = new KModelObjectList();
			for (var i:int=0; i < objects.length(); i++)
			{
				var tempObj:KObject = objects.getObjectAt(i);
				var modelObj:KObject = model == null ? null : model.getObjectByID(tempObj.id);
				var matrix:Matrix = modelObj == null ? null : modelObj.getFullPathMatrix(kskTime);
				var pt:Point = matrix == null ? null : matrix.transformPoint(modelObj.defaultCenter);
				var dh:Number = pt == null ? -1 : KMathUtil.distanceOf(tempObj.defaultCenter,pt);
				var off:int = _offset <= OFFSET_INCREMENT && dh > OFFSET_INCREMENT/2 ? 0 : _offset;
				off = _offset <= OFFSET_INCREMENT && dh == -1 ? 0 : off;
				cloned.add(copyObject(model,tempObj,kskTime,off));
			}
			return cloned;
		}

		public function copyObject(model:KModel, object:KObject, kskTime:Number, offset:int):KObject
		{
			var id:int = model == null ? object.id : model.nextID;
			var matrix:Matrix;
			if (object is KStroke)
			{
				matrix = object.getFullPathMatrix(kskTime);
				var points:Vector.<Point> = _clonePoints((object as KStroke).points,matrix,offset);
				var stroke:KStroke = new KStroke(id,kskTime,points);
				stroke.thickness = (object as KStroke).thickness;
				stroke.color = (object as KStroke).color;
				return stroke;
			}
			else if (object is KGroup)
			{	
				var ctr:Point = (object as KGroup).defaultCenter.add(new Point(offset,offset)); 
				var group:KGroup = new KGroup(id,kskTime,new KModelObjectList(),ctr);
				var it:IIterator = (object as KGroup).directChildIterator(object.createdTime);
				while (it.hasNext())
				{
					var obj:KObject = copyObject(model,it.next(),kskTime,offset);
					obj.addParentKey(kskTime,group);
					group.add(obj);
				}
				group.updateCenter();
				return group;
			}
			else if(object is KImage)
			{
				var pt:Point = (object as KImage).imagePosition;
				var image:KImage = new KImage(id,pt.x+offset,pt.y+offset,kskTime);
				image.imageData = (object as KImage).imageData.clone();
				return image;
			}
			return null;
		}		

		private function _clonePoints(points:Vector.<Point>, m:Matrix, 
									  offset:int):Vector.<Point>
		{
			var pts:Vector.<Point> = new Vector.<Point>();
			for (var i:int = 0; i < points.length; i++)
				pts.push(m.transformPoint(points[i].clone()).add(new Point(offset,offset)));
			return pts;
		}	
		
		private function _getAllStrokes(group:KGroup, kskTime:Number):KModelObjectList
		{
			var list:KModelObjectList = new KModelObjectList();
			var it:IIterator = group.allChildrenIterator(kskTime);
			var obj:KObject;
			while(it.hasNext())
				if ((obj = it.next()) is KStroke)
					list.add(obj);
			return list;
		}
	}
}
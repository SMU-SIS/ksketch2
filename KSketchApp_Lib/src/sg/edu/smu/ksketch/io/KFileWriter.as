/**------------------------------------------------
 * Copyright 2012 Singapore Management University
 * All Rights Reserved
 *
 *-------------------------------------------------*/

package sg.edu.smu.ksketch.io
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Encoder;
	import sg.edu.smu.ksketch.model.IKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KMovieClip;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.model.geom.K2DVector;
	import sg.edu.smu.ksketch.model.geom.K3DVector;
	import sg.edu.smu.ksketch.model.implementations.KActivityKeyFrame;
	import sg.edu.smu.ksketch.model.implementations.KParentKeyframe;
	import sg.edu.smu.ksketch.model.implementations.KSpatialKeyFrame;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.utilities.IIterator;
	
	public class KFileWriter extends KFileParser
	{	
		public static function debugInfo(object:KObject):XML
		{
			return _generateNode_ExclChildren(object, true);
		}
		
		public static function kObjectsToFile(root:KGroup):XML
		{
			return _kObjectsToFile(root, new Vector.<int>());
		}
		
		private static function _kObjectsToFile(group:KGroup, existingObjects:Vector.<int>):XML
		{
			var xml:XML = new XML( "<" + ROOT + "></" + ROOT + ">");
			var i:IIterator = group.iterator;
			while(i.hasNext())
				xml.appendChild(_generateKObjectNode(i.next(), false, existingObjects));
			return xml;
		}
		
		private static function _generateKObjectNode(object:KObject, showDefault:Boolean, 
													 existingObjects:Vector.<int>):XML
		{
			var node:XML;
			if(existingObjects.indexOf(object.id) < 0)
			{
				existingObjects.push(object.id);
				node = _generateNode_ExclChildren(object, showDefault);
				if(object is KGroup)
					node.appendChild(_kObjectsToFile(object as KGroup, existingObjects).children());
			}
			else
				node = _generateNode_IDOnly(object);
			return node;
		}
		
		////Damian
		private static function _generateNode_IDOnly(object:KObject):XML
		{
			var strokeNode:String = "<" + STROKE + "></" + STROKE + ">";
			var groupNode:String = "<" + GROUP + "></" + GROUP + ">";
			var imageNode:String = "<" + IMAGE + "></" + IMAGE + ">";
			var node:XML;
			if(object is KStroke)
				node = new XML(strokeNode);
			else if(object is KGroup)
				node = new XML(groupNode);
			else if(object is KImage)
				node = new XML(imageNode);
			else if(object is KMovieClip)
				node = new XML(imageNode);
			else
				throw new Error("unsupported kobject!");
			_parseIDAttr(node, object.id);
			return node;
		}
		
		private static function _generateNode_ExclChildren(object:KObject, showDefault:Boolean):XML
		{
			var strokeNode:String = "<" + STROKE + "></" + STROKE + ">";
			var groupNode:String = "<" + GROUP + "></" + GROUP + ">";
			var imageNode:String = "<" + IMAGE + "></" + IMAGE + ">";
			var node:XML;
			if(object is KStroke)
			{
				node = new XML(strokeNode);
				var stroke:KStroke = object as KStroke;
				_setObjectAttr(node, stroke, showDefault);
				_setStrokeAttr(node, stroke);
			}
			else if(object is KGroup)
			{
				var group:KGroup = object as KGroup;
				node = new XML(groupNode);
				_setObjectAttr(node, group, showDefault);
			}
			else if(object is KImage)
			{
				var image:KImage = object as KImage;			
				node = new XML(imageNode);
				_setObjectAttr(node, image, showDefault);
				_setImageAttr(node, image);
			}
			else if(object is KMovieClip)
			{
				var movieClip:MovieClip = (object as KMovieClip).movieClip;
				var point:Point = movieClip.movieClipPosition;
				var toBeSavedImage:BitmapData = new BitmapData(movieClip.width, movieClip.height);
				toBeSavedImage.draw(movieClip);
				var tempImage:KImage = new KImage(0, point.x, point.y, object.createdTime);
				node = new XML(imageNode);
				_setObjectAttr(node, object, showDefault);
				_setImageAttr(node, tempImage);
			}
			else
				throw new Error("unsupported kobject!");
			return node;
		}
		
		private static function _setImageAttr(node:XML, image:KImage):void
		{
			node.@[IMAGE_X] = image.imagePosition.x;
			node.@[IMAGE_Y] = image.imagePosition.y;
			node.@[IMAGE_WIDTH] = image.imageData.width;
			node.@[IMAGE_HEIGHT] = image.imageData.height;
			node.@[IMAGE_FORMAT]= IMAGE_FORMAT_PNG;
			node.@[IMAGE_DATA] = pngToString(image.imageData);
		}
		
		private static function _setStrokeAttr(node:XML, stroke:KStroke):void
		{
			node.@[COLOR] = stroke.color;
			node.@[THICKNESS] = stroke.thickness;
			node.@[STROKE_POINTS] = pointsToString(stroke.points);
		}
		
		private static function _setObjectAttr(node:XML, object:KObject, showDefault:Boolean):void
		{
			_parseIDAttr(node, object.id);
			_parseFrameListNode(node, object, showDefault);
		}
		
		private static function _parseFrameListNode(node:XML, object:KObject, showDefault:Boolean):void
		{
			var frameListNode:XML = new XML("<" + KEYFRAME_LIST + "/>");
			_parseActivityKeys(frameListNode,object.getActivityKeys());
			_parseParentKeys(frameListNode,object.getParentKeys());
			_parseTranslationKeys(frameListNode, object.getSpatialKeys(KTransformMgr.TRANSLATION_REF));
			_parseRotationKeys(frameListNode, object.getSpatialKeys(KTransformMgr.ROTATION_REF));
			_parseScaleKeys(frameListNode, object.getSpatialKeys(KTransformMgr.SCALE_REF));
			if(frameListNode.children().length() != 0)
				node.appendChild(frameListNode);
		}
		
		private static function _parseActivityKeys(frame_listNode:XML,keys:Vector.<IKeyFrame>):void
		{	
			for each(var key:IKeyFrame in keys)
			{
				var node:XML = new XML("<" + KEYFRAME + "/>");
				node.@[KEYFRAME_TYPE] = KEYFRAME_TYPE_ACTIVITY;
				node.@[KEYFRAME_TIME] = key.endTime;
				var activity:KActivityKeyFrame = key as KActivityKeyFrame;
				if(activity.alpha >= 0)
					node.@[ACTIVITY_ALPHA] = activity.alpha;
				frame_listNode.appendChild(node);
			}			
		}
		
		private static function _parseParentKeys(frame_listNode:XML,keys:Vector.<IKeyFrame>):void
		{			
			for each(var key:IKeyFrame in keys)
			{
				var node:XML = new XML("<" + KEYFRAME + "/>");
				node.@[KEYFRAME_TYPE] = KEYFRAME_TYPE_PARENT;
				node.@[KEYFRAME_TIME] = key.endTime;
				node.@[PARENT_ID] = (key as KParentKeyframe).parent.id;
				frame_listNode.appendChild(node);
			}			
		}
		
		private static function _parseTranslationKeys(frame_listNode:XML,keys:Vector.<IKeyFrame>):void
		{			
			for each(var key:IKeyFrame in keys)
			{
				var skey:KSpatialKeyFrame = key as KSpatialKeyFrame;
				var path:String = _get3DString(skey.translate.transitionPath.points);
				frame_listNode.appendChild(_createSpatialNode(KEYFRAME_TYPE_TRANSLATE,
					key.endTime,path,skey.center.x,skey.center.y));
			}
		}
		
		private static function _parseRotationKeys(frame_listNode:XML,keys:Vector.<IKeyFrame>):void
		{
			for each(var key:IKeyFrame in keys)
			{
				var skey:KSpatialKeyFrame = key as KSpatialKeyFrame;
				var path:String = _get2DString(skey.rotate.transitionPath.points);
				frame_listNode.appendChild(_createSpatialNode(KEYFRAME_TYPE_ROTATE,
					key.endTime,path,skey.center.x,skey.center.y));
			}
		}
		
		private static function _parseScaleKeys(frame_listNode:XML,keys:Vector.<IKeyFrame>):void
		{
			for each(var key:IKeyFrame in keys)
			{
				var skey:KSpatialKeyFrame = key as KSpatialKeyFrame;
				var path:String = _get2DString(skey.scale.transitionPath.points);
				frame_listNode.appendChild(_createSpatialNode(KEYFRAME_TYPE_SCALE,
					key.endTime,path,skey.center.x,skey.center.y));
			}
		}
		
		private static function _createSpatialNode(type:String, endTime:Number, path:String,
												   centerX:Number=NaN, centerY:Number=NaN):XML
		{
			var node:XML = new XML("<" + KEYFRAME + "/>");
			node.@[KEYFRAME_TYPE] = type;
			node.@[KEYFRAME_TIME] = endTime;
			node.@[KEYFRAME_CURSOR_PATH] = path;
			if (!isNaN(centerX))
				node.@[KEYFRAME_CENTER_X] = centerX;
			if (!isNaN(centerY))
				node.@[KEYFRAME_CENTER_Y] = centerY;
			return node;
		}
		
		private static function _get3DString(points:Vector.<K3DVector>):String
		{			
			var path:String = points.length>0 ? points[0].x+","+points[0].y+","+points[0].z : "";
			for (var i:int=1; i<points.length; i++)
				path += " "+points[i].x+","+points[i].y+","+points[i].z;
			return path;
		}				
		
		private static function _get2DString(points:Vector.<K2DVector>):String
		{			
			var path:String = points.length>0 ? points[0].x+","+points[0].y : "";
			for (var i:int=1; i<points.length; i++)
				path += " "+points[i].x+","+points[i].y;
			return path;
		}				
		
		private static function _parseIDAttr(node:XML, id:int):void
		{
			node.@[ID] = id;
		}
	}
}
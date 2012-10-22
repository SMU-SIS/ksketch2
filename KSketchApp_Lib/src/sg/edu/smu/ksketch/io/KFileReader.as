/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.io
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.ISpatialKeyframe;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.model.geom.K2DPath;
	import sg.edu.smu.ksketch.model.geom.K2DVector;
	import sg.edu.smu.ksketch.model.geom.K3DPath;
	import sg.edu.smu.ksketch.model.geom.K3DVector;
	import sg.edu.smu.ksketch.model.geom.KPath;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.model.geom.KPathProcessor;
	import sg.edu.smu.ksketch.model.geom.KRotation;
	import sg.edu.smu.ksketch.model.geom.KScale;
	import sg.edu.smu.ksketch.model.geom.KTranslation;
	import sg.edu.smu.ksketch.model.implementations.KActivityKeyFrame;
	import sg.edu.smu.ksketch.model.implementations.KKeyFrame;
	import sg.edu.smu.ksketch.model.implementations.KParentKeyframe;
	import sg.edu.smu.ksketch.operation.KGroupUtil;
	import sg.edu.smu.ksketch.operation.KTransformMgr;
	import sg.edu.smu.ksketch.operation.implementations.KCompositeOperation;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	public class KFileReader extends KFileParser
	{
		/**
		 * Given a model, replaces its current hierarchy and instantiates
		 * a scene graph from the given xml
		 */
		public static function xmlToModel(xml:XML, model:KModel, parent:KGroup = null, debugSpacing:String = ""):void
		{
			if(xml == null)
				throw new Error("file cannot be null!");
			if(xml.name() == null)
				throw new Error("unsupported file!");
			
			if(!parent)
				parent = model.root;
			
			var currentNode:XML;
			var objectNodes:XMLList = xml.children();

			for(var i:int = 0; i< objectNodes.length(); i++)
			{
				currentNode = objectNodes[i];
				trace(debugSpacing,currentNode.name(), currentNode.@id);
				
				switch(currentNode.name().toString())
				{
					case KFileParser.GROUP:
						var group:KGroup = _generateGroup(currentNode);
						KGroupUtil.addObjectToParent(KGroupUtil.STATIC_GROUP_TIME, group, parent, null);
						xmlToModel(currentNode, model, group, debugSpacing+"	");
						break;
					case KFileParser.STROKE:
						var stroke:KStroke = _generateStroke(currentNode);
						KGroupUtil.addObjectToParent(KGroupUtil.STATIC_GROUP_TIME, stroke, parent, null);
						break;
					case KFileParser.IMAGE:
						var image:KImage = _generateImage(currentNode);
						KGroupUtil.addObjectToParent(KGroupUtil.STATIC_GROUP_TIME, image, parent, null);
						break;
				}
			}
		}
		
		private static function _generateGroup(node:XML):KGroup
		{
			var id:int = node.attribute(ID);
			var createdTime:Number = _getCreatedTime(node);
			var group:KGroup = new KGroup(id, createdTime, null, new Point(0, 0));
			_setObjectFields(group, node);
			return group;
		}
		
		private static function _generateImage(node:XML):KImage
		{
			var id:int = node.attribute(ID);
			var createdTime:Number = _getCreatedTime(node);
			var xPos:Number = node.attribute(IMAGE_X);
			var yPos:Number = node.attribute(IMAGE_Y);	
			var image:KImage = new KImage(id, xPos, yPos, createdTime);
			image.data64 = node.attribute(IMAGE_DATA);
			_setObjectFields(image, node);
			return image;
		}		
		
		private static function _generateStroke(node:XML):KStroke
		{
			var id:int = node.attribute(ID);
			var createdTime:Number = _getCreatedTime(node);
			var points:Vector.<Point> = _generatePoints(node.attribute(STROKE_POINTS));
			var stroke:KStroke = new KStroke(id, createdTime, points);
			stroke.color = node.attribute(COLOR);
			stroke.thickness = node.attribute(THICKNESS);
			_setObjectFields(stroke, node);
			return stroke;
		}
		
		private static function _setObjectFields(object:KObject, node:XML):void
		{
			var frame_listNodes:XMLList = node.child(KEYFRAME_LIST);
			if(frame_listNodes.length() == 1)
			{
				var frame_listNode:XML = frame_listNodes[0];
				for each(var keyNode:XML in frame_listNode.child(KEYFRAME))
				{
					var path:String = keyNode.attribute(KEYFRAME_CURSOR_PATH);
					var keyframeType:String = keyNode.attribute(KEYFRAME_TYPE).toString();
					if(keyframeType == KEYFRAME_TYPE_ACTIVITY)
					{
						var activityKey:KActivityKeyFrame = 
							_generateActivityKeyframe(keyNode) as KActivityKeyFrame;
						object.addActivityKey(activityKey.endTime,
							activityKey.alpha);
					}
					else if (path != null)
					{
						var endTime:Number = keyNode.attribute(KEYFRAME_TIME);
						var centerX:Number = keyNode.attribute(KEYFRAME_CENTER_X);
						var centerY:Number = keyNode.attribute(KEYFRAME_CENTER_Y);
						var center:Point = new Point(centerX,centerY);
						//			var transitionType:String = KEYFRAME_TRANSITION_TYPE_REALTIME;
						switch (keyframeType)
						{
							case KEYFRAME_TYPE_TRANSLATE:
								_setTranslation(object,path,centerX,centerY,endTime);
								break;
							case KEYFRAME_TYPE_ROTATE:
								_setRotation(object,path,centerX,centerY,endTime);
								break;
							case KEYFRAME_TYPE_SCALE:
								_setScale(object,path,centerX,centerY,endTime);
								break;
						}
					}
				}
			}
			else if(frame_listNodes.length() > 1)
				throw new Error("parse error: each KObject cannot contain more than one frame_list");
		}
		
		private static function _setTranslation(object:KObject, path:String, 
												centerX:Number, centerY:Number, time:Number):void
		{
			var key:ISpatialKeyframe = object.transformMgr.addKeyFrame(
				KTransformMgr.TRANSLATION_REF,time,centerX,centerY,
				new KCompositeOperation()) as ISpatialKeyframe;
			key.translate = _getTranslation(path);
		}
		
		private static function _getTranslation(path:String):KTranslation
		{
			var translation:KTranslation = new KTranslation();
			translation.transitionPath = _gererate3DPath(_generate3DPoints(path));;
			translation.motionPath = KPathProcessor.generateTranslationMotionPath(translation.transitionPath);
			return translation;
		}
		
		private static function _setRotation(object:KObject, path:String, 
											 centerX:Number, centerY:Number, time:Number):void
		{
			var key:ISpatialKeyframe = object.transformMgr.addKeyFrame(
				KTransformMgr.ROTATION_REF,time,centerX,centerY,
				new KCompositeOperation()) as ISpatialKeyframe;
			key.rotate = _getRotation(path);
		}
		
		private static function _getRotation(path:String):KRotation
		{
			var rotation:KRotation = new KRotation();
			rotation.transitionPath = _generate2DPath(_generate2DPoints(path));
			rotation.motionPath = KPathProcessor.generateRotationMotionPath(rotation.transitionPath);
			return rotation;
		}
		
		private static function _setScale(object:KObject, path:String, 
										  centerX:Number, centerY:Number, time:Number):void
		{
			var key:ISpatialKeyframe = object.transformMgr.addKeyFrame(
				KTransformMgr.SCALE_REF,time,centerX,centerY,
				new KCompositeOperation()) as ISpatialKeyframe;
			key.scale = _getScale(path);
		}
		
		private static function _getScale(path:String):KScale
		{
			var scale:KScale = new KScale();
			scale.transitionPath = _generate2DPath(_generate2DPoints(path));
			scale.motionPath = KPathProcessor.generateScaleMotionPath(scale.transitionPath);
			return scale;
		}
		
		private static function _getCreatedTime(node:XML):Number
		{
			var kskTime:Number = -1;
			var tmpKSKTime:Number;
			var frame_listNodes:XMLList = node.child(KEYFRAME_LIST);
			if(frame_listNodes.length() == 1)
			{
				var frame_listNode:XML = frame_listNodes[0];
				for each(var keyNode:XML in frame_listNode.child(KEYFRAME))
				{
					if(keyNode.attribute(KEYFRAME_TYPE).toString() ==  KEYFRAME_TYPE_PARENT)
					{
						tmpKSKTime = keyNode.attribute(KEYFRAME_TIME);
						if(kskTime < 0)
							kskTime = tmpKSKTime;
						if(tmpKSKTime < kskTime)
							kskTime = tmpKSKTime;
					}
				}
			}
			else
				throw new Error("parse error: each KObject cannot contain more than one frame_list");
			return kskTime;
		}
		
		private static function _generatePoints(pntsString:String):Vector.<Point>
		{
			if(pntsString == null)
				return null;
			var points:Vector.<Point> = new Vector.<Point>();
			var coordinates:Array = pntsString.split(" ");
			for each(var point:String in coordinates)
			{
				if(point != "")
				{
					var xy:Array = point.split(",");
					if(xy.length==2)
						points.push(new Point(xy[0], xy[1]));
					else
						throw new Error("Stroke.points: expected 2 parameters " +
							"for each coordiantes, but found \""+point+"\"");
				}
			}
			return points;
		}
		
		private static function _generateParentKeyframe(node:XML, objectList:KModelObjectList):KKeyFrame
		{
			var kskTime:Number = node.attribute(KEYFRAME_TIME);
			var parentID:int = parseInt(node.attribute(PARENT_ID).toString());
			var parent:KGroup = _getObjectByID(objectList, parentID) as KGroup;
			if(parent == null)
				throw new Error("There is no parent object with id:"+parentID);
			return new KParentKeyframe(kskTime, parent);
		}
		
		private static function _generateActivityKeyframe(node:XML):KKeyFrame
		{
			var kskTime:Number = node.attribute(KEYFRAME_TIME);
			var alpha:Number = -1;
			var str:String = node.attribute(ACTIVITY_ALPHA);
			if(str!=null && str.length>0)
				alpha = new Number(str);
			return new KActivityKeyFrame(kskTime, alpha);
		}
		
		private static function _generate2DPath(points:Vector.<K2DVector>):K2DPath
		{
			var path2D:K2DPath = new K2DPath();
			for (var i:int=0; i < points.length; i++)
				path2D.push(points[i].x,points[i].y);
			return path2D
		}
		
		private static function _generate2DPoints(path:String):Vector.<K2DVector>
		{
			if(path == null)
				return null;
			var points:Vector.<K2DVector> = new Vector.<K2DVector>();
			var pointStrArr:Array = path.split(" ");			
			for each(var pointStr:String in pointStrArr)
			{
				if(pointStr != "")
				{
					var pt:Array = pointStr.split(",");
					if(pt.length == 2)
						points.push(new K2DVector(pt[0], pt[1]));
					else
						throw new Error("Keyframe.cursorPath: expected 2 parameters " +
							"for each cursor path point, but found \""+pointStr+"\"");
				}
			}
			return points;
		}
		
		private static function _generateKPath(points:Vector.<KPathPoint>):KPath
		{
			var path:KPath = new KPath();
			for (var i:int=0; i < points.length; i++)
				path.addPoint(points[i].x,points[i].y,points[i].time);
			return path;
		}
		
		private static function _gererate3DPath(points:Vector.<K3DVector>):K3DPath
		{
			var path3D:K3DPath = new K3DPath();
			for (var i:int=0; i < points.length; i++)
				path3D.push(points[i].x,points[i].y,points[i].z);
			return path3D
		}
		
		private static function _generate3DPoints(path:String):Vector.<K3DVector>
		{
			if(path == null)
				return null;
			var points:Vector.<K3DVector> = new Vector.<K3DVector>();
			var pointStrArr:Array = path.split(" ");			
			for each(var pointStr:String in pointStrArr)
			{
				if(pointStr != "")
				{
					var pt:Array = pointStr.split(",");
					if(pt.length == 3)
						points.push(new K3DVector(pt[0], pt[1], pt[2]));
					else
						throw new Error("Keyframe.cursorPath: expected 3 parameters " +
							"for each cursor path point, but found \""+pointStr+"\"");
				}
			}
			return points;
		}
		
		private static function _generateInstantOffset(node:XML):Point
		{
			var str:String = node.attribute(POSITION_KEYFAME_INSTANT_OFFSET);
			if(str==null || str.length==0)
				return new Point();
			var pointStrArr:Array = str.split(",");
			var offset:Point;
			if(pointStrArr.length==2)
				offset = new Point(pointStrArr[0], pointStrArr[1]);
			else
				throw new Error("position keyframe instant offset: " +
					"expected 2 parameters but found \""+str+"\"");
			return offset;
		}
		
		private static function _generateInstantAngle(node:XML):Number
		{
			var str:String = node.attribute(ROTATION_KEYFAME_INSTANT_ANGLE);
			if(str==null || str.length==0)
				return 0;
			var angle:Number = new Number(str) * Math.PI / 180;
			return angle;
		}
		
		private static function _generateInstantFactor(node:XML):Number
		{
			var str:String = node.attribute(SCALE_KEYFAME_INSTANT_FACTOR);
			if(str==null || str.length==0)
				return 1;
			var factor:Number = new Number(str);
			return factor;
		}
		
		private static function _hasObjectID(objectList:KModelObjectList, id:int):Boolean
		{
			var it:IIterator = objectList.iterator;
			while(it.hasNext())
				if(it.next().id == id)
					return true;
			return false;
		}
		
		private static function _getObjectByID(objectList:KModelObjectList, id:int):KObject
		{
			var it:IIterator = objectList.iterator;
			var obj:KObject;
			while(it.hasNext())
			{
				obj = it.next();
				if(obj.id == id)
					return obj;
			}
			return null;
		}
	}
}
/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.data_structures
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.operators.operations.KInsertKeyOperation;
	import sg.edu.smu.ksketch2.operators.operations.KReplacePathOperation;
	
	public class KSpatialKeyFrame extends KKeyFrame implements ISpatialKeyFrame
	{
		private var _isDirty:Boolean;
		private var _center:Point;
		private var _actualCenter:Point;
		public var translatePath:KPath;
		public var rotatePath:KPath;
		public var scalePath:KPath;
		
		//Paths used during transition
		//If they aren't cleared after transitions, an error will be thrown
		public var tempX:Number;
		public var tempY:Number;
		public var tempTheta:Number;
		public var tempSigma:Number;
		
		public function KSpatialKeyFrame(newTime:int, center:Point)
		{
			super(newTime);
			
			_isDirty = true;
			_center = center.clone();
			translatePath = new KPath();
			rotatePath = new KPath();
			scalePath = new KPath();
			
			tempX = 0;
			tempY = 0;
			tempTheta = 0;
			tempSigma = 0;
		}
		
		public function dirtyKey():void
		{
			_isDirty = true;
			(next as KSpatialKeyFrame).dirtyKey();
		}
		
		public function get center():Point
		{
			return _center.clone();
		}
		
		/**
		 * Returns the concatenated matrix from all previous and this key frame up till getTime
		 */
		public function fullMatrix(getTime:int):Matrix
		{
			var pre:Array = getMatrixPair(getTime);
			var result:Matrix = pre[1];
			result.concat(pre[0] as Matrix);
			return result;
		}
		
		/**
		 * Temporary function with a stupid name to get a pair of matrices
		 * [translation matrix, RS matrix] from the previous key frames
		 */
		public function getMatrixPair(getTime:int):Array
		{
			var tMat:Matrix;
			var rsMat:Matrix;
			
			if(_previous)
			{
				var pre:Array = (_previous as KSpatialKeyFrame).getMatrixPair(getTime);
				tMat = pre[0];
				rsMat = pre[1];
			}
			else
			{
				tMat = new Matrix();
				rsMat = new Matrix();
			}
			
			if(getTime < startTime)
				return [tMat, rsMat];
			
			var transforms:Array = _findTransforms(getTime);
			rsMat.translate(-_center.x, -_center.y);
			rsMat.rotate(transforms[0]);
			rsMat.scale(transforms[1], transforms[1]);
			rsMat.translate(_center.x, _center.y);
			tMat.translate(transforms[2],transforms[3]);
			return [tMat, rsMat];
		}
		
		/**
		 *Returns this key frame's transformation matrix up to getTime
		 * Contains duplicate code path from getPartial matrix, JT should really go and 
		 * clean this up if it works
		 */
		public function partialMatrix(getTime:int):Matrix
		{
			getMatrixPair(startTime);

			var transforms:Array = _findTransforms(getTime);
			
			//create the matrix for this key frame
			var matrix:Matrix = new Matrix();
			matrix.translate(-_center.x, -_center.y);
			matrix.rotate(transforms[0]);
			matrix.scale(transforms[1],transforms[1]);
			matrix.translate(transforms[2], transforms[3]);
			matrix.translate(_center.x, _center.y);
			return matrix;
		}
		
		private function _findTransforms(getTime:int):Array
		{
			if(getTime < startTime)
				return [0,1,0,0];
			
			var keyDuration:int = this.duration;
			
			var point:KTimedPoint;
			var theta:Number = 0;
			var sigma:Number = 1;
			var dx:Number = 0;
			var dy:Number = 0;
			
			//Duration 0 happens on two cases
			//1. Key is really of 0 duration
			//2. There is no previous key, which means it can only be the head key
			var proportion:Number;
			if(keyDuration == 0)
				proportion = 1;
			else
				proportion = Number((getTime-startTime)/keyDuration);
			
			//Return the full path transform
			theta = tempTheta;
			point = rotatePath.find_Point(proportion);
			if(point)
				theta += point.x;

			
			sigma = 1+tempSigma;
			point = scalePath.find_Point(proportion);
			if(point)
				sigma += point.x;

			
			dx = tempX;
			dy = tempY;
			point = translatePath.find_Point(proportion);
			if(point)
			{
				dx += point.x;
				dy += point.y;
			}

			
			return [theta, sigma, dx, dy];
		}
		
		/**
		 * If this keyframe has a transition, it will return true, else false.
		 * transition is determined by having changes in its transformation over time.
		 */
		override public function hasActivityAtTime():Boolean
		{
			return translatePath.length > 0 || rotatePath.length > 0 || scalePath.length > 0;
		}
		
		/**
		 * Returns a clone of this KSpatialKeyframe.
		 */
		override public function clone():IKeyFrame
		{
			var newKey:KSpatialKeyFrame = new KSpatialKeyFrame(_time, _center.clone());
			newKey.translatePath = translatePath.clone();
			newKey.rotatePath = rotatePath.clone();
			newKey.scalePath = scalePath.clone();
			
			return newKey;
		}
		
		/**
		 * Splits this key into two portions
		 */
		override public function splitKey(atTime:int, op:KCompositeOperation):IKeyFrame
		{
			//Handle the pre split operation first
			//We are basically "removing" this key and adding 2 more keys, so a total of 3 key operations
			
			//Find the proportion
			var proportion:Number = findProportion(Number(atTime));
			var frontKey:KSpatialKeyFrame = new KSpatialKeyFrame(atTime, center);
			var oldPath:KPath;
			
			oldPath = translatePath.clone();
			frontKey.translatePath = translatePath.splitPath(proportion);
			op.addOperation(new KReplacePathOperation(this, translatePath, oldPath, KSketch2.TRANSFORM_TRANSLATION));
				
			oldPath = rotatePath.clone();	
			frontKey.rotatePath = rotatePath.splitPath(proportion);
			op.addOperation(new KReplacePathOperation(this, rotatePath, oldPath, KSketch2.TRANSFORM_ROTATION));
			
			oldPath = scalePath.clone();	
			frontKey.scalePath = scalePath.splitPath(proportion);
			op.addOperation(new KReplacePathOperation(this, scalePath, oldPath, KSketch2.TRANSFORM_SCALE));
			
			frontKey.previous = previous;

			if(previous)
				(previous as KSpatialKeyFrame).next = frontKey;
			
			frontKey.next = this;
			previous = frontKey;
			
			//Now we have 2 more keys
			//Deal with teh 2 "inserted keys"
			op.addOperation(new KInsertKeyOperation(frontKey.previous, this, frontKey));
			
			return frontKey;
		}
		
		override public function isUseful():Boolean
		{
			var hasTranslation:Boolean = true;
			var hasRotation:Boolean = true;
			var hasScale:Boolean = true;
			
			return (time != 0) && (hasActivityAtTime()||((next != null)&&next.hasActivityAtTime()));
		}
		
		override public function serialize():XML
		{
			var keyXML:XML = <spatialkey time="0" center=""/>;
			keyXML.@time = _time.toString();
			keyXML.@center = _center.x.toString()+","+_center.y.toString();
			
			var pathXML:XML = translatePath.serialize();
			pathXML.@type = "translate";
			keyXML.appendChild(pathXML);
			
			pathXML = rotatePath.serialize();
			pathXML.@type = "rotate";
			keyXML.appendChild(pathXML);
			
			pathXML = scalePath.serialize();
			pathXML.@type = "scale";
			keyXML.appendChild(pathXML);
			
			return keyXML;
		}
		
		override public function deserialize(xml:XML):void
		{
			var centroidPosition:Array = ((xml.@center).toString()).split(",");
			_center = new Point(centroidPosition[0], centroidPosition[1]);
			
			var pathXML:XMLList = xml.path;
			var currentPathXML:XML;
			for(var i:int = 0; i<pathXML.length(); i++)
			{
				currentPathXML = pathXML[i];
				switch(currentPathXML.@type.toString())
				{
					case "translate":
						translatePath.deserialize(currentPathXML.@points);
						break;
					
					case "rotate":
						rotatePath.deserialize(currentPathXML.@points);
						break;
					
					case "scale":
						scalePath.deserialize(currentPathXML.@points);
						break;
				}
			}
		}
	}
}
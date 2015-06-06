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
	import sg.edu.smu.ksketch2.utils.iterators.INumberIterator;
	
	/**
	 * The KSpatialKeyFrame class serves as the concrete class that defines the core
	 * implementations of spatial key frames in K-Sketch. Spatial key frames contain
	 * spatial data such as its paths and transformation center.
	 */
	public class KSpatialKeyFrame extends KKeyFrame implements ISpatialKeyFrame
	{
		// settings variables
		private var _isDirty:Boolean;			// the dirty status
		private var _center:Point;				// the transformation center
		private var _actualCenter:Point;		// the actual transformation center

		// path variables
		public var translatePath:KPath;
		public var rotatePath:KPath;
		public var scalePath:KPath;
		
		// paths used during transition
		// if they aren't cleared after transitions, an error will be thrown
		public var tempX:Number;
		public var tempY:Number;
		public var tempTheta:Number;
		public var tempSigma:Number;

		/**
		 * The main constructor for the KSpatialKeyFrame.
		 * 
		 * @param newTime The spatial key frame's time.
		 * @param center The spatial key frame's center position.
		 */
		public function KSpatialKeyFrame(newTime:Number, center:Point)
		{
			// set the spatial key frame's time
			super(newTime);
			
			if(center.x > 2000 || center.y > 2000)
			{
				trace("Center is large");
			}
			// initialize the main variables
			_isDirty = true;
			_center = center.clone();
			
			translatePath = new KPath(KPath.TRANSLATE);
			rotatePath = new KPath(KPath.ROTATE);
			scalePath = new KPath(KPath.SCALE);
			
			// initialize the temporary variables
			tempX = 0;
			tempY = 0;
			tempTheta = 0;
			tempSigma = 0;
		}
		
		/**
		 * Gets the total x (horizontal) translation difference for the spatial key frame.
		 * 
		 * @return The total horizontal translation difference.
		 */
		public function get dX():Number
		{
			if (2 <= translatePath.length) {
				return translatePath.points[translatePath.length -1].x - translatePath.points[0].x;			
			}
			else {
				return 0;
			}
		}
		
		/**
		 * Gets the total y (vertical) translation difference for the spatial key frame.
		 * 
		 * @return The total vertical translation difference.
		 */
		public function get dY():Number
		{
			if (2 <= translatePath.length) {
				return translatePath.points[translatePath.length -1].y - translatePath.points[0].y;			
			}
			else {
				return 0;
			}
		}
		
		/**
		 * Gets the total rotation difference for the spatial key frame.
		 * 
		 * @return The total rotaion difference.
		 */
		public function get dTheta():Number
		{
			if (2 <= rotatePath.length) {
				return rotatePath.points[rotatePath.length -1].x - rotatePath.points[0].x;			
			}
			else {
				return 0;
			}
		}
		
		/**
		 * Gets the total scale factor for the spatial key frame.
		 * 
		 * @return The total scale factor.
		 */
		public function get fSigma():Number
		{
			if (2 <= scalePath.length) {
				return scalePath.points[scalePath.length -1].x / scalePath.points[0].x;			
			}
			else {
				return 1;
			}
		}
		
		/**
		 * Dirties the key and all future keys, forcing recomputation of its matrix when it is required.
		 */
		public function dirtyKey():void
		{
			_isDirty = true;
			(next as KSpatialKeyFrame).dirtyKey();
		}
		
		/**
		 * Gets a clone of the key's transformation center.
		 * 
		 * @return A clone of the key's transformation center.
		 */
		public function get center():Point
		{
			return _center.clone();
		}
		
		
		/**
		 * Gets the spatial key's matrix, concatenated with matrices of previous keys at the given time.
		 * 
		 * @param time The target time.
		 * @return The spatial key's full matrix.
		 */
		public function fullMatrix(getTime:Number):Matrix
		{
			// get the matrix pair
			var pre:Array = getMatrixPair(getTime);
			
			// get the result matrix
			var result:Matrix = pre[1];
			
			// get the concatenated matrix
			result.concat(pre[0] as Matrix);
			
			// return the full matrix
			return result;
		}
		
		/**
		 * A temporary function with a stupid name for getting a pair of matrices
		 * [translation matrix, RS matrix] from the previous key frames.
		 * 
		 * @param getTime The target time.
		 * @return A pair of matrices from the previous key frames.
		 */
		public function getMatrixPair(getTime:Number):Array
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
		 * Gets the spatial key's matrix, concatenated with matrices of previous keys at the given time.
		 * Note: Contains duplicate code path from getPartial matrix, JT should really go and 
		 * clean this up if it works.
		 * 
		 * @param time The target time.
		 * @return The spatial key's full matrix.
		 */
		public function partialMatrix(getTime:Number):Matrix
		{
			getMatrixPair(startTime);

			var transforms:Array = _findTransforms(getTime);
			
			// create the matrix for this key frame
			var matrix:Matrix = new Matrix();
			matrix.translate(-_center.x, -_center.y);
			matrix.rotate(transforms[0]);
			matrix.scale(transforms[1],transforms[1]);
			matrix.translate(transforms[2], transforms[3]);
			matrix.translate(_center.x, _center.y);
			return matrix;
		}

		/**
		 * Returns an iterator that gives the times of all translate events, in order from beginning to end. 
		 * If this key frame has no previous key frame, returns null.
		 * 
		 * @return An iterator for all transate event times.
		 */
		public function translateTimeIterator():INumberIterator
		{
			return translatePath.timeIterator(_previous.time, _time);
		}
		
		/**
		 * Returns an iterator that gives the times of all rotate events, in order from beginning to end. 
		 * If this key frame has no previous key frame, returns null.
		 * 
		 * @return An iterator for all rotate event times.
		 */
		public function rotateTimeIterator():INumberIterator
		{
			return rotatePath.timeIterator(_previous.time, _time);
		}
		
		/**
		 * Returns an iterator that gives the times of all scale events, in order from beginning to end. 
		 * If this key frame has no previous key frame, returns null.
		 * 
		 * @return An iterator for all scale event times.
		 */
		public function scaleTimeIterator():INumberIterator
		{
			return scalePath.timeIterator(_previous.time, _time);
		}
		

		/**
		 * Find the transforms.
		 * 
		 * @param getTime The target time.
		 * @return The found transforms in an array of four Numbers: [rotation, scale, x translation, y translation].
		 */
		private function _findTransforms(getTime:Number):Array
		{
			if(getTime < startTime)
				return [0,1,0,0];
			
			var keyDuration:int = this.duration;
			
			var point:KTimedPoint;
			var theta:Number = 0;
			var sigma:Number = 1;
			var dx:Number = 0;
			var dy:Number = 0;
			
			// duration 0 happens on two cases
			// 1. key is really of 0 duration
			// 2. there is no previous key, which means it can only be the head key
			var proportion:Number;
			if(keyDuration == 0)
				proportion = 1;
			else
				proportion = Number((getTime-startTime)/keyDuration);
			
			// return the full path transform
			theta = tempTheta;
			point = rotatePath.find_Point(proportion, this);
			if(point)
				theta += point.x;
			
			sigma = 1+tempSigma;
			point = scalePath.find_Point(proportion, this);
			if(point)
				sigma += point.x;

			dx = tempX;
			dy = tempY;
			point = translatePath.find_Point(proportion, this);
			if(point)
			{
				dx += point.x;
				dy += point.y;
			}

			
			return [theta, sigma, dx, dy];
		}
		
		/**
		 * Checks if the key frame has a transition and returns true if so, else false.
		 * A transition is determined by having changes in its transformation over time.
		 * 
		 * @return If the key frame has a transition.
		 */
		override public function hasActivityAtTime():Boolean
		{
			return translatePath.length > 0 || rotatePath.length > 0 || scalePath.length > 0;
		}
		
		/**
		 * Gets a clone of the key frame.
		 * 
		 * @return A clone of the key frame.
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
		 * Splits the key frame into two parts -- a front key frame and a back key frame -- and returns the front key frame.
		 * 
		 * @param time The time of the split key frame.
		 * @param op The associated composite operation.
		 * @return The front key.
		 */
		override public function splitKey(atTime:Number, op:KCompositeOperation):IKeyFrame
		{	
			// handle the pre-split operation first
			// we are basically "removing" this key and adding 2 more keys, so a total of 3 key operations
			
			// find the proportion
			var proportion:Number = findProportion(Number(atTime));
			var frontKey:KSpatialKeyFrame = new KSpatialKeyFrame(atTime, center);
			var oldPath:KPath;
			
			oldPath = translatePath.clone();
			frontKey.translatePath = translatePath.splitPath(proportion, this);
			op.addOperation(new KReplacePathOperation(this, translatePath, oldPath, KSketch2.TRANSFORM_TRANSLATION));
				
			oldPath = rotatePath.clone();	
			frontKey.rotatePath = rotatePath.splitPath(proportion, this);
			op.addOperation(new KReplacePathOperation(this, rotatePath, oldPath, KSketch2.TRANSFORM_ROTATION));
			
			oldPath = scalePath.clone();	
			frontKey.scalePath = scalePath.splitPath(proportion, this);
			op.addOperation(new KReplacePathOperation(this, scalePath, oldPath, KSketch2.TRANSFORM_SCALE));
			
			frontKey.previous = previous;

			if(previous)
				(previous as KSpatialKeyFrame).next = frontKey;
			
			frontKey.next = this;
			previous = frontKey;
			
			// now we have 2 more keys
			// deal with teh 2 "inserted keys"
			op.addOperation(new KInsertKeyOperation(frontKey.previous, this, frontKey));
			
			return frontKey;
		}
		
		/**
		 * Checks for the spatial key frame's usefulness by whether the
		 * spatial key frame or its next one had any activity, and returns
		 * true if so, else false.
		 * 
		 * @return If the spatial key frame or its next one had any activity.
		 */
		override public function isUseful():Boolean
		{
			var hasTranslation:Boolean = true;
			var hasRotation:Boolean = true;
			var hasScale:Boolean = true;
			
			return (time != 0) && (hasActivityAtTime()||((next != null)&&next.hasActivityAtTime()));
		}
		
		/**
		 * Serializes the key frame to an XML object.
		 * 
		 * @return The serialized XML object of the key frame.
		 */
		override public function serialize():XML
		{
			var keyXML:XML = <spatialkey time="0" center="" passthrough=""/>;
			keyXML.@time = _time.toString();
			keyXML.@center = _center.x.toString()+","+_center.y.toString();
			keyXML.@passthrough = _passthrough.toString(); //Passthrough edit
			
			var pathXML:XML = translatePath.serialize();
			pathXML.@type = "translate";
			keyXML.appendChild(pathXML);
			
			pathXML = rotatePath.serialize();
			pathXML.@type = "rotate";
			keyXML.appendChild(pathXML);
			
			pathXML = scalePath.serialize();
			pathXML.@type = "scale2";
			keyXML.appendChild(pathXML);
			
			return keyXML;
		}
		
		/**
		 * Deserializes the XML object to a key frame.
		 * 
		 * @param xml The target XML object.
		 * @param params Optional state to be used in desearialization.
		 */
		override public function deserialize(xml:XML, params:Object = null):void
		{
			var centroidPosition:Array = ((xml.@center).toString()).split(",");
			_center = new Point(centroidPosition[0], centroidPosition[1]);
			var startScale:Number = 1;
			
			if (params) {
				startScale = Number(params);
			}
			
			//Passthrough edit
			var passthroughValue:String = (xml.@passthrough.toString());
			if(passthroughValue == null)
				_passthrough = false;
			else if (passthroughValue.indexOf("true") >= 0)
				_passthrough = true;
			else
				_passthrough = false;
			
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
						var length:int = scalePath.length;
						var points:Vector.<KTimedPoint> = scalePath.points;
						var x:Number;
						for(var j:int = 0; j<length; j++)
						{
							x = points[j].x;
							points[j].x = (x == 0) ? 1 : (startScale + x)/startScale;
						}
						break;
					
					case "scale2":
						scalePath.deserialize(currentPathXML.@points);
						break;
				}
			}
		}
	}
}
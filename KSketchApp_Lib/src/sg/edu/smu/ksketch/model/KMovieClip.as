/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.model
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class KMovieClip extends KObject
	{		
		public static var NUM_BOUNDING_POINTS:Number = 1;
		public var _cachedCenter:Point;
		private var _movieClip:MovieClip
		private var _movieClipPosition:Point
		
		public function KMovieClip(id:int, movieClip:MovieClip, xPos:Number, yPos:Number, createdTime:Number=0)
		{
			super(id, createdTime);
			_movieClip = movieClip;
			_movieClipPosition = new Point(xPos, yPos);
		}
		
		public function get movieClip():MovieClip
		{
			return _movieClip;
		}

		public function updateCenter():void
		{
			var rect:Rectangle = _movieClip ? new Rectangle(0,0,_movieClip.width, _movieClip.height): new Rectangle(0,0,0,0);
			_cachedCenter = new Point(rect.x+rect.width/2, rect.y + rect.height/2);
			_cachedCenter.x += _movieClipPosition.x;
			_cachedCenter.y += _movieClipPosition.y;
		}
		
		public override function get defaultCenter():Point
		{
			if(!_cachedCenter)
				updateCenter();
			return _cachedCenter.clone();			
		}
		
		public function get movieClipPosition():Point
		{
			return _movieClipPosition.clone();
		}
		
		public override function handleCenter(kskTime:Number):Point
		{
			return defaultCenter;
		}		
	}
}
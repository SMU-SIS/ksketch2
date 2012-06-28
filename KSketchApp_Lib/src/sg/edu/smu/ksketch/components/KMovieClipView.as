/**------------------------------------------------
 * Copyright 2012 Singapore Management University
 * All Rights Reserved
 *
 *-------------------------------------------------*/

package sg.edu.smu.ksketch.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KMovieClip;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KMovieClipView extends KObjectView
	{
		private var _movieClip:MovieClip;
		private var _glowFilter:GlowFilter;
		
		public function KMovieClipView(appState:KAppState, object:KMovieClip)
		{
			super(appState, object);			
			_movieClip = object.movieClip;
			addChild(_movieClip);
			_movieClip.x = object.movieClipPosition.x
			_movieClip.y = object.movieClipPosition.y;
			_glowFilter = new GlowFilter(0xff0000);
		}
		
		public override function set selected(selected:Boolean):void
		{
			if(selected)
				filters = [_glowFilter];
			else
				filters = [];
		}
	}
}
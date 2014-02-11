/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import com.google.analytics.AnalyticsTracker;
	import com.google.analytics.GATracker;
	
	import sg.edu.smu.ksketch2.canvas.components.view.KSketch_CanvasView;
	
	public class GoogleAnalytics
	{
		public var  tracker:AnalyticsTracker;
		private var _canvas:KSketch_CanvasView;
		
		public function init(canvas:KSketch_CanvasView):void
		{
			/**
			 * References the current display object, web property ID, tracking mode, and debug mode
			 */
			_canvas = canvas;
			tracker = new GATracker(_canvas, "UA-47832938-1", "AS3", false);
		}
		
	}//end of class
}
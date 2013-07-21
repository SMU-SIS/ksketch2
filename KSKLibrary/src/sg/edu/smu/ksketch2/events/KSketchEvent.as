/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.events
{
	import flash.events.Event;
	
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	
	/**
	 * The KSketchEvent class serves as the concrete class for denoting
	 * events to sketches in K-Sketch.
	 */
	public class KSketchEvent extends Event
	{
		/**
		 * The initialized K-Sketch event.
		 */
		public static const EVENT_KSKETCH_INIT:String = "KSketch Initialised";
		
		/**
		 * The updated model event.
		 */
		public static const EVENT_MODEL_UPDATED:String = "model updated"
			
		/**
		 * The changed stroke event.
		 */
		public static const EVENT_STROKE_POINT_CHANGED:String = "stroke changed";
		
		/**
		 * The new selection event.
		 */
		public static const EVENT_SELECTION_SET_CHANGED:String = "new selection";

		private var _root:KGroup;	// the root of the scene graph
		
		/**
		 * The main constructor of the KSketchEvent class.
		 * 
		 * @param type The event type.
		 * @param sceneRoot The root of the scene graph.
		 */
		public function KSketchEvent(type:String, sceneRoot:KGroup = null)
		{
			super(type);
			
			_root = sceneRoot;
		}
		
		/**
		 * Gets the root of the scene graph.
		 * 
		 * @return The root of the scene graph.
		 */
		public function get root():KGroup
		{
			return _root;
		}
	}
}
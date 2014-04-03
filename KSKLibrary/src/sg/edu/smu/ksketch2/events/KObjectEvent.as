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
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	/**
	 * The KObjectEvent class serves as the concrete class for denoting
	 * events to a KObject in K-Sketch.
	 */
	public class KObjectEvent extends Event
	{
		/**
		 * The finalized object transform state.
		 */
		public static const OBJECT_TRANSFORM_FINALISED:String = "Transform Finalised"
		
		/**
		 * The changed object transform state.
		 */
		public static const OBJECT_TRANSFORM_CHANGED:String = "Transform Changed";
		
		/**
		 * The changed object selection state.
		 */
		public static const OBJECT_SELECTION_CHANGED:String = "Selection Changed";
		
		/**
		 * The changed object visibility state.
		 */
		public static const OBJECT_VISIBILITY_CHANGED:String = "Visibility Changed";
		
		/**
		 * The started object transform state.
		 */
		public static const OBJECT_TRANSFORM_BEGIN:String = "Transform Begin";
		
		/**
		 * The updated object transform state.
		 */
		public static const OBJECT_TRANSFORM_UPDATING:String = "Transform Updating";
		
		/**
		 * The ended object transform state.
		 */
		public static const OBJECT_TRANSFORM_ENDED:String = "Transform Ended";
		
		private var _targetObject:KObject;		// the target object
		private var _parent:KGroup;				// the object's parent
		private var _time:Number;					// the object's time
		
		/**
		 * The main constructor for the KObjectEvent class.
		 * 
		 * @param type The event type.
		 * @param targetObject The target object.
		 * @param eventTime The event's time.
		 */
		public function KObjectEvent(type:String, targetObject:KObject, eventTime:Number)
		{
			super(type);
			_targetObject = targetObject;
			_parent = targetObject.parent;
			_time = eventTime;
		}
		
		/**
		 * Gets the target object.
		 * 
		 * @return The target object.
		 */
		public function get object():KObject
		{
			return _targetObject;
		}
		
		/**
		 * Gets the object's parent.
		 * 
		 * @return The object's parent.
		 * 
		 */
		public function get parent():KGroup
		{
			return _parent;
		}
		
		/**
		 * Gets the object's time.
		 * 
		 * @return The object's time.
		 */
		public function get time():Number
		{
			return _time;
		}
	}
}
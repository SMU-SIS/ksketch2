/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.operators
{
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.IVisibilityKey;
	import sg.edu.smu.ksketch2.model.data_structures.KVisibilityKey;
	import sg.edu.smu.ksketch2.model.data_structures.KVisibilityKeyList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.operators.operations.KInsertKeyOperation;
	import sg.edu.smu.ksketch2.operators.operations.KParentChangeOperation;
	import sg.edu.smu.ksketch2.operators.operations.KVisibilityChangedOperation;

	/**
	 * The KVisibilityControl class serves as the concrete class for visibility
	 * control in K-Sketch. Specifically, the transform operator for visibility
	 * key frames.
	 */
	public class KVisibilityControl implements IVisibilityControl
	{
		// static constants
		public static const VISIBLE_ALPHA:Number = 1;
		public static const GHOST_ALPHA:Number = 0.2;
		public static const INVISIBLE_ALPHA:Number = 0;
		
		public static const STUDYMODE_K:int = 0;						// Version K value
		public static const STUDYMODE_P:int = 1;						// Version P value
		public static const STUDYMODE_KP:int = 2;						// Version KP value
		public static const STUDYMODE_KP2:int = 3;							// Version KP2 value
		public static var studyMode:int = STUDYMODE_KP2;
		
		// class variables
		private var _object:KObject;						// the object
		private var _visibilityKeys:KVisibilityKeyList;		// the visibility key frame list
		
		/**
		 * The main constructor for the KVisibilityControl class.
		 * 
		 * @param object The target object.
		 */
		public function KVisibilityControl(object:KObject)
		{
			// set the object
			_object = object;
			
			// initialize the set of visibility key frames
			_visibilityKeys = new KVisibilityKeyList();
			//setVisibility(false, 0, null);
			
		}
		
		public function get earliestVisibleTime():Number
		{
			// set the current key frame as the head of the visibility key frame list
			var currentKey:IKeyFrame = _visibilityKeys.head;
			
			// iterate through each non-completely visible key frame
			while(!(currentKey as IVisibilityKey).visible)
			{
				currentKey = currentKey.next;
			}
			
			// return the time of the first completely visible key frame
			return currentKey.time;
		}
		
		public function setVisibility(visible:Boolean, time:Number, op:KCompositeOperation, clearKey:Boolean):void
		{
			// look for the relevant key frame at the given time first
			var key:IVisibilityKey = _visibilityKeys.getActiveKey(time);
			
			// case: the key frame exists
			if(key)
			{				
				if(!clearKey)
				{
					if(time  == _object.transformInterface.firstKeyTime)
					{
						op.addOperation(new KParentChangeOperation(_object, null, _object.parent));
						_object.parent = null;
						return;
					}
					
					if(key.visible == visible)
						return;
				}
				
				if(key.time == time)
				{	
					var afterKey:IKeyFrame = _visibilityKeys.getKeyAftertime(time);
					if(afterKey)
						_visibilityKeys.removeKeyFrame(afterKey);
					
					if(op)
						op.addOperation(new KVisibilityChangedOperation(key, key.visible, visible));
					
					key.visible = visible;
					_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_VISIBILITY_CHANGED, _object, time));
					return;
				}
			}
			
			var passthrough:Boolean;
			if(studyMode == STUDYMODE_K || studyMode == STUDYMODE_KP)
				passthrough = false;
			else
				passthrough = true;
			
			key = new KVisibilityKey(time,passthrough);
			_visibilityKeys.insertKey(key);
			if(op)
				op.addOperation(new KInsertKeyOperation(key.previous, key.next, key));
			
			//Set the visibility at the give time
			key.visible = visible;
			if(op)
				op.addOperation(new KVisibilityChangedOperation(key, false, visible));
			
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_VISIBILITY_CHANGED, _object, time));
		}
		
		public function serializeVisibility():XML
		{
			var visibilityXML:XML = <Activity/>;
			visibilityXML.appendChild(_visibilityKeys.serialize());
			
			return visibilityXML;
		}
		
		public function deserializeVisibility(xml:XML):void
		{
			_visibilityKeys = new KVisibilityKeyList();
			var keyXML:XMLList = xml.keylist.visibilitykey
			for(var i:int = 0; i<keyXML.length(); i++)
			{
				//Passthrough edit
				var passthrough:Boolean;
				if(studyMode == STUDYMODE_K || studyMode == STUDYMODE_KP)
					passthrough = false;
				else
					passthrough = true;
				
				var newVisibilityKey:KVisibilityKey = new KVisibilityKey(new Number(keyXML[i].@time),passthrough);
				
				if(keyXML[i].@visibility == "true")
					newVisibilityKey.visible = true;
				else
					newVisibilityKey.visible = false;
				_visibilityKeys.insertKey(newVisibilityKey);
			}
		}
		
		public function alpha(time:Number):Number
		{
			// get the activity visibility key frame at the given time
			var key:IVisibilityKey = _visibilityKeys.getActiveKey(time);
			
			// case: the key frame exists
			if(key)
			{
				// case: the key frame has a visibile state
				// return a visible alpha value
				if(key.visible)
					return VISIBLE_ALPHA;
				else
				{
					// case: the key frame's time matches the given time
					// return a ghost visible alpha value
					if(key.time == time)
						return GHOST_ALPHA;
					
					// case: the key frame lacks both a visibile state and matching time
					// return an invisible alpha value
					else
						return INVISIBLE_ALPHA;
				}
			}
			// the visibility key doesn't exist
			// return an invisible alpha value
			else
				return INVISIBLE_ALPHA;
		}
		
		/**
		 * Gets the visibility key frame at the head of the visibility key frame list.
		 * 
		 * @return The visibility key frame at the head of the visibility key frame list.
		 */
		public function get visibilityKeyHeader():IKeyFrame
		{
			return _visibilityKeys.head;
		}
		
		/**
		 * Gets a clone of the visibility control.
		 * 
		 * @return A clone of the visibility control.
		 */
		public function clone():IVisibilityControl
		{
			var newVisibilityControl:KVisibilityControl = new KVisibilityControl(_object);
			var clonedKeys:KVisibilityKeyList = _visibilityKeys.clone() as KVisibilityKeyList;
			
			newVisibilityControl._visibilityKeys = clonedKeys;
			
			return newVisibilityControl;
		}
	}
}
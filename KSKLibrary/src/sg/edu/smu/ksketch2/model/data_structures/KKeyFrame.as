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
	import flash.utils.getQualifiedClassName;
	
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.operators.operations.KRemoveKeyOperation;
	
	/**
	 * The KKeyFrame class serves as the abstract class that defines the core
	 * implementations of key frames in K-Sketch. Do not instantiate this class
	 * by itself.
	 */
	public class KKeyFrame implements IKeyFrame
	{
		protected var _owner:int;				// the owner ID of the key frame
		protected var _previous:KKeyFrame;		// the previous key frame
		protected var _next:KKeyFrame;			// the next key frame
		protected var _time:int;				// the key frame's time
		
		/**
		 * The main constructor for the KKeyFrame object. Do not instantiate this
		 * class by itself.
		 * 
		 * @param newTime The key frame's new time.
		 */
		public function KKeyFrame(newTime:int)
		{
			time = newTime;
		}
		
		/**
		 * Gets the key frame's owner ID.
		 * 
		 * @return The key frame's owner ID.
		 */
		public function get ownerID():int
		{
			return _owner;
		}

		/**
		 * Sets the key frame's owner ID.
		 * 
		 * @param value The key frame's owner ID.
		 */
		public function set ownerID(value:int):void
		{
			_owner = value;
		}

		/**
		 * Gets the previous key frame in the linked list.
		 * 
		 * @return The previous key frame.
		 */
		public function get previous():IKeyFrame
		{
			return _previous;
		}
		
		/**
		 * Sets the previous key frame in the linked list.
		 * 
		 * @param key The previous key frame.
		 */
		public function set previous(key:IKeyFrame):void
		{
			if(key)
			{
				if( _time <= key.time)
				{
					trace("Given key.time:",key.time, "this key's time:", _time);
					throw new Error("KKeyFrame set previous: the previous key should have a time value that is smaller than this key");
				}
			}
			
			_previous = key as KKeyFrame
		}
		
		/**
		 * Gets the next key frame in the linked list.
		 * 
		 * @return The next key frame.
		 */
		public function get next():IKeyFrame
		{
			return _next;
		}
		
		/**
		 * Sets the next key frame in the linked list.
		 * 
		 * @return The next key frame.
		 */
		public function set next(key:IKeyFrame):void
		{
			if(key)
			{
				if(key.time <= _time)
				{
					trace("Given key.time:",key.time, "this key's time:", _time);
					throw new Error("KKeyFrame set next: the next key should have a time value that is greater than this key");
				}
			}
			
			_next = key as KKeyFrame;
		}
		
		/**
		 * Gets the time at which the key frame is defined. Time must be strictly
		 * greater than previous.time, and strictly smaller than next.time.
		 * 
		 * @return The key frame's current time.
		 */
		public function get time():int
		{
			return _time;
		}
		
		/**
		 * Sets the time at which the key frame is defined. Time must be strictly
		 * greater than previous.time, and strictly smaller than next.time.
		 * 
		 * @param newTime The key frame's current time.
		 */
		public function set time(newTime:int):void
		{
			// do a logic check with previous key frame's time
			if(previous)
			{
				if(newTime <= previous.time)
				{
					trace("Warning: The previous key has a time value greater than the new time: Previous Key Time:",previous.time, "new time:", newTime);
				}
			}
			
			// do a logic check with next key frame's time
			if(next)
			{
				if(next.time <= newTime)
				{
					trace("Warning: THe next Key has a time value smaller than the new time: Next Key Time:",next.time, "new time:", newTime);
				}
			}
			
			// set the key frame's new time
			_time = newTime;
		}
		
		/**
		 * Retimes the key frame by setting it with the new time.  Also handles special cases if the new time
		 * conflicts with the previous key frame.
		 * 
		 * @param newTime The new target time.
		 * @param op The associated composite operation.
		 */
		public function retime(newTime:int, op:KCompositeOperation):void
		{
			// case: a previous key frame exists
			if(_previous)
			{
				// case: the target new time occurred before the previous key frame's time
				if(newTime <= _previous.time)
				{
					// case: there is no activity at the time of this key frame
					if(!hasActivityAtTime())
					{
						// set the previous key frame's next key frame to this key frame's next key frame
						_previous.next = _next;

						// case: a next frame exists
						if(_next)
						{
							// set the next key frame's previous key frame to this key frame's previous key frame
							_next.previous = _previous;
						}
						
						// case: a composite operation exists
						if(op)
						{
							// append the new composite operation
							op.addOperation(new KRemoveKeyOperation(_previous, _next, this));
						}
						
						_previous = null;
						_next = null;
					}
					
					// case: there is activity at the time of this key frame
					else
					{
						throw new Error("Erroneous retiming of key frame. The widget allowed the key's host marker to stack when this key has activities");
				
					}
				}
			}
			
			// set the key frame's new time
			time = newTime;
		}
		
		/**
		 * Checks if the key frame has a transition and returns true if so, else false.
		 * A transition is determined by having changes in its transformation over time.
		 * 
		 * @return If the key frame has a transition.
		 */
		public function hasActivityAtTime():Boolean
		{
			throw new Error("KKeyFrame is an abstract class. Don't call hasActivityAtTime thru KKeyFrame");
			return false;
		}
		
		/**
		 * Gets a clone of the key frame.
		 * 
		 * @return A clone of the key frame.
		 */
		public function clone():IKeyFrame
		{
			throw new Error("KKeyFrame is an abstract class. Don't call clone thru KKeyFrame");
			return null;
		}
		
		/**
		 * Splits this key into two parts: a front key frame and a back key frame. Then it returns the front key frame.
		 *
		 * @param time The time of the split key frame.
		 * @param op The associated composite operation.
		 * @return The front key.
		 */
		public function splitKey(time:int, op:KCompositeOperation):IKeyFrame
		{
			return null;
		}
		
		/**
		 * Gets the key frame's start time.
		 * 
		 * @return startTime The key frame's start time.
		 */
		public function get startTime():int
		{
			// case: the key frame has a previous key frame
			if(previous)
			{
				// get the previous key frame's time
				return previous.time;
			}
			// case: the key frame is the head key frame
			else
			{
				// return this key frame's time
				return time;
			}
		}
		
		/**
		 * Gets the duration of the key frame.
		 * 
		 * @return The duration of the key frame.
		 */
		public function get duration():int
		{
			// case: the key frame has a previous key frame
			if(previous)
			{
				// gets the duration of the key frame by calculating the difference with the previous key frame's time
				return time - previous.time;
			}
			// case: the key frame is the head key frame
			else
			{
				// assume that this is the head key, always duration = 0
				return 0;
			}
		}
		
		/**
		 * Gets the target time's proportion within the time of the entire key frames.
		 * 
		 * @param atTime The target time.
		 * @return The target time's proportion within the time of the entire key frames.
		 */
		public function findProportion(atTime:Number):Number
		{
			// case: the target time is at least equal to the final time
			if(time <= atTime)
				return 1;
			
			// case: the target time is at most equal to the beginning time
			if(atTime <= startTime)
				return 0;
			
			var timeElapsed:Number = (atTime-startTime);	// calculate the elapsed time
			var duration:Number = time - startTime;			// calculate the duration time
			var proportionKeyframe:Number;					// initialize the proportion value

			// case: zero-length duration time
			if(duration == 0)
				proportionKeyframe = 1;
			// case: non-zero-length duration time
			else
				proportionKeyframe = timeElapsed/duration;
			
			// return the proportion value
			return proportionKeyframe;
		}
		
		/**
		 * Checks the usefulness of the key frame.
		 * 
		 * @return Whether the key frame is useful.
		 */
		public function isUseful():Boolean
		{
			return true;
		}
		
		/**
		 * Serializes the key frame to an XML object.
		 * 
		 * @return The serialized XML object of the key frame.
		 */
		public function serialize():XML
		{
			var keyXML:XML = <key type="default" time="0"/>;
			keyXML.@time = _time.toString();
			return keyXML;
		}
		
		/**
		 * Deserializes the XML object to a key frame.
		 * 
		 * @param xml The target XML object.
		 */
		public function deserialize(xml:XML):void
		{
			
		}
	}
}
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
	
	public class KKeyFrame implements IKeyFrame
	{
		protected var _owner:int;
		protected var _previous:KKeyFrame;
		protected var _next:KKeyFrame;
		protected var _time:int;
		
		/**
		 * KKeyFrame is the abstract class that defines the core implementations of key frames
		 * Do not instantiate this class by itself
		 */
		public function KKeyFrame(newTime:int)
		{
			time = newTime;
		}
		
		public function get ownerID():int
		{
			return _owner;
		}

		public function set ownerID(value:int):void
		{
			_owner = value;
		}

		/**
		 * Key that is before this KKeyFrame in its key frame linked list
		 */
		public function get previous():IKeyFrame
		{
			return _previous;
		}
		
		/**
		 * Key that is before this KKeyFrame in its key frame linked list
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
		 * Key that is after this KKeyFrame in its key frame linked list
		 */
		public function get next():IKeyFrame
		{
			return _next;
		}
		
		/**
		 * Key that is after this KKeyFrame in its key frame linked list
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
		 * Time position of this KKeyFrame.
		 * Time must strictly be greater than previous.time
		 * Time must also be strictly smaller than next.time
		 */
		public function get time():int
		{
			return _time;
		}
		
		/**
		 * Time position of this KKeyFrame.
		 * Time must strictly be greater than previous.time
		 * Time must also be strictly smaller than next.time
		 */
		public function set time(newTime:int):void
		{
			if(previous)
			{
				if(newTime <= previous.time)
				{
					trace("Warning: The previous key has a time value greater than the new time: Previous Key Time:",previous.time, "new time:", newTime);
				}
			}
			
			if(next)
			{
				if(next.time <= newTime)
				{
					trace("Warning: THe next Key has a time value smaller than the new time: Next Key Time:",next.time, "new time:", newTime);
				}
			}
			
			_time = newTime;
		}
		
		public function retime(newTime:int, op:KCompositeOperation):void
		{
			if(_previous)
			{
				if(newTime <= _previous.time)
				{
					if(!hasActivityAtTime())
					{
						_previous.next = _next;

						if(_next)
							_next.previous = _previous;
						
						if(op)
							op.addOperation(new KRemoveKeyOperation(_previous, _next, this));
						_previous = null;
						_next = null;
					}
					else
						throw new Error("Erroneous retiming of key frame. The widget allowed the key's host marker to stack when this key has activities");
				}
			}
			
			time = newTime;
		}
		
		public function hasActivityAtTime():Boolean
		{
			throw new Error("KKeyFrame is an abstract class. Don't call hasActivityAtTime thru KKeyFrame");
			return false;
		}
		
		public function clone():IKeyFrame
		{
			throw new Error("KKeyFrame is an abstract class. Don't call clone thru KKeyFrame");
			return null;
		}
		
		public function splitKey(time:int, op:KCompositeOperation):IKeyFrame
		{
			return null;
		}
		
		public function get startTime():int
		{
			if(previous)
				return previous.time;
			else
				return time;
		}
		
		public function get duration():int
		{
			if(previous)
				return time - previous.time;
			else
				return 0; // Assume that this is the head key, always duration = 0;
		}
		
		public function findProportion(atTime:Number):Number
		{
			if(time <= atTime)
				return 1;
			
			var timeElapsed:Number = (atTime-startTime);
			var duration:Number = time - startTime;
			var proportionKeyframe:Number;


			if(duration == 0)
				proportionKeyframe = 1;
			else
				proportionKeyframe = timeElapsed/duration;
			
			return proportionKeyframe;
		}
		
		public function isUseful():Boolean
		{
			return true;
		}
		
		public function serialize():XML
		{
			var keyXML:XML = <key type="default" time="0"/>;
			keyXML.@time = _time.toString();
			return keyXML;
		}
		
		public function deserialize(xml:XML):void
		{
			
		}
	}
}
/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model.geom
{
	import flash.geom.Point;
	
	public class KPathPoint extends Point
	{
		private var _time:Number;
		private var _type:int;
		
		/**
		 * Constructor.
		 * @param time Time of the KPathPoint.
		 * @param x X coordinate of the KPathPoint.
		 * @param y Y coordinate of the KPathPoint.
		 */		
		public function KPathPoint(x:Number=0, y:Number=0,time:Number=0, type:int=0)
		{
			super(x, y);
			_time = time;
			_type = type;
		}
		
		/**
		 * The time of the KPathPoint.
		 */		
		public function get time():Number
		{
			return _time;
		}
		public function set time(value:Number):void
		{
			_time = value;
		}

		public function get type():int
		{
			return _type;
		}

		public function set type(value:int):void
		{
			_type = value;
		}
		
		override public function clone():Point
		{
			return new KPathPoint(x,y,time,type);
		}
		

	}
}
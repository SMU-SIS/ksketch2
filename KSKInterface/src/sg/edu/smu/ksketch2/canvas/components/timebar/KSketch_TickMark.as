/**
 * Copyright 2010-2015 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.timebar
{
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;

	public class KSketch_TickMark
	{
		//Spatial variables used to compute this tick mark's position
		public var x:Number;
		public var originalPosition:Number;
		
		//Time value FOR THIS TICK ONLY. Changing this time does not change the key frame's time directly
		public var time:Number;

		//Variables to reference model's objects
		public var key:IKeyFrame;
		public var selected:Boolean;
		public var associatedObjectID:int;

		//Prev and next tick mark in the time line
		public var prev:KSketch_TickMark;
		public var next:KSketch_TickMark;

		public function KSketch_TickMark()
		{
			
		}
		
		
		//Hooks up the tick mark to model references
		public function init(refKey:IKeyFrame, initialXPos:Number, ownerID:int):void
		{
			key = refKey;
			associatedObjectID = ownerID;
			time = key.time;
			x = initialXPos;
		}
		
		/**
		 * Moves this time tick as close to the given position as possible
		 * The time tick's range of possible position will be from 
		 * +1 frame from prev to max container width or -1 frame from next
		 */
		public function moveToX(xPos:Number, pixelPerFrame:Number):void
		{
			if(xPos < 0)
				xPos = 0;
			
			if(prev)
			{
				if(xPos < (prev.x + pixelPerFrame))
					xPos = prev.x + pixelPerFrame;
			}
			else if(next)
			{
				if(xPos > (next.x - pixelPerFrame))
					xPos = next.x - pixelPerFrame;
			}

			x = xPos
		}
		
		/**
		 * Move self to xPos and next ticks by xpos - original position
		 */
		public function moveSelfAndNext(xPos:Number, pixelPerFrame:Number):void
		{
			var dx:Number = xPos - originalPosition;

			if(next)
				next.moveSelfAndNext(next.originalPosition+dx, pixelPerFrame);
			
			moveToX(xPos, pixelPerFrame);
		}
	}
}
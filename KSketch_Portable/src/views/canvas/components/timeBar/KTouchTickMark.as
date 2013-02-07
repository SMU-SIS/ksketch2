package views.canvas.components.timeBar
{
	import sg.edu.smu.ksketch2.controls.widgets.timewidget.KMarkerActivityBar;
	import sg.edu.smu.ksketch2.controls.widgets.timewidget.KTimeMarker;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.ISpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.IVisibilityKey;

	public class KTouchTickMark
	{
		public var x:Number;
		public var changeX:Number;

		public var originalPosition:Number;
		
		public var key:IKeyFrame;
		public var associatedObject:int;
		public var time:int;
		public var prev:KTouchTickMark;
		public var next:KTouchTickMark;
		public var prevAssociated:KTouchTickMark;
		public var nextAssociated:KTouchTickMark;
		
		public function KTouchTickMark()
		{
			
		}
		
		public function updateAssociation():void
		{
			var prevMarker:KTouchTickMark = prev;
			
			while(prevMarker)
			{
				if(!prevMarker.canStackWith(this))
				{
					prevAssociated = prevMarker;
					prevMarker.nextAssociated = this;
					prevMarker = null;
				}
				else
					prevMarker = prevMarker.prev;
			}
		}
		
		public function canStackWith(toStackMarker:KTouchTickMark):Boolean
		{			
			var toStackKey:IKeyFrame = toStackMarker.key;
			
			if(associatedObject != toStackMarker.associatedObject)
				return true;
			
			if(key is IVisibilityKey && toStackKey is ISpatialKeyFrame)
				return true;
			
			if(key is ISpatialKeyFrame && toStackKey is IVisibilityKey)
				return true;
			
			if(key is ISpatialKeyFrame && toStackKey is ISpatialKeyFrame)
				return !(toStackKey as ISpatialKeyFrame).hasActivityAtTime();
			
			return false;
		}
		
		public function moveFutureMarkers(dX:Number):void
		{
			if(next)
			{
				var nextX:Number = next.originalPosition + dX;
				next.updateX(nextX);
				next.moveFutureMarkers(dX);
			}
		}
		
		public function updateX(xPos:Number):void
		{
			x = xPos;
		}
		
		/**
		 * Move marker to toXPos, taking into considerations its collisions with markers in front of it
		 */
		public function moveWithStacking(toXPos:Number, pixelPerFrame:Number):void
		{
			//If there is no prev, prev associated should not exist!
			if(prev)
			{
				//Handle the prev first
				//If prev is not associated, then we stack prev and this
				//If prev is associated then we dont do anything first
				if((toXPos-1) <= prev.originalPosition)
				{
					if(prev != prevAssociated)
						prev.moveWithStacking(toXPos, pixelPerFrame);
				}
				
				//Then we handle the bunching case
				if(prevAssociated)
				{
					if((toXPos-1) <= prevAssociated.originalPosition)
					{
						var prevX:Number = toXPos - pixelPerFrame;
						
						if(prevX <= 0)
							prevX = 0;
						
						prevAssociated.moveWithStacking(prevX, pixelPerFrame);
						toXPos = prevAssociated.x + pixelPerFrame;
					}
				}
			}
			
			updateX(toXPos);
		}
	}
}
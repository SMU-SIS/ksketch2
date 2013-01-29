package views.custom
{
	import mx.core.ILayoutElement;	
	import spark.layouts.supportClasses.LayoutBase;
	
	public class MenuLayout extends LayoutBase
	{
		public function MenuLayout():void
		{
			super();
		}
		
		override public function updateDisplayList(scnWidth:Number, scnHeight:Number):void
		{
			super.updateDisplayList(scnWidth, scnHeight);
			
			if(!target)
				return;
			
			const btnWidth:uint = 125;
			const btnHeight:uint = 50;
			
			var layoutElement:ILayoutElement;
			var eleCount:uint = target.numElements;
			var angleDeg:Number = 360/(eleCount - 1);
			var centerX : Number = (target.width - btnWidth)/2;
			var centerY : Number = (target.height - btnHeight)/2;
			var radius:Number = 0.9*Math.min(centerX, centerY);
			var backBtnRadius:Number = 0.8*radius;
			
			//Layout Back Button
			//Assumption: Back Button is passed in as first element
			layoutElement = target.getElementAt(0);
			layoutElement.setLayoutBoundsPosition((target.width - backBtnRadius)/2, (target.height - backBtnRadius)/2);
			layoutElement.setLayoutBoundsSize(backBtnRadius, backBtnRadius);
			
			//Layout other buttons
			for(var i:int=1; i<(eleCount); i++)
			{
				layoutElement = target.getElementAt(i);
				
				if(!layoutElement || !layoutElement.includeInLayout)
					continue;
				
				var radAngle : Number = (angleDeg * i) * (Math.PI / 180) ;
				var _x : Number = Math.sin( radAngle );
				var _y : Number = - Math.cos( radAngle );
				var xCoord:int = centerX + (_x * radius);
				var yCoord:int = centerY + (_y * radius);
				
				layoutElement.setLayoutBoundsPosition(xCoord, yCoord);
				layoutElement.setLayoutBoundsSize(100,50);
			}
		}
	}
}
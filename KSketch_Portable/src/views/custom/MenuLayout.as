package views.custom
{
	import mx.core.ILayoutElement;
	import spark.components.Button;
	import spark.components.Label;
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
			
			const btnWidth:uint = 120;
			const btnHeight:uint = 60;
			
			var layoutElement:ILayoutElement = target.getElementAt(0);
			var eleCount:uint = target.numElements;
			var angleDeg:Number = 360/(eleCount - 2);
			var centerX:Number = (scnWidth - btnWidth)/2;
			var centerY:Number = (scnHeight - btnHeight)/2;
			var radius:Number = 0.8*Math.min(centerX, centerY);
			var backBtnRadius:Number = 0.6*radius;
			var labelWidth:Number = layoutElement.getPreferredBoundsWidth();
			var labelHeight:Number = layoutElement.getPreferredBoundsHeight();
			
			//Layout Menu label
			//Assumption: Menu Label is passed in as first element
			layoutElement.setLayoutBoundsPosition((scnWidth - labelWidth)/2, (0.99*scnHeight - labelHeight));
			layoutElement.setLayoutBoundsSize(labelWidth, labelHeight);
			(layoutElement as Label).setStyle("fontSize", 0.1*scnHeight);
			
			//Layout Back button
			//Assumption: Back Button is passed in as second element
			layoutElement = target.getElementAt(1);
			layoutElement.setLayoutBoundsPosition((scnWidth - backBtnRadius)/2, (scnHeight - backBtnRadius)/2);
			layoutElement.setLayoutBoundsSize(backBtnRadius, backBtnRadius);
			(layoutElement as Button).setStyle("fontSize", 0.05*scnHeight);

			
			//Layout other buttons
			for(var i:int=2; i<(eleCount); i++)
			{
				layoutElement = target.getElementAt(i);
				
				if(!layoutElement || !layoutElement.includeInLayout)
					continue;
				
				var radAngle:Number = (angleDeg*(i - 2))*(Math.PI/180) ;
				var _x:Number = Math.sin(radAngle);
				var _y:Number = - Math.cos(radAngle);
				var xCoord:int = centerX + (_x*radius);
				var yCoord:int = centerY + (_y*radius);
				
				layoutElement.setLayoutBoundsPosition(xCoord, yCoord);
				layoutElement.setLayoutBoundsSize(btnWidth, btnHeight);
				(layoutElement as Button).setStyle("fontSize", 25);
			}
		}
	}
}
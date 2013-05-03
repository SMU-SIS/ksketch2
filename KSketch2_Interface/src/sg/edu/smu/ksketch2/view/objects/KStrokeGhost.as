package sg.edu.smu.ksketch2.view.objects
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class KStrokeGhost extends Sprite
	{
		public function KStrokeGhost(strokePoints:Vector.<Point>, color:uint, thickness:Number)
		{
			super();
			
			if(strokePoints)
			{
				if(strokePoints.length > 0)
				{
					graphics.lineStyle(thickness, color);
					graphics.moveTo(strokePoints[0].x, strokePoints[0].y);
					
					for(var i:int = 1; i< strokePoints.length; i++)
						graphics.lineTo(strokePoints[i].x, strokePoints[i].y);
				}
			}
			
			alpha = KObjectView.GHOST_ALPHA;
		}
	}
}
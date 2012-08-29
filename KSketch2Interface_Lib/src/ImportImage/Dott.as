package ImportImage
{
	import flash.display.*;
	import flash.events.MouseEvent;

	public class Dott extends Sprite 
	{	
		public var shape:Shape = new Shape();
		
		public function Dott() 
		{			
			shape.graphics.beginFill( 0xFF0000 );
			shape.graphics.drawCircle( 0, 0, 5 );			
			shape.graphics.endFill();
			shape.graphics.beginFill( 0x00FF00 );
			shape.graphics.drawCircle( 0, 0, 3 );
			shape.graphics.endFill();
			shape.x = 0;
			shape.y = 0;			
	     	addChild(shape);										
			setChildIndex( shape, 0 );
			this.doubleClickEnabled=true;
		}
			
	}
		
}
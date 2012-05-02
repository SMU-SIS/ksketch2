/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.utilities
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;

	public class KQuadTreeObject
	{
		public var bounds:Rectangle;
		public var level:int;
		
		public var topLeft:Rectangle;
		public var topLeftObjects:Vector.<DisplayObject>;
		public var topLeftOctTree:KQuadTreeObject;
		
		public var topRight:Rectangle;
		public var topRightObjects:Vector.<DisplayObject>;
		public var topRightOctTree:KQuadTreeObject;
		
		public var bottomLeft:Rectangle;
		public var bottomLeftObjects:Vector.<DisplayObject>;
		public var bottomLeftOctTree:KQuadTreeObject;
		
		public var bottomRight:Rectangle;
		public var bottomRightObjects:Vector.<DisplayObject>;
		public var bottomRightOctTree:KQuadTreeObject;
		
		public function KQuadTreeObject(objects:Vector.<DisplayObject> ,
										coordinateSpace:DisplayObjectContainer,
									    givenBounds:Rectangle, assignedLevel:int = 0)
		{
			bounds = givenBounds;
			level = assignedLevel;
			
			var halfWidth:Number = bounds.width/2;
			var halfHeight:Number = bounds.height/2;
			var midX:Number = bounds.x+halfWidth;
			var midY:Number = bounds.y+halfHeight;
			
			topLeft = new Rectangle(bounds.x, bounds.y, halfWidth, halfHeight);
			topRight = new Rectangle(midX, bounds.y, halfWidth, halfHeight);
			bottomLeft = new Rectangle(bounds.x, midY, halfWidth, halfHeight);
			bottomRight = new Rectangle(midX, midY, halfWidth, halfHeight);
			
			topLeftObjects = new Vector.<DisplayObject>();
			topRightObjects = new Vector.<DisplayObject>();
			bottomLeftObjects = new Vector.<DisplayObject>();
			bottomRightObjects = new Vector.<DisplayObject>();
			
			var objBounds:Rectangle;
			
			for each(var obj:DisplayObject in objects)
			{
				objBounds = obj.getBounds(coordinateSpace);
				if(objBounds.intersects(topLeft))
					topLeftObjects.push(obj);
				if(objBounds.intersects(topRight))
					topRightObjects.push(obj);
				if(objBounds.intersects(bottomLeft))
					bottomLeftObjects.push(obj);
				if(objBounds.intersects(bottomRight))
					bottomRightObjects.push(obj);
			}
			if(0 < level)
			{
				topLeftOctTree = new KQuadTreeObject(topLeftObjects, coordinateSpace, topLeft, level -1);
				topRightOctTree = new KQuadTreeObject(topRightObjects, coordinateSpace, topRight, level -1);
				bottomLeftOctTree = new KQuadTreeObject(bottomLeftObjects, coordinateSpace, bottomLeft, level -1);
				bottomRightOctTree = new KQuadTreeObject(bottomRightObjects, coordinateSpace, bottomRight, level -1);
			}
		}
		
		public function detectPoint(x:Number, y:Number):Vector.<DisplayObject>
		{
			if(level == 0)
			{
				if(!bounds.contains(x,y))
				{
					return new Vector.<DisplayObject>();
				}
				if(topLeft.contains(x,y))
					return topLeftObjects;
				
				if(topRight.contains(x,y))
					return topRightObjects;
				
				if(bottomLeft.contains(x,y))
					return bottomLeftObjects;
				
				if(bottomRight.contains(x,y))
					return bottomRightObjects;
				
				return new Vector.<DisplayObject>();
			}
			else
			{
				if(!bounds.contains(x,y))
				{
					return new Vector.<DisplayObject>();
				}
				if(topLeft.contains(x,y))
					return topLeftOctTree.detectPoint(x,y);
				
				if(topRight.contains(x,y))
					return topRightOctTree.detectPoint(x,y);
				
				if(bottomLeft.contains(x,y))
					return bottomLeftOctTree.detectPoint(x,y);
				
				if(bottomRight.contains(x,y))
					return bottomRightOctTree.detectPoint(x,y);
				
				return new Vector.<DisplayObject>();
			}
		}
	}
}
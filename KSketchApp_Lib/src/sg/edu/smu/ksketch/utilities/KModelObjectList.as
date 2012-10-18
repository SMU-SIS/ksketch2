/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.utilities
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KObject;
	
	public class KModelObjectList implements IModelObjectList
	{
		private var _objectList:Vector.<KObject>;
		
		public function KModelObjectList()
		{
			_objectList = new Vector.<KObject>();
		}
		
		public function intersect(list:KModelObjectList):void
		{
			var it:IIterator = iterator;
			var obj:KObject;
			while (it.hasNext())
			{
				obj = it.next();
				if (!list.contains(obj))
					remove(obj);
			}
		}
		
		public function merge(list:KModelObjectList):void
		{
			var it:IIterator = list.iterator;
			while (it.hasNext())
			{
				var obj:KObject = it.next();
				if (!contains(obj))
					_objectList.push(obj);
			}
		}
		
		public function contains(obj:KObject):Boolean
		{
			return _objectList.indexOf(obj) > -1;
		}
		
		public function add(object:KObject, index:int = -1):void
		{
			if(_objectList.indexOf(object) < 0)
			{
				if(index < 0)
					_objectList.push(object);
				else
					_objectList.splice(index, 0, object);
			}
			else
				throw new Error(ErrorMessage.OBJECT_EXISTS +" "+object.id);
		}
		
		public function remove(object:KObject):void
		{
			var index:int = _objectList.indexOf(object);
			if(index >= 0)
				_objectList.splice(index,1);
			else
				throw new Error(ErrorMessage.OBJECT_NOT_EXIST);
		}
		
		public function length():int
		{
			return _objectList.length;
		}
		
		public function getObjectAt(index:int):KObject
		{
			return _objectList[index];
		}
		
		public function get iterator():IIterator
		{
			return new KModelObjectListIterator(this);
		}
		
		public function toIDs():Vector.<int>
		{
			var ints:Vector.<int> = new Vector.<int>();
			var it:IIterator = iterator;
			while(it.hasNext())
				ints.push(it.next().id);
			return ints;
		}
		
		public function toString():String
		{
			var str:String = "";
			var it:IIterator = iterator;
			if(it.hasNext())
				str = it.next().id.toString();
			while(it.hasNext())
				str += " " + it.next().id;
			return str;
		}
		
		public function getBoundingRect(time:Number, padding:Number = 0):Rectangle
		{
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			
			var maxX:Number = Number.MIN_VALUE;
			var maxY:Number = Number.MIN_VALUE;
			
			var object:KObject;
			var objectBounds:Rectangle;
			var topLeft:Point;
			var bottomRight:Point;
			var topRight:Point;
			var bottomLeft:Point;
			var minimum:Number;
			var maximum:Number
			var m:Matrix;
			
			var childList:Vector.<KObject> = new Vector.<KObject>;
			
			//Iterate through the given list of objects
			//and find all the children strokes that the objects have
			//Compile all the objects into a Nx2 array;
			//Each row of the Nx2 array consists of a stroke and its accopanying time
			for(var i:int = 0; i< _objectList.length; i++)
			{
				object = _objectList[i];
				
				if(object is KGroup)
				{	
					var subChildList:Vector.<KObject> = (object as KGroup).getChildren(time);
					
					for(var j:int = 0; j< subChildList.length; j++)
					{
						childList.push(subChildList[j]);
					}					
				}
				else
				{
					childList.push(object);
				}
			}
			
			//Iterate through the aggregated list of strokes and find its transformed bounding box
			var currentObjectBounds:Rectangle;
			
			for(var k:int = 0; k < childList.length; k++)
			{
				object = childList[k];
				m = object.getFullPathMatrix(time);
				currentObjectBounds = object.getBoundingRect(time);
				
				//Find the 4 points of each object's default bounding box
				topLeft = new Point(currentObjectBounds.x, currentObjectBounds.y);
				bottomRight = new Point(currentObjectBounds.right, currentObjectBounds.bottom);
				topRight = new Point(currentObjectBounds.right, currentObjectBounds.y);
				bottomLeft = new Point(currentObjectBounds.x, currentObjectBounds.bottom);
				
				//transform each point according to the desired matrix
				topLeft = m.transformPoint(topLeft);
				bottomRight = m.transformPoint(bottomRight);
				topRight = m.transformPoint(topRight);
				bottomLeft = m.transformPoint(bottomLeft);
				
				//find the min and max of x and y values
				minimum = Math.min(Math.min(topLeft.x, topRight.x), Math.min(bottomLeft.x, bottomRight.x));
				maximum = Math.max(Math.max(topLeft.x, topRight.x), Math.max(bottomLeft.x, bottomRight.x));
				minX = Math.min(minimum, minX);
				maxX = Math.max(maximum, maxX);
				
				minimum = Math.min(Math.min(topLeft.y, topRight.y), Math.min(bottomLeft.y, bottomRight.y));
				maximum = Math.max(Math.max(topLeft.y, topRight.y), Math.max(bottomLeft.y, bottomRight.y));
				minY = Math.min(minimum, minY);
				maxY = Math.max(maximum, maxY);
			}
			
			//return new rectangle with the min and max y values
			return new Rectangle(minX-padding, minY-padding, maxX-minX-padding, maxY-minY-padding);
		}
		
		public function getDefaultCenter(time:Number):Point
		{
			
			var sum:Point = new Point();
			var m:Matrix;
			var object:KObject;
			var total:int = 0;
			
			for(var i:int = 0; i< _objectList.length; i++)
			{
				object = _objectList[i];
				total ++;
				m = object.getFullMatrix(time);
				sum = sum.add(m.transformPoint(object.defaultCenter));
			}
			
			return new Point(sum.x/total, sum.y/total);
		}
			
	}
}
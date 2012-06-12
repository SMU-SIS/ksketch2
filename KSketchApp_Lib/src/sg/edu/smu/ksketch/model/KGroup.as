/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.model
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.IModelObjectList;
	import sg.edu.smu.ksketch.utilities.KAllChildrenIterator;
	import sg.edu.smu.ksketch.utilities.KDirectChildrenIterator;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	import sg.edu.smu.ksketch.utilities.KModelObjectListIterator;
	
	/**
	 * KGroup class models a list of KObjects. It contains methods to 
	 * add, remove and iterates through the KObjects in the Group. 
	 */		
	public class KGroup extends KObject implements IModelObjectList
	{
		private var _children:KModelObjectList;
		private var _defaultCenter:Point;
		
		public function KGroup(id:int, createdTime:Number, children:KModelObjectList, center:Point)
		{
			super(id,createdTime);
			_children = children;
			if(_children == null)
				_children = new KModelObjectList();
		}
		
		public function get children():KModelObjectList
		{
			return _children;
		}
		
		public function set children(value:KModelObjectList):void
		{
			_children = value;
		}
		
		public function hasChild(obj:KObject, time:Number):Boolean
		{
			var children:IIterator = directChildIterator(time);
			var currentObject:KObject;
			
			while(children.hasNext())
			{
				currentObject = children.next();
				
				//Id matches, just return
				if(currentObject.id == obj.id)
					return true;
				
				//else go deeper
				if(currentObject is KGroup)
					if((currentObject as KGroup).hasChild(obj, time))
						return true;
			}
			
			return false;
		}
		
		public function directChildIterator(kskTime:Number):IIterator
		{
			return new KDirectChildrenIterator(this, kskTime);
		}
		
		public function allChildrenIterator(kskTime:Number):IIterator
		{
			return new KAllChildrenIterator(this, kskTime);
		}
		
		public function get iterator():IIterator
		{
			return new KModelObjectListIterator(_children);
		}
		
		public function add(object:KObject, index:int = -1):void
		{
			_children.add(object, index);
		}
		
		/**
		 * Remove the specific object from the group.
		 * @param object a KObject to be removed.
		 */		
		public function remove(object:KObject):void
		{
			_children.remove(object);
		}
		
		public function length():int
		{
			return _children.length();
		}
		
		public function getObjectAt(index:int):KObject
		{
			return _children.getObjectAt(index);
		}
		
		override public function getBoundingRect(kskTime:Number = 0):Rectangle
		{
			var rect:Rectangle = null;
			var it:IIterator = allChildrenIterator(kskTime);
			while (it.hasNext())
			{
				var obj:KObject = it.next();
				if (obj is KStroke)
				{
					if (rect == null)
						rect = obj.getBoundingRect(kskTime);
					else
						rect = rect.union(obj.getBoundingRect(kskTime));
				}
			}
			return rect;
		}
		
		/** 
		 * Obtain the default center (centroid in this case) of this KGroup object
		 */		
		public override function get defaultCenter():Point
		{

			return _defaultCenter;
		}
		
		public function updateCenter(kskTime:Number = 0):void
		{
	//		var time:Number = createdTime;
			var time:Number = Math.max(createdTime,kskTime);
			var sum:Point = new Point();
			var m:Matrix;
			var object:KObject;
			var total:int = 0;
			//	var i:IIterator = allChildrenIterator(time);
			var i:IIterator = directChildIterator(time);
			while(i.hasNext())
			{
				object = i.next();
				total ++;
				m = object.getFullMatrix(time);
				sum = sum.add(m.transformPoint(object.defaultCenter));
			}
			
			if(total == 0)
				total = 1;
			
			_defaultCenter =  new Point(sum.x/total, sum.y/total);
		}

		public function getChildren(kskTime:Number):Vector.<KObject>
		{
			var child:KObject;
			var length:int = _children.length();
			var returnList:Vector.<KObject> = new Vector.<KObject>();
			
			var currentChildren:IIterator = allChildrenIterator(kskTime);
			
			while(currentChildren.hasNext())
			{
				returnList.push(currentChildren.next());
			}
			
			return returnList;
		}
		
		/**
		 * Returns a vector containing the parts of this KGroup that are visible
		 * If the whole of this KGroup is visible at given time, returns vector contains this group only
		 * If part of this group is not visible, returns vector containing all visible children, grandChildren and so on
		 * Calls recursively.
		 */
		public function partsVisible(time:Number):Vector.<KObject>
		{
			var allVisible:Boolean = true;
			
			var visibleParts:Vector.<KObject> = new Vector.<KObject>();
			var currentObject:KObject;
			var i:int = 0;
			var numChildren:int = _children.length();
			
			for(i = 0; i<numChildren; i++)
			{
				currentObject = _children.getObjectAt(i);
	
				if(currentObject is KGroup)
				{
					var visibleChildParts:Vector.<KObject> = (currentObject as KGroup).partsVisible(time);
					
					if(visibleChildParts[0] !== currentObject)
					{
						visibleParts = visibleParts.concat(visibleChildParts);
						allVisible = false;
					}
					else
						visibleParts.push(visibleChildParts[0]);
				}
				else
				{
					if(currentObject.getVisibility(time) > 0)
						visibleParts.push(currentObject)
					else
						allVisible = false;
				}
			}
			
			if(allVisible && (getVisibility(time) > 0))
			{
				visibleParts = new Vector.<KObject>();
				visibleParts.push(this);				
			}
			
			return visibleParts;
		}
	}
}
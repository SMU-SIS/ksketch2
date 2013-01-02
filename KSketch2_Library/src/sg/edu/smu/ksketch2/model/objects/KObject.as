/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.model.objects
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.operators.ITransformInterface;
	import sg.edu.smu.ksketch2.operators.IVisibilityControl;
	import sg.edu.smu.ksketch2.operators.KSingleReferenceFrameOperator;
	import sg.edu.smu.ksketch2.operators.KVisibilityControl;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	
	public class KObject extends EventDispatcher
	{
		public var transformInterface:ITransformInterface;
		public var visibilityControl:IVisibilityControl;
		private var _id:int;
		private var _parent:KGroup;
		protected var _selected:Boolean;
		protected var _center:Point;
		protected var _creationTime:int;
		
		/**
		 * KObject is teh abstract class representing the screen objects in the model.
		 */
		public function KObject(id:int)
		{
			super(this);
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch2.model.objects::KObject")
				throw new new Error("KObject is an Abstract class. You can't instantiate it!");
			_id = id;
			_selected = false;
			visibilityControl = new KVisibilityControl(this);
		}
		
		/**
		 * Initialises this object's visibility and transform. Object fails if it is not initialised
		 */
		public function init(time:int, op:KCompositeOperation):void
		{
			_creationTime = time;
			if(this is KGroup)
				visibilityControl.setVisibility(true, 0, op);
			else
				visibilityControl.setVisibility(true, time, op);
			transformInterface.insertBlankKeyFrame(time, op);
		}

		
		/**
		 * A number that identifies this KObject
		 */
		public function get id():int
		{
			return _id;
		}
		
		/**
		 * Boolean denoting whether this object is selected
		 * Setting this value causes the object to dispatch a selection state changed event
		 */
		public function get selected():Boolean
		{
			return _selected;	
		}
		
		/**
		 * Boolean denoting whether this object is selected
		 * Setting this value causes the object to dispatch a selection state changed event
		 */
		public function set selected(value:Boolean):void
		{
			_selected = value;
			dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_SELECTION_CHANGED,this, 0));
		}
		
		/**
		 * Returns the current parent of this KObject
		 */
		public function get parent():KGroup
		{
			return _parent;
		}
		
		/**
		 * Setting the parent for this KObject removes it from its previous parent
		 * and adds it to the new parent
		 */
		public function set parent(newParent:KGroup):void
		{
			//If old parent exists, dispatch an event to notify the whoever that the this object will be
			//Removed from its old parent
			if(_parent)
				_parent.remove(this);
			
			_parent = newParent;
			
			//Now dispatch another event to notify whoeever that this object will be added to newParent
			if(_parent)
				_parent.add(this);
		}
		
		/**
		 * Returns a list of this object's ancestors, with the most immediate parents occupying index 0....
		 * i.e. The root will always be at the end of the list if it is present.
		 */
		public function getHierarchy(hierarchyList:KModelObjectList = null):KModelObjectList
		{
			if(!hierarchyList)
				hierarchyList = new KModelObjectList();
			
			if(_parent)
			{ 
				hierarchyList.add(_parent);
				_parent.getHierarchy(hierarchyList);
			}
			return hierarchyList;
		}
		
		/**
		 * Returns the matrix of this object denoting its transformation on the screen.
		 * This matrix is its own matrix concatenated with its parents', grandparents' great granparents', great greate grandparents...
		 */
		public function fullPathMatrix(time:int):Matrix
		{

			var matrix:Matrix = transformInterface.matrix(time);
			
			if(_parent)
				matrix.concat(parent.fullPathMatrix(time));
			
			return matrix;
		}
		
		/**
		 * Returns this KObject's own matrix
		 */
		public function transformMatrix(time:int):Matrix
		{
			return transformInterface.matrix(time);
		}
		
		/**
		 * The default centroid of this object in the model
		 * not modified by any matrices
		 * We use the centroid as a measurement of an object's position
		 * This centroid its not its current centroid, it is its centroid at its created time
		 * May need to multiply the returned centroid with matrices if you need a relevant one.
		 */
		public function get centroid():Point
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch2.model.objects::KObject")
				throw new new Error("You don't ask a KObject for its centroid. Ask a KStroke or Group instead");
			
			return null;
		}
		
		public function debug(debugSpacing:String = ""):void
		{
			trace(debugSpacing,this, id);
		}
		
		public function serialize():XML
		{
			var objectXML:XML = <KObject id="" type="" centroid=""/>;
			objectXML.@id = id.toString();
			if(_center)
				objectXML.@centroid = _center.x.toString()+","+_center.y.toString();
			
			var parentXML:XML = <parent id=""/>;
			parentXML.@id=parent.id.toString();
			
			objectXML.appendChild(parentXML);
			objectXML.appendChild(visibilityControl.serializeVisibility());
			objectXML.appendChild(transformInterface.serializeTransform());
			
			return objectXML;
		}
		
		public function deserialize(xml:XML):void
		{
			if(xml.@centroid)
			{
				var centroidPosition:Array = ((xml.@centroid).toString()).split(",");
				if(centroidPosition[0].length > 0 && centroidPosition[1].length > 0)
					_center = new Point(centroidPosition[0], centroidPosition[1]);
			}
			visibilityControl.deserializeVisibility(new XML(xml.Activity));
			transformInterface.deserializeTransform(new XML(xml.transform));
		}
		
		/**
		 * Clone this object and let it have the given id
		 * Cloned objects can have identical motions as the original
		 * Visibility attributes are not cloned and the cloned objects will appear 
		 * at any given time. Remember to give it a visibility key if not it will not appear
		 */
		public function clone(id:int, withMotions:Boolean = false):KObject
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch2.model.objects::KObject")
				throw new new Error("You don't ask a KObject for its centroid. Ask a KStroke or Group instead");
			
			return null;
		}
	}
}
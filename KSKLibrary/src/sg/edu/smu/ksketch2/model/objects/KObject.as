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
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.operators.ITransformInterface;
	import sg.edu.smu.ksketch2.operators.IVisibilityControl;
	import sg.edu.smu.ksketch2.operators.KVisibilityControl;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.utils.iterators.INumberIterator;
	import sg.edu.smu.ksketch2.utils.iterators.KNumberIteratorComposite;
	
	/**
	 * The KObject class serves as the abstract class for representing
	 * screen objects in the model in K-Sketch.
	 */
	public class KObject extends EventDispatcher
	{
		public var transformInterface:ITransformInterface;	// the object's transform
		public var visibilityControl:IVisibilityControl;	// the object's visibility
		
		private var _id:int;								// the object's ID
		private var _parent:KGroup;							// the object's parent
		
		protected var _selected:Boolean;					// the object's selection state flag
		protected var _center:Point;						// the object's center of rotation/scaling
		protected var _creationTime:Number;					// the object's creation time
		
		//KSKETCH-SYNPHNE
		private var _template:Boolean;	
		private var _hide:Boolean;
		private var _originalId:int;
		private var _startRegion:int;
		private var _endRegion:int;
		
		/**
		 * The main constructor of the KObject class.
		 * 
		 * @param id The object's ID.
		 */
		public function KObject(id:int)
		{
			super(this);
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch2.model.objects::KObject")
				throw new new Error("KObject is an Abstract class. You can't instantiate it!");
			_id = id;
			_selected = false;
			
			//KSKETCH-SYNPHNE
			_template = false;
			_hide = false;
			_originalId = id;
			
			visibilityControl = new KVisibilityControl(this);
		}
		
		/**
		 * Initializes the object's visibility and transform. The
		 * object fails if it is not initialized.
		 * 
		 * @param time The target creation time.
		 * @param op The corresponding composite operation.
		 */
		public function init(time:Number, op:KCompositeOperation):void
		{
			// set the object's creation time
			_creationTime = time;
			
			// handle cases for different derived classes
			if(this is KGroup)
			{
				visibilityControl.setVisibility(true, 0, op, false);
				transformInterface.insertBlankKeyFrame(0, op, false);
			}
				
			else
			{
				visibilityControl.setVisibility(true, time, op, false);
				// insert a blank key at the given time in the transform
				transformInterface.insertBlankKeyFrame(time, op, false);
			}
				
			
			
		}

		
		/**
		 * Gets the object's ID.
		 * 
		 * @return The object's ID.
		 */
		public function get id():int
		{
			return _id;
		}
		
		/**
		 * Gets the object's selection state.
		 * 
		 * @return The object's selection state.
		 */
		public function get selected():Boolean
		{
			return _selected;	
		}
		
		/**
		 * Sets the object's selection state. Setting this value causes the
		 * object to dispatch a selection state changed event.
		 * 
		 * @param value The object's selection state.
		 */
		public function set selected(value:Boolean):void
		{
			_selected = value;
			
			dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_SELECTION_CHANGED,this, 0));
		}
		
		/**
		 * Gets the object's current parent.
		 * 
		 * @return The object's current parent.
		 */
		public function get parent():KGroup
		{
			return _parent;
		}
		
		/**
		 * Sets the object's current parent by first removing its previous
		 * parent and then adding its new parent.
		 * 
		 * @param newParent The object's new parent.
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
			{
				//TRACE GROUP CENTROID
				trace("==============================================================");
				trace("KObject > set parent() > parent: " + _parent.id + ", kobject: " + this.id);
				//END OF TRACE
				
				_parent.add(this);
			}
		}
		
		/**
		 * Gets the object's hierarchy by retrieving the list of the
		 * object's ancestors, with the most immediate parents occupying
		 * index 0. That is, the root will always be at the end of the list,
		 * if it is present.
		 * 
		 * @param hierarchyList The object's previous hierarchy.
		 * @return The object's current hierarchy.
		 */
		public function getHierarchy(hierarchyList:KModelObjectList = null):KModelObjectList
		{
			// case: there is no hierarchy list
			if(!hierarchyList)
				hierarchyList = new KModelObjectList();
			
			// case: the object's parent exists
			if(_parent)
			{ 
				// add the object's parent
				hierarchyList.add(_parent);
				
				// recurse through the object's parent
				_parent.getHierarchy(hierarchyList);
			}
			
			// return the object's updated hierarchy
			return hierarchyList;
		}
		
		/**
		 * Get the object's maximum time by retrieving the time of the last
		 * key frame in the object's transform.
		 * 
		 * @return The object's maximum time.
		 */
		public function get maxTime():Number
		{
			return transformInterface.lastKeyTime;
		}
		
		/**
		 * Gets the object's fulll matrix that denotes its transformation on the screen. This matrix is its own matrix that concatenates its
		 * ancesortors (i.e, parents', grandparents', ...).
		 * 
		 * @param time The target time.
		 * @return The object's full matrix.
		 */
		public function fullPathMatrix(time:Number):Matrix
		{
			// get the transform's matrix at the given time
			var matrix:Matrix = transformInterface.matrix(time);
			
			// case: the object's parent exists
			// concatenate the parent's full matrix to this matrix
			if(_parent)
				matrix.concat(parent.fullPathMatrix(time));
			
			// return the full matrix
			return matrix;
		}
		
		/**
		 * Returns the object's transform matrix.
		 * 
		 * @param int The target time.
		 * @return The object's transform matrix.
		 */
		public function transformMatrix(time:Number):Matrix
		{
			return transformInterface.matrix(time);
		}
		
		/**
		 * The default centroid of this object in the model not modified by any
		 * matrices. We use the centroid as a measurement of the object's position.
		 * This centroid is not its current centroid, but the centroid at its created
		 * time. May need to multiply the returned centroid with matrices if you need
		 * a relevant one.
		 * 
		 * @return The object's centroid at creation time.
		 */
		public function get center():Point
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch2.model.objects::KObject")
				throw new new Error("You don't ask a KObject for its centroid. Ask a KStroke or Group instead");
			
			return null;
		}
		
		/**
		 * Debugs the object by outputting debugging console messages.
		 * 
		 * @param debugSpacing The target spacing in the debugging messages.
		 */
		public function debug(debugSpacing:String = ""):void
		{
			trace(debugSpacing,this, id);
		}
		
		/**
		 * Sets the object's centroid.
		 * 
		 * @param point The object's centroid.
		 */
		public function set center(point:Point):void
		{
			_center = point.clone();
		}
		
		
		/**
		 * Returns an interator that gives the times of all translate events for this object or its parents
		 * in order from beginning to end. 
		 */
		public function translateTimeIterator():INumberIterator
		{
			if (_parent == null)
			{
				return transformInterface.translateTimeIterator()
			}
			else
			{
				return new KNumberIteratorComposite(transformInterface.translateTimeIterator(), 
					_parent.translateTimeIterator());		
			}
		}
		
		/**
		 * Returns an interator that gives the times of all rotate events for this object or its parents
		 * in order from beginning to end. 
		 */
		public function rotateTimeIterator():INumberIterator
		{
			if (_parent == null)
			{
				return transformInterface.rotateTimeIterator()
			}
			else
			{
				return new KNumberIteratorComposite(transformInterface.rotateTimeIterator(), 
					_parent.rotateTimeIterator());		
			}
		}
		
		/**
		 * Returns an interator that gives the times of all scale events for this object or its parents
		 * in order from beginning to end. 
		 */
		public function scaleTimeIterator():INumberIterator
		{
			if (_parent == null)
			{
				return transformInterface.scaleTimeIterator()
			}
			else
			{
				return new KNumberIteratorComposite(transformInterface.scaleTimeIterator(), 
					_parent.scaleTimeIterator());		
			}
		}
		
		
		/**
		 * Serializes the object to an XML object.
		 * 
		 * @return The serialized XML object of the object.
		 */
		public function serialize():XML
		{
			var objectXML:XML = <KObject/>;
			objectXML.@id = id.toString();
			objectXML.@creationTime = _creationTime.toString();
			
			//KSKETCH-SYNPHNE
			objectXML.@hide = _hide.toString();
			objectXML.@template = _template.toString();
			objectXML.@originalId = _originalId.toString();
			objectXML.@startRegion = _startRegion.toString();
			objectXML.@endRegion = _endRegion.toString();
			
			if(_center)
				objectXML.@centroid = _center.x.toString()+","+_center.y.toString();
			
			if(parent)
			{
				var parentXML:XML = <parent/>;
				parentXML.@id=parent.id.toString();	
				objectXML.appendChild(parentXML);
			}
			
			objectXML.appendChild(visibilityControl.serializeVisibility());
			objectXML.appendChild(transformInterface.serializeTransform());
			
			return objectXML;
		}
		
		/**
		 * Deserializes the XML object to an object.
		 * 
		 * @param The target XML object.
		 */
		public function deserialize(xml:XML):void
		{
			if(xml.@centroid)
			{
				var centroidPosition:Array = ((xml.@centroid).toString()).split(",");
				if(centroidPosition[0].length > 0 && centroidPosition[1].length > 0)
					_center = new Point(centroidPosition[0], centroidPosition[1]);
			}
			
			if(xml.@creationTime)
			{
				_creationTime = Number((xml.@creationTime).toString());
			}
			
			//KSKETCH-SYNPHNE
			if(xml.@startRegion)
			{
				_startRegion = Number((xml.@startRegion).toString());
			}
			
			if(xml.@endRegion)
			{
				_endRegion = Number((xml.@endRegion).toString());
			}
			
			if(xml.@originalId)
			{
				_originalId = Number((xml.@originalId).toString());
			}
			
			if(xml.@hide)
			{
				var temp:String = (xml.@hide.toString());
				if(temp == null)
					_hide = false;
				else if (temp.indexOf("true") >= 0)
					_hide = true;
				else
					_hide = false;
			}
			
			if(xml.@template)
			{
				var temp:String = (xml.@template.toString());
				if(temp == null)
					_template = false;
				else if (temp.indexOf("true") >= 0)
					_template = true;
				else
					_template = false;
			}
			//END KSKETCH-SYNPHNE
				
			visibilityControl.deserializeVisibility(new XML(xml.Activity));
			transformInterface.deserializeTransform(new XML(xml.transform));
		}
		
		/**
		 * Clones the object with the given ID. Cloned objects can have
		 * identical motions to the original objects. Visibility attributes
		 * are not cloned and the cloned objects will appear at any given
		 * time. Remember to give cloned objects a visibility key. If not,
		 * it will not appear.
		 * 
		 * @param id The cloned object's ID.
		 * @param withMotions The cloned object's motion state flag.
		 */
		public function clone(id:int, withMotions:Boolean = false):KObject
		{
			if (getQualifiedClassName(this) == "sg.edu.smu.ksketch2.model.objects::KObject")
				throw new new Error("You don't ask a KObject for its centroid. Ask a KStroke or Group instead");
			
			return null;
		}
		
		//KSKETCH-SYNPHNE
		public function initRegion(start:int, end:int):void
		{
			_startRegion = start;
			_endRegion = end;
		}
		
		public function get startRegion():int
		{
			return _startRegion;
		}
		
		public function set startRegion(value:int):void
		{
			_startRegion = value;
		}
		
		public function get endRegion():int
		{
			return _endRegion;
		}
		
		public function set endRegion(value:int):void
		{
			_endRegion = value;
		}
		
		public function get hide():Boolean
		{
			return _hide;
		}
		
		public function set hide(value:Boolean):void
		{
			_hide = value;
		}
		
		public function get originalId():int
		{
			return _originalId;
		}
		
		public function set originalId(id:int):void
		{
			_originalId = id;
		}
		
		public function get template():Boolean
		{
			return _template;
		}
		
		public function set template(value:Boolean):void
		{
			_template = value;
		}
	}
}
/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.operators
{
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.IVisibilityKey;
	import sg.edu.smu.ksketch2.model.data_structures.KVisibilityKey;
	import sg.edu.smu.ksketch2.model.data_structures.KVisibilityKeyList;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.operators.operations.KInsertKeyOperation;
	import sg.edu.smu.ksketch2.operators.operations.KVisibilityChangedOperation;

	public class KVisibilityControl implements IVisibilityControl
	{
		private var _object:KObject;
		private var _visibilityKeys:KVisibilityKeyList;
		
		/**
		 * Operator for visibility keys
		 * Don't really need this but I think we should have something here.
		 * We can deal with visibility interpolation in this class instead of changing the data object
		 * for visibility keys.
		 */
		public function KVisibilityControl(object:KObject)
		{
			_object = object;
			_visibilityKeys = new KVisibilityKeyList();
//			setVisibility(false, 0, null);
		}
		
		public function get earliestVisibleTime():int
		{
			var currentKey:IKeyFrame = _visibilityKeys.head;
			
			while(!(currentKey as IVisibilityKey).visible)
			{
				currentKey = currentKey.next;
			}
			
			return currentKey.time;
		}
		
		public function get visibilityKeyHeader():IKeyFrame
		{
			return _visibilityKeys.head;
		}
		
		/**
		 * Sets the visibility at time
		 */
		public function setVisibility(visible:Boolean, time:int, op:KCompositeOperation):void
		{
			//Look for the relevant key at given time first
			var key:IVisibilityKey = _visibilityKeys.getActiveKey(time);
			if(key)
			{
				if(key.visible == visible)
					return;
				
				if(key.time == time)
				{	
					if(op)
						op.addOperation(new KVisibilityChangedOperation(key, key.visible, visible));
					key.visible = visible;
					_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_VISIBILITY_CHANGED, _object, time));
					return;
				}
			}
			
			key = new KVisibilityKey(time);
			_visibilityKeys.insertKey(key);
			if(op)
				op.addOperation(new KInsertKeyOperation(key.previous, key.next, key));
			
			//Set the visibility at the give time
			key.visible = visible;
			if(op)
				op.addOperation(new KVisibilityChangedOperation(key, false, visible));
			
			_object.dispatchEvent(new KObjectEvent(KObjectEvent.OBJECT_VISIBILITY_CHANGED, _object, time));
		}
		
		/**
		 * Should be able to switch this function around to give
		 * interpolated visibility values
		 */
		public function alpha(time:int):Number
		{
			var key:IVisibilityKey = _visibilityKeys.getActiveKey(time);
			if(key)
			{
				if(key.visible)
					return 1.0;
				else
					return 0.0;
			}
			else
				return 0.0;
		}
		
		public function serializeVisibility():XML
		{
			var visibilityXML:XML = <Activity/>;
			visibilityXML.appendChild(_visibilityKeys.serialize());
			
			return visibilityXML;
		}
		
		public function deserializeVisibility(xml:XML):void
		{
			_visibilityKeys = new KVisibilityKeyList();
			var keyXML:XMLList = xml.keylist.visibilitykey
			for(var i:int = 0; i<keyXML.length(); i++)
			{
				var newVisibilityKey:KVisibilityKey = new KVisibilityKey(int(keyXML[i].@time));
				
				if(keyXML[i].@visibility == "true")
					newVisibilityKey.visible = true;
				else
					newVisibilityKey.visible = false;
				_visibilityKeys.insertKey(newVisibilityKey);
			}
		}
		
		public function clone():IVisibilityControl
		{
			var newVisibilityControl:KVisibilityControl = new KVisibilityControl(_object);
			var clonedKeys:KVisibilityKeyList = _visibilityKeys.clone() as KVisibilityKeyList;
			
			newVisibilityControl._visibilityKeys = clonedKeys;
			
			return newVisibilityControl;
		}
	}
}
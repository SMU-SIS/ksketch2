/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.operation.implementations
{
	import sg.edu.smu.ksketch.event.KGroupUngroupEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.IParentKeyFrame;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KModel;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.operation.KGroupUtil;
	import sg.edu.smu.ksketch.utilities.IIterator;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;

	public class KGroupOperation implements IModelOperation
	{
		private var _model:KModel;
		private var _parent:KGroup;
		private var _group:KGroup;
		private var _oldParents:Vector.<KGroup>;
		
		public function KGroupOperation(model:KModel, parent:KGroup, 
										group:KGroup, oldParents:Vector.<KGroup>)
		{
			_model = model;
			_parent = parent;
			_group = group;
			_oldParents = oldParents;
		}
		
		public function apply():void
		{
			if (!_parent.children.contains(_group))
				_parent.add(_group);
			KGroupUtil.setParentKey(_group.createdTime,_group,_parent);
			var children:KModelObjectList = _group.children;
			for (var i:int = 0; i < children.length(); i++)
			{
				var obj:KObject = children.getObjectAt(i);
				var key:IParentKeyFrame = obj.getParentKey(_group.createdTime) as IParentKeyFrame;
	
				if (key != null && key.parent.children.contains(obj))
					key.parent.remove(obj);
				KGroupUtil.setParentKey(_group.createdTime,obj,_group);
				obj.dispatchEvent(new KObjectEvent(obj,KObjectEvent.EVENT_PARENT_CHANGED));
			}
			_group.updateCenter();
			_group.dispatchEvent(new KObjectEvent(_group,KObjectEvent.EVENT_TRANSFORM_CHANGED));
			_model.dispatchEvent(new KObjectEvent(_group, KObjectEvent.EVENT_OBJECT_ADDED));
			_model.dispatchEvent(new KGroupUngroupEvent(_group, KGroupUngroupEvent.EVENT_GROUP));
		}
		
		public function undo():void
		{	
			var children:KModelObjectList = _group.children;
			for (var i:int = 0; i < children.length(); i++)
			{
				var obj:KObject = children.getObjectAt(i);
				if (_oldParents[i])
				{
					KGroupUtil.setParentKey(_group.createdTime,obj,_oldParents[i]);
					if (!_oldParents[i].children.contains(obj))
						_oldParents[i].add(obj);
				}
				else
					obj.removeParentKey(_group.createdTime);
				obj.dispatchEvent(new KObjectEvent(obj,KObjectEvent.EVENT_PARENT_CHANGED));
			}
			KGroupUtil.setParentKey(_group.createdTime,_group,_model.root);
			if (_parent.children.contains(_group))
				_parent.remove(_group);
			_group.updateCenter();
			_group.dispatchEvent(new KObjectEvent(_group,KObjectEvent.EVENT_TRANSFORM_CHANGED));
			_model.dispatchEvent(new KGroupUngroupEvent(_group, KGroupUngroupEvent.EVENT_UNGROUP));
			_model.dispatchEvent(new KObjectEvent(_group, KObjectEvent.EVENT_OBJECT_REMOVED));
		}
		
		public function get group():KGroup
		{
			return _group;
		}
		
		public function get parent():KGroup
		{
			return _parent;
		}
	}
}
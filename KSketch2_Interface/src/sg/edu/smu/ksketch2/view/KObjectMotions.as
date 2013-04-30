package sg.edu.smu.ksketch2.view
{
	import flash.display.Sprite;
	
	import sg.edu.smu.ksketch2.events.KObjectEvent;
	import sg.edu.smu.ksketch2.model.data_structures.KSpatialKeyFrame;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	
	public class KObjectMotions extends Sprite
	{
		private var _object:KObject;
		private var color:Array = [0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0x00FFFF, 0xFF00FF]
		
		
		/**
		 *	Display class for motion paths and ghosts.
		 *	Supposed to help in micromanaging object motion paths
		 */
		public function KObjectMotions()
		{
			super();
		}
		
		public function set object(newObject:KObject):void
		{
			_object = newObject;		
			
			if(_object)
			{
				//draw translation path here
				//Object ghosts will be here too
				graphics.beginFill(color[_object.id]);
				graphics.drawCircle(_object.centroid.x, _object.centroid.y, 20);
				graphics.endFill();
			}
			else
			{
				graphics.clear();
			}
		}
		
		public function get object():KObject
		{
			return object;
		}
		
		public function _visibilityChanged(event:KObjectEvent):void
		{
			if(!_object)
				return;
			
			if(_object.visibilityControl.alpha(event.time) <= 0)
			{
				this.visible = false;
				return;
			}
			else
				this.visible = true;
		}
		
		public function updateObjectMotion(fromTime:int, toTime:int):void	
		{
			//Find the active key
			var activeKey:KSpatialKeyFrame = _object.transformInterface.getActiveKey(toTime) as KSpatialKeyFrame;
		}
		
		private function _transformBegin(event:KObjectEvent):void
		{
			//If performance, need to hide paths
			//Init ghosts here
			
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_ENDED, _transformEnd);	
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _transformBegin);
		}
		
		private function _transformEnd(event:KObjectEvent):void
		{
			_object.removeEventListener(KObjectEvent.OBJECT_TRANSFORM_ENDED, _transformEnd);	
			_object.addEventListener(KObjectEvent.OBJECT_TRANSFORM_BEGIN, _transformBegin);
		}
	}
}
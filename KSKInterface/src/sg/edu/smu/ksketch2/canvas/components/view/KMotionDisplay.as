package sg.edu.smu.ksketch2.canvas.components.view
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import spark.core.SpriteVisualElement;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.controls.IInteractionControl;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KObject;

	public class KMotionDisplay extends SpriteVisualElement
	{
		private const DEFAULT_MOTION_DISPLAY_LIMIT:int = 10;
		
		private var _KSketch:KSketch2;
		private var _interactionControl:IInteractionControl;
		
		private var _objectsWithPath:KModelObjectList;
		private var _visibleMotionDisplays:Dictionary;
		private var _motionDisplays:Dictionary;
		
		/**
		 * Class that manages and displays motion paths
		 * Determines which motion paths to show and creates/draws them
		 */
		public function KMotionDisplay()
		{
			super();
			_visibleMotionDisplays = new Dictionary(true);
			_motionDisplays = new Dictionary(true);
			_objectsWithPath = new KModelObjectList();
			mouseChildren = false;
			mouseEnabled = false;
		}
		
		public function init(KSketchInstance:KSketch2, interactionControl:IInteractionControl):void
		{
			_KSketch = KSketchInstance;	
			_interactionControl = interactionControl;
			
			_interactionControl.addEventListener(KSketchEvent.EVENT_SELECTION_SET_CHANGED, _turnOnMotionDisplays);
			_KSketch.addEventListener(KTimeChangedEvent.EVENT_TIME_CHANGED, _handler_UpdateAllViews);
			_KSketch.addEventListener(KSketchEvent.EVENT_MODEL_UPDATED, _handler_UpdateAllViews);
			_KSketch.addEventListener(KSketchEvent.EVENT_KSKETCH_INIT, reset);
		}
		
		/**
		 * Registers a KObject for motion display
		 * Once registered, object's motions will show up when it is selected
		 */
		public function registerObject(object:KObject):void	
		{
			var newObjectMotion:KObjectMotions = new KObjectMotions();
			newObjectMotion.object = object;
			addChild(newObjectMotion);
			_motionDisplays[object] = newObjectMotion;
		}
		
		/**
		 * Invoked when the selection set changes (object composition changes)
		 * Deals with path visibility, detailed changes to the motion paths
		 * will be handled by the paths themselves
		 */
		private function _turnOnMotionDisplays(event:KSketchEvent):void
		{
			//Find 3 sets of objects
			//Objects that were already part of selection
			//Objects that were part of the selection, but not in the current set
			//New objects
			var i:int;			
			var currentSelection:KModelObjectList = _interactionControl.selection?_interactionControl.selection.objects:new KModelObjectList();
			var currentObject:KObject;
			var objectMotion:KObjectMotions;

			//There was a set of selection before this
			//We need to remove those objects which are not currently selected first				
			for(i = 0; i < _objectsWithPath.length(); i++)
			{
				currentObject = _objectsWithPath.getObjectAt(i);

				if(_visibleMotionDisplays[currentObject])
				{
					objectMotion = _visibleMotionDisplays[currentObject];
					objectMotion.visible = false;
					delete(_visibleMotionDisplays[currentObject]);
				}
			}
				
			//Then we add the new selections in for display
			
			_objectsWithPath = new KModelObjectList();
			
			for(i = 0; i < currentSelection.length(); i++)
			{
				currentObject = currentSelection.getObjectAt(i);
				
				if(!_motionDisplays[currentObject])
					registerObject(currentObject);

				if(!_visibleMotionDisplays[currentObject])
				{
					objectMotion = _motionDisplays[currentObject];				
					_visibleMotionDisplays[currentObject] = objectMotion;
					objectMotion.visible = true;
				}
				
				_objectsWithPath.add(currentObject);
			}
		}
		
		/**
		 * Updates the view of each object in the views table.
		 */
		private function _handler_UpdateAllViews(event:Event):void
		{
			for(var view:Object in _visibleMotionDisplays)
				_visibleMotionDisplays[view]._updateObjectMotion(_KSketch.time);
		}
		
		public function reset(event:KSketchEvent = null):void
		{
			while(numChildren!=0)
				removeChildAt(0);
			
			mouseChildren = false;
			mouseEnabled = false;
			_visibleMotionDisplays = new Dictionary(true);
			_motionDisplays = new Dictionary(true);
			_objectsWithPath = new KModelObjectList();
		}
	}
}
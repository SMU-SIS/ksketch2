/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.utilities
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import sg.edu.smu.ksketch.event.KDebugHighlightChanged;
	import sg.edu.smu.ksketch.event.KSelectionChangedEvent;
	import sg.edu.smu.ksketch.event.KTimeChangedEvent;
	import sg.edu.smu.ksketch.gestures.GestureDesign;
	import sg.edu.smu.ksketch.interactor.KLoopSelectInteractor;
	import sg.edu.smu.ksketch.interactor.KSelection;
	import sg.edu.smu.ksketch.interactor.UserOption;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	
	public class KAppState extends EventDispatcher
	{
		public static const APP_BUILD_SERIAL:String = "0.2a 22-08-2012";
		public static const TIMER_INTERVAL:Number = 15;
		public static const ANIMATION_INTERVAL:Number = 62.5;
		public static const DEFAULT_MAX_TIME:Number = 5000;
		public static const DEFAULT_MAX_PLAY_TIME:Number = 1000;
		
		public static const KEYBOARD_INTERPOLATED:Array = [];
		public static const KEYBOARD_REALTIME:Array = [Keyboard.CONTROL, Keyboard.PAGE_UP,Keyboard.ALTERNATE, Keyboard.PAGE_DOWN];
		public static const KEYBOARD_INSTANT:Array = [];
		public static const RIGHT_BUTTON_SAME_AS:uint = Keyboard.CONTROL;
		
		public static const SELECTION_GROUP:String = "Group-Selection";
		public static const SELECTION_STROKE:String = "Stroke-Selection";
		public static const SELECTION_GROUP_AND_STROKE:String = "Group-and-Stroke-Selection";
		
		public static const CREATION_INTERPOLATE:String = "Interpolate";
		public static const CREATION_DEMONSTRATE:String = "Demonstrate";
		public static const CREATION_INTERPOLATE_DEMONSTRATE:String = "Interpolate-and-Demonstrate";
		
		public static const GROUPING_EXPLICIT_STATIC:String = "Explicit-Static-Grouping";
		public static const GROUPING_EXPLICIT_DYNAMIC:String = "Explicit-Dynamic-Grouping";
		public static const GROUPING_IMPLICIT_DYNAMIC:String = "Implicit-Dynamic-Grouping";
		public static const GROUPING_IMPLICIT_STATIC:String = "Implicit-Static-Grouping"
		
		public static const TRANSITION_INSTANT:int = 2;
		public static const TRANSITION_INTERPOLATED:int = 1;
		public static const TRANSITION_REALTIME:int = 0;
		public static const TRANSITION_DEFAULT:int = TRANSITION_INTERPOLATED;
		
		public static const EVENT_EDIT_ENABLED_CHANGED:String = 'editEnabledChanged';
		public static const EVENT_GROUPING_ENABLED_CHANGED:String = 'groupingEnabledChanged';
		public static const EVENT_UNDO_REDO_ENABLED_CHANGED:String = 'UndoRedoEnabledChanged';
		public static const EVENT_UNDO_ENABLED_CHANGED:String = 'UndoEnabledChanged';
		public static const EVENT_REDO_ENABLED_CHANGED:String = 'RedoEnabledChanged';
		public static const EVENT_HANDLE_CENTER_CHANGED:String = "CenterChanged";
		public static const EVENT_SELECT_MODE_CHANGED:String = "SelectModeChanged";
		public static const EVENT_ANIMATION_START:String = "AnimationStart";
		public static const EVENT_ANIMATION_STOP:String = "AnimationStop";
		public static const EVENT_RECORDING_START:String = "RecordingStart";
		public static const EVENT_RECORDING_STOP:String = "RecordingStop";
		public static const EVENT_OBJECT_PATH:String = "ShowPathOption";
				
		public static const IS_AIR:Boolean = Capabilities.playerType == "Desktop";
		
		public var defaultPenColor:uint = 0x000000;
		[Bindable]
		public var penColor:uint = defaultPenColor;
		[Bindable]
		public var penThickness:uint = 1;
		[Bindable]
		public var isPen:Boolean;
		
		[Bindable]
		public var gestureDesignName:String = GestureDesign.design1.name;
		
		[Bindable]
		public var gesture:String = "";
		[Bindable]
		public var score:Number = 0;
		[Bindable]
		public var selectedItem:String;
		
		[Bindable]
		public var cyclingEnabled:Boolean;
		
		[Bindable]
		public var isUserTest:Boolean;
		
		public var setSliderMaxValueForUndo:Function;
		public var setSliderMaxValueForRedo:Function;
		
		public var updateFacadeInsertionMode:Function;
		public var updateFacadeCenterMode:Function;
		public var updateFacadeRefactorMode:Function;
		public var updateFacadeCreationMode:Function;
		
		public var trackTapTime:Number;
		public var overViewTrackBox:Rectangle;
		public var translateTrackBox:Rectangle;
		public var rotateTrackBox:Rectangle;
		public var scaleTrackBox:Rectangle;
		public var targetTrackBox:int;
		
		public static var erase_real_time_future:Boolean = true;
		private static var _time:Number; 
		
		private var _savedTime:Number;
		private var _maxTime:Number;
		private var _maxPlayTime:Number;
		
		private var _explicitGrouping:Boolean;
		private var _implicitUngroup:Boolean;
		
		private var _creationMode:String;		
		private var _transitionType:int;
		private var _selectMode:String;
		
		private var _prevSelection:KSelection;
		private var _selection:KSelection;
		private var _debugSelection:KModelObjectList;
		
		private var _undoStack:Vector.<IModelOperation>;
		private var _redoStack:Vector.<IModelOperation>;
		
		private var _ctrlEnabled:Boolean;
		private var _altEnabled:Boolean;
		private var _pgUpEnabled:Boolean;
		private var _pgDownEnabled:Boolean;
		
		private var _undoEnabled:Boolean;
		private var _redoEnabled:Boolean;
		private var _pasteEnabled:Boolean;
		private var _ungroupEnabled:Boolean;
		
		private var _refactorMode:String;
		
		private var _groupSelectMode:String;
		private var _groupingMode:String;
		private var _timer:Timer;
		
		private var _startSysTime:Number;
		private var _startKSKTime:Number;
		
		private var _userOption:UserOption;
		
		private var _zoomedOutProportion:Number = 0.45;
		
		public var gestureMode:Boolean = false;
		
		public function KAppState()
		{
			_undoEnabled = true;
			if(_undoEnabled)
				_undoStack = new Vector.<IModelOperation>();
			
			_redoEnabled = true;
			if(_redoEnabled)
				_redoStack = new Vector.<IModelOperation>();
			
			_time = 0;
			_selection = null;
			_ctrlEnabled = true;
			_altEnabled = true;
			_pgUpEnabled = true;
			_pgDownEnabled = true;
			_groupSelectMode = SELECTION_GROUP_AND_STROKE;
			_groupingMode = GROUPING_IMPLICIT_DYNAMIC;
			_pasteEnabled = false;
			_ungroupEnabled = false;
			
			_timer = new Timer(TIMER_INTERVAL, 0);
			
			_maxTime = DEFAULT_MAX_TIME;
			_maxPlayTime = DEFAULT_MAX_PLAY_TIME;
			_startSysTime = -1;
			_startKSKTime = -1;
			
			_implicitUngroup = true;
			
			_userOption = new UserOption(this);
			
			_creationMode = CREATION_INTERPOLATE_DEMONSTRATE;
			_transitionType = TRANSITION_INTERPOLATED;
			_selectMode = KLoopSelectInteractor.MODE;
			isPen = true;
			
			cyclingEnabled = true;
			isUserTest = false;
		}
		
		public function get appBuildNumber():String
		{
			return APP_BUILD_SERIAL;
		}
		
		public function get zoomedOutProportion():Number
		{
			return _zoomedOutProportion;
		}
		
		public function set zoomedOutProportion(value:Number):void
		{
			_zoomedOutProportion = value;
		}
		
		public function get groupingMode():String
		{
			return _groupingMode;
		}
		
		public function set groupingMode(value:String):void
		{
			_groupingMode = value;
		}
		
		public function get userOption():UserOption
		{
			return _userOption;
		}
		
		[Bindable(event='SelectModeChanged')]
		public function get selectMode():String
		{
			return _selectMode;
		}
		
		public function set selectMode(value:String):void
		{
			_selectMode = value;
			this.dispatchEvent(new Event(EVENT_SELECT_MODE_CHANGED));
		}
		
		public function get transitionType():int
		{
			return _transitionType;
		}
		
		public function set transitionType(value:int):void
		{
			_transitionType = value;
		}
		
		public function get creationMode():String
		{
			return _creationMode;
		}
		
		public function set creationMode(value:String):void
		{
			if(updateFacadeCreationMode != null)
				updateFacadeCreationMode(value);
			
			_creationMode = value;
		}
		
		public function get maxPlayTime():Number
		{
			return _maxPlayTime;
		}
		
		public function set maxPlayTime(value:Number):void
		{
			_maxPlayTime = value;
			this.dispatchEvent(new Event("maxPlayTimeChanged"));
		}
		
		[Bindable(event='maxTimeChanged')]
		public function get maxTime():Number
		{
			return _maxTime;
		}
		
		public function set maxTime(value:Number):void
		{
			_maxTime = value;
			this.dispatchEvent(new Event("maxTimeChanged"));
		}
		
		public function get isAnimating():Boolean
		{
			return _timer.running;
		}
		
		public function startPlaying():void
		{
			_savedTime = _time;
			_timer.addEventListener(TimerEvent.TIMER, playHandler);
			startTimer();
			this.dispatchEvent(new Event(EVENT_ANIMATION_START));
		}
		private function playHandler(event:TimerEvent):void 
		{
			var now_sysTime:Number = (new Date()).time;
			var now_kskTime:Number =  _startKSKTime + (now_sysTime - _startSysTime);
			
			if(now_kskTime > _maxPlayTime)
			{
				time = _maxPlayTime;
				stopPlaying();
			}
			else
				time = now_kskTime;
		}
		public function pause():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, playHandler);
			stopTimer();
			this.dispatchEvent(new Event(EVENT_ANIMATION_STOP));
		}
		
		public function stopPlaying():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, playHandler);
			stopTimer();
			time = _savedTime;
			this.dispatchEvent(new Event(EVENT_ANIMATION_STOP));
		}
		
		public function startRecording():void
		{
			_timer.addEventListener(TimerEvent.TIMER, recordHandler);
			startTimer();
			this.dispatchEvent(new Event(EVENT_RECORDING_START));
		}
		private function recordHandler(event:TimerEvent):void 
		{
			var now_sysTime:Number = (new Date()).time;
			var now_kskTime:Number =  _startKSKTime + (now_sysTime - _startSysTime);
			while(now_kskTime > maxTime)
				maxTime = maxTime + KAppState.DEFAULT_MAX_TIME;
			time = now_kskTime;
		}
		
		public function stopRecording():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, recordHandler);
			stopTimer();
			this.dispatchEvent(new Event(EVENT_RECORDING_STOP));
		}
		
		private function startTimer():void
		{
			_startSysTime = (new Date()).time;
			_startKSKTime = _time;
			_timer.start();
		}
		
		private function stopTimer():void
		{
			_timer.stop();
			time = nextNearestKey(time);
			_startSysTime = -1;
			_startKSKTime = -1;
		}
		
		public function timerReset(newAppStateTime:Number):void
		{
			_startSysTime = (new Date()).time;
			_startKSKTime = newAppStateTime;
			time = newAppStateTime;
		}
		
		public function undo():void
		{ 
			if(!_undoEnabled)
				return;
			
			var undoOperation:IModelOperation = _undoStack.pop();
			if(undoOperation != null)
			{				
				undoOperation.undo();
				_redoStack.push(undoOperation);
				_fireUndoRedoEvent();
				_fireFacadeUndoRedoModelChangedEvent();
				fireEditEnabledChangedEvent();
				fireGroupingEnabledChangedEvent();
			}					
		}
		
		public function redo():void
		{
			if(!_redoEnabled)
				return;

			var redoOperation:IModelOperation = _redoStack.pop();
			if(redoOperation != null)
			{			
				redoOperation.apply();
				_undoStack.push(redoOperation);									
				fireGroupingEnabledChangedEvent();
				fireEditEnabledChangedEvent();
				_fireFacadeUndoRedoModelChangedEvent();
				_fireRedoEvent()			
				_fireUndoRedoEvent();					
			}			
		}
		
		public function addOperation(operation:IModelOperation):void
		{
			if(!_undoEnabled || !_redoEnabled)
				return;
			
			_undoStack.push(operation);
			_redoStack.length = 0;
			_fireUndoRedoEvent();
		}
		
		public function clearStacks():void
		{
			_undoStack = new Vector.<IModelOperation>();
			_redoStack = new Vector.<IModelOperation>();
			_fireUndoRedoEvent();
		}
		
		[Bindable]
		public function get time():Number
		{
			return _time;
		}
		
		public static function getCurrentTime():Number
		{
			return _time;
		}
		
		public function set time(value:Number):void
		{
			if(_time != value)
			{
				var event:KTimeChangedEvent = new KTimeChangedEvent(_time, value);
				_time = value;
				this.dispatchEvent(event);
			}
		}
		
		public function get prevSelection():KSelection
		{	
			
			return _prevSelection;			
		}
		
		public function get selection():KSelection
		{	
			
			return _selection;			
		}
		
		public function set interactingSelection(value:KSelection):void
		{			
			var oldSelection:KSelection = _selection;
			_selection = value;
			
			_fireSelectionChangedEvent(
				KSelectionChangedEvent.EVENT_SELECTION_CHANGING,oldSelection,_selection);
		}
		
		public function set selection(value:KSelection):void
		{	
			_prevSelection = _selection;
		
			if(_prevSelection)
				if(prevSelection.fullObjectSet)
					_prevSelection.objects = _prevSelection.fullObjectSet;
			_selection = value;			
			
			_fireSelectionChangedEvent(
				KSelectionChangedEvent.EVENT_SELECTION_CHANGED,_prevSelection,_selection);
		}
		
		public function get userSetCenterOffset():Point
		{
			if(_selection)
				return _selection.userSetHandleOffset;
			else
				return new Point();
		}
		
		public function set userSetCenterOffset(value:Point):void
		{
			if(_selection)
				_selection.userSetHandleOffset = value;
			this.dispatchEvent(new Event(EVENT_HANDLE_CENTER_CHANGED));
		}
		
		[Bindable(event='UndoRedoEnabledChanged')]
		public function get undoEnabled():Boolean
		{	
			return _undoEnabled && _undoStack.length != 0;
		}
		
		public function set undoEnabled(undoEnabled:Boolean):void
		{
			_undoEnabled = undoEnabled;
		}
		
		[Bindable(event='UndoRedoEnabledChanged')]
		public function get redoEnabled():Boolean
		{
			return _redoEnabled && _redoStack.length != 0;
		}
		
		public function set redoEnabled(redoEnabled:Boolean):void
		{
			_redoEnabled = redoEnabled;
		}
		
		public function get ctrlEnabled():Boolean
		{
			return _ctrlEnabled;
		}
		
		public function set ctrlEnabled(setBoolean:Boolean):void
		{
			_ctrlEnabled = setBoolean;
		}
		
		public function get altEnabled():Boolean
		{
			return _altEnabled;
		}
		
		public function set altEnabled(setBoolean:Boolean):void
		{
			_altEnabled = setBoolean;
		}
		
		public function get pgDownEnabled():Boolean
		{
			return _pgDownEnabled;
		}
		
		public function set pgDownEnabled(setBoolean:Boolean):void
		{
			_pgDownEnabled = setBoolean;
		}
		
		public function get pgUpEnabled():Boolean
		{
			return _pgUpEnabled;
		}
		
		public function set pgUpEnabled(setBoolean:Boolean):void
		{
			_pgUpEnabled = setBoolean;
		}

		[Bindable(event='editEnabledChanged')]
		public function get copyEnabled():Boolean
		{	
			return _selectedLength() > 0;
		}
		
		[Bindable(event='editEnabledChanged')]
		public function get pasteEnabled():Boolean
		{	
			return _pasteEnabled;
		}
		
		public function set pasteEnabled(enabled:Boolean):void
		{	
			_pasteEnabled = enabled;
		}
		
		[Bindable(event='groupingEnabledChanged')]
		public function get groupEnabled():Boolean
		{	
			return groupingMode != GROUPING_IMPLICIT_DYNAMIC && _selectedLength() > 1;
		}
		
		[Bindable(event='groupingEnabledChanged')]
		public function get ungroupEnabled():Boolean
		{	
			return groupingMode != GROUPING_IMPLICIT_DYNAMIC && 
				_ungroupEnabled && _selectedLength() > 0;
		}

		public function set ungroupEnabled(enabled:Boolean):void
		{
			_ungroupEnabled = enabled;
		}
		
		public function set groupSelectMode(value:String):void
		{	
			_groupSelectMode = value;	
			
			if(value == SELECTION_GROUP_AND_STROKE)
				cyclingEnabled = true;
			else
				cyclingEnabled = false;
			
		}
		
		public function get groupSelectMode():String
		{
			return _groupSelectMode;	
		}
		
		public function get debugSelection():KModelObjectList
		{
			return _debugSelection;
		}
		
		public function set debugSelection(value:KModelObjectList):void
		{
			var oldDebug:KModelObjectList = _debugSelection;
			_debugSelection = value;
			this.dispatchEvent(new KDebugHighlightChanged(oldDebug, _debugSelection));
		}
		
		public static function kskTime(keyIndex:int):Number
		{
			return Math.ceil(keyIndex * ANIMATION_INTERVAL);
		}
		
		public static function indexOf(kskTime:Number):int
		{
			return kskTime / ANIMATION_INTERVAL;
		}
		
		public static function nextKey(kskTime:Number):int
		{
			var nextIndex:int = KAppState.indexOf(kskTime);//kskTime / ANIMATION_INTERVAL;
			nextIndex ++;
			return KAppState.kskTime(nextIndex);
		}
		
		public static function previousKey(kskTime:Number):int
		{
			var preIndex:int = KAppState.indexOf(kskTime);//kskTime / ANIMATION_INTERVAL;
			preIndex --;
			return KAppState.kskTime(preIndex);
		}
		
		/**
		 * Get next frame time of a K-Sketch time. If the K-Sketch time is 
		 * just a frame time(63,125,188,...), then return this frame time.
		 * @param kskTime K-Sketch time
		 * @return Nearest frame time from kskTime 
		 */		
		public static function nextNearestKey(kskTime:Number):int
		{
			var index:int = KAppState.indexOf(kskTime);//kskTime / ANIMATION_INTERVAL;
			if(kskTime == KAppState.kskTime(index))//Math.ceil(ANIMATION_INTERVAL * index))
				return kskTime;
			else
				return KAppState.kskTime(++index);
		}
		
		public static function previousNearestKey(kskTime:Number):int
		{
			var index:int = KAppState.indexOf(kskTime);//kskTime / ANIMATION_INTERVAL;
			if(kskTime == KAppState.kskTime(index))//Math.ceil(ANIMATION_INTERVAL * index))
				return kskTime;
			else
				return KAppState.kskTime(--index);
		}
		
		public function fireEditEnabledChangedEvent():void
		{
			this.dispatchEvent(new Event(EVENT_EDIT_ENABLED_CHANGED));			
		}
		
		public function fireGroupingEnabledChangedEvent():void
		{
			this.dispatchEvent(new Event(EVENT_GROUPING_ENABLED_CHANGED));			
		}
		
		public function _fireUndoRedoEvent():void
		{
			this.dispatchEvent(new Event(EVENT_UNDO_REDO_ENABLED_CHANGED));			
		}
		
		public function _fireUndoEvent():void
		{
			this.dispatchEvent(new Event(EVENT_UNDO_ENABLED_CHANGED));
		}
		
		public function _fireRedoEvent():void
		{
			this.dispatchEvent(new Event(EVENT_REDO_ENABLED_CHANGED));			
		}
		
		public function _fireFacadeUndoRedoModelChangedEvent():void
		{
			//		   facade.dispatchEvent(new KModelEvent(KModelEvent.EVENT_MODEL_UPDATED));
		}
		
		private function _fireSelectionChangedEvent(event_type:String,old:KSelection,current:KSelection):void
		{
			this.dispatchEvent(new KSelectionChangedEvent(event_type, old, current));
		}
		
		private function _selectedLength():int
		{
			return selection != null && selection.objects != null ?
				selection.objects.length() : -1;
		}		
	}
}
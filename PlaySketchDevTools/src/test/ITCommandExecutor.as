/**------------------------------------------------
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 
*-------------------------------------------------*/
package test
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import sg.edu.smu.ksketch.defines.KWidgetEvent;
	import sg.edu.smu.ksketch.interactor.KLoggerCommandExecutor;
	import sg.edu.smu.ksketch.logger.KLogger;

	public class ITCommandExecutor extends KLoggerCommandExecutor
	{
		private static const UI_DELAY:Number = 300;
		
		private var _eventDispatcher:EventDispatcher;
		private var _testUtil:ITTestUtil;
		private var _isPausing:Boolean;
		private var _uiTimer:Timer;
		
		public function ITCommandExecutor(dispatcher:EventDispatcher)
		{
			super(null,null,null);
			_eventDispatcher = dispatcher;
			_isPausing = false;
			_testUtil = new ITTestUtil();
			_uiTimer = new Timer(UI_DELAY, 0);
			_uiTimer.addEventListener(TimerEvent.TIMER, _commandFinished);
			restartTest();
		}

		public function restartTest():void
		{
			if(_uiTimer.running)
				_uiTimer.stop();
			_testUtil.startApplication();
			_canvas = application.appCanvas;
			_appState = application.appState;
			_facade = application.facade;
		}
		
		public function get application():PlaySketchCanvas
		{
			return _testUtil.application;
		}
		
		public function generateCommandList(xml:XML):XMLList
		{
			var pauseAll:Boolean = xml.child(KLogger.PAUSEALL).length() != 0;
			var delayAll:Boolean = xml.child(KLogger.DELAYALL).length() != 0;
			var xmlCommands:XML = new XML("<"+KLogger.COMMANDS+"/>");
			var time:String;
			if(delayAll)
				time = xml.child(KLogger.DELAYALL).attribute(KLogger.DELAYALL_TIME)[0];
			
			var list:XMLList = xml.children();
			
			for each(var node:XML in list)
			{
				if(node.name().toString() != KLogger.PAUSEALL && node.name().toString() !=  KLogger.DELAYALL)
				{
					if(pauseAll)
					{
						if(node.name().toString() != KLogger.PAUSE)
						{
							xmlCommands.appendChild(node);
							xmlCommands.appendChild(new XML("<"+KLogger.PAUSE+"/>"));
						}
					}
					else
					{
						xmlCommands.appendChild(node);
						if(delayAll)
						{
							var delayNode:XML = new XML("<"+KLogger.DELAY+"/>");
							delayNode.@[KLogger.DELAY_TIME] = time;
							xmlCommands.appendChild(delayNode);
						}	
					}
				}
			}
			return xmlCommands.children();
		}
		
		/**
		 * Execute a single line command.
		 * @param command Integration test command in an XML format. All supported tag names
		 * 
		 */		
		public function executeCommand(command:XML):void
		{
			var name:String;
			switch (command.name().toString())
			{
				case KLogger.BTN_NEW:
				case KLogger.BTN_NEXT:
				case KLogger.BTN_PREVIOUS:
				case KLogger.BTN_FIRST:
					doButtonCommand(command.name().toString());
					_uiTimer.start();
					_commandFinished();
					break;
				case KLogger.BTN_LOAD:
					_testUtil.addFileLoadedListener(_commandFinished);
					doButtonCommand(KLogger.BTN_LOAD);
					break;
				case KLogger.BTN_SAVE:
					_testUtil.addFileSavedListener(_commandFinished);
					doButtonCommand(KLogger.BTN_SAVE);
					break;
				case KLogger.CHANGE_TIME:
					application.appState.time = new Number(
						command.attribute(KLogger.CHANGE_TIME_TO).toString());
					_commandFinished();
					break;				
				case KLogger.BTN_UNDO:
				case KLogger.BTN_REDO:
					_uiTimer.start();
					doButtonCommand(command.name().toString());
					break;
				case KLogger.INTERACTION_DRAW:
					_uiTimer.start();
					_draw(command);
					break;
				case KLogger.INTERACTION_TRANSLATE:
					_uiTimer.start();
					_transform(KWidgetEvent.DOWN_TRANSLATE,command);
					break;
				case KLogger.INTERACTION_ROTATE:
					_uiTimer.start();
					_transform(KWidgetEvent.DOWN_ROTATE,command);
					break;
				case KLogger.INTERACTION_SCALE:
					_uiTimer.start();
					_transform(KWidgetEvent.DOWN_SCALE,command);
					break;
				case KLogger.INTERACTION_DRAG_CENTER: 
					// tap will not be execute since move center interaction will first tap on center region automatically
					_commandFinished();
					break;
				case KLogger.INTERACTION_MOVE_CENTER:
					_uiTimer.start();
					_moveCenter(command);
					break;
				case KLogger.INTERACTION_GESTURE:
					_uiTimer.start();
					_gesture(command);
					break;
				case KLogger.ASSERT_MATRIX:
					_testUtil.assertMatrix(command);
					_commandFinished();
					break;
				case KLogger.ASSERT_KEYFRAME:
					_testUtil.assertKeyframe(command);
					_commandFinished();
					break;
				case KLogger.DELAY:
					var timer:Timer = new Timer(command.attribute(KLogger.DELAY_TIME), 1);
					timer.addEventListener(TimerEvent.TIMER, _commandFinished);
					timer.start();
					break;
				case KLogger.PAUSE:
					_isPausing = true;
					break;
				default:
					throw new Error("Unsupported tag name: " + command.name().toString());
			}
		}
		
		public function resume():void
		{
			if(_isPausing == true)
			{
				_isPausing = false;
				_commandFinished();
			}
		}
		
		public function set testUtil(value:ITTestUtil):void
		{
			_testUtil = value;
		}
		
		private function _commandFinished(event:Event=null):void
		{
			if(_isPausing)
				_isPausing = false;
			if(_uiTimer.running)
				_uiTimer.stop();
			_eventDispatcher.dispatchEvent(new Event(PlaySketch_Test.COMMAND_FINISHED));
		}
								
		private function _draw(commandNode:XML):void
		{
			var name:String = commandNode.attribute(KLogger.ASSERTION_OBJECT_NAME)[0];
			if(name != null && name != "")
				_testUtil.nameToBeSet = name;
			_interact(commandNode);	
		}
					
		private function _moveCenter(commandNode:XML):void
		{
			var timer:Timer = new Timer(100, 1);
			timer.addEventListener(TimerEvent.TIMER, function (event:Event):void
			{
				_interact(commandNode);
			});
			timer.start();
			_tapCenter();
		}		
	}
}
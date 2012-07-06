/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.interactor
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import mx.controls.Button;
		
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.components.KFilteredLoopView;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.geom.KTimestampPoint;
	import sg.edu.smu.ksketch.gestures.GestureDesign;
	import sg.edu.smu.ksketch.gestures.Library;
	import sg.edu.smu.ksketch.gestures.PigtailConflictReducer;
	import sg.edu.smu.ksketch.gestures.PigtailDetector;
	import sg.edu.smu.ksketch.gestures.RecognizeResult;
	import sg.edu.smu.ksketch.gestures.Recognizer;
	import sg.edu.smu.ksketch.logger.ILoggable;
	import sg.edu.smu.ksketch.logger.KGestureLog;
	import sg.edu.smu.ksketch.logger.KGestureSubLog;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.logger.KPostGestureLog;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KMathUtil;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	// change the color of history loop while pausing
	public class KGestureRecognizer implements IComplexInteractor
	{
		private static const MODE_PRE_GESTURE:String = "PRE_GESTURE";
		private static const MODE_SELECTING:String = "SELECTING";
		private static const MODE_PIGTAIL:String = "PIGTAIL";
		private static const MODE_DELAY_AFTER_PAUSE:String = "TEMP";
		
		[Bindable]
		public static var PEN_PAUSE_TIME:Number = 60;
		private static const TIMEOUT_DELAY:Number = 1000;
		private static const PEN_TOGGLE_ASPECT_RATIO:Number = 0.95;
		
		private static const _preDesign1Lib:Library = new Library(GestureDesign.design1, true, false);
		private static const _preDesign2Lib:Library = new Library(GestureDesign.design2, true, false);
		private static const _postDesign1Lib:Library = new Library(GestureDesign.design1, false, true);
		private static const _postDesign2Lib:Library = new Library(GestureDesign.design2, false, true);
		
		/*
		gesture design3
		*/
		private static const _preDesign3Lib:Library = new Library(GestureDesign.design3, true, false);
		private static const _postDesign3Lib:Library = new Library (GestureDesign.design3, false, true);
		
		/*
		gesture design4
		*/
		private static const _preDesign4Lib:Library = new Library (GestureDesign.design4, true, false);
		private static const _postDesign4Lib:Library = new Library (GestureDesign.design4, false, true);
		
		
		private var _canvas:KCanvas;
		private var _appState:KAppState;
		
		private var _timer:Timer;
		private var _pigtailDelay:Timer;
		private var _timeoutTimer:Timer;
		
		private var _selectInteractor:KLoopSelectInteractor;
		
		private var _preSelectionRecognizer:Recognizer;
		private var _postSelectionRecognizer:Recognizer;
		
		// need to be cleared when interaction finished
		private var _savedSelection:KSelection;
		
		private var _guess:KSelection;
		private var _lastLoopPoint:Point;
		
		private var _gesture:Vector.<Point>;
		private var _postGesture:Vector.<KTimestampPoint>;
		// --- need to be cleared
		
		private var _pigtailDetector:PigtailDetector;
		private var _intelliGuess:KIntelligentArbiter;
		private var _simpleGuess:KSimpleArbiter;
		private var _executor:KCommandExecutor;
		private var _tooglePen:Boolean;
		
		private var _log:KGestureLog;
		
		private var _mode:String;
		
		private var _tempView:KFilteredLoopView;
		
		// variables that used for changing the color of history loop
		private var _tempLoopPoint:KFilteredLoopView;
		
		private var _historyLoop:Vector.<Point>;
		
		private var _historyShape:Shape;
		
		//add a button while pausing
		private var _button:Button;
		
		// white color for new loop
		private static const NEW_COLOR:uint = 0xdbd4d6
		
		// pre-defined threshold which prevents the color flashing of history loop. 
		private static const DEFAULT_THRESHOLD:uint = 15;
		
		//used to record every point in selection loop
		private var _selectionPigtail:Vector.<KTimestampPoint>;
		
		//	private var _selectionPigtailClone:Vector.<KTimestampPoint>;
		
		//used to detect pigtail between selection loop and pigtail loop
		private var _selectionPigtailDetector:PigtailDetector;
		
		//used to record if a valid flick gesture has been mounted
		private var _validFlick:Boolean;
		
		//used to distinguish the pigtial and flick gesture after pausing
		private var _pigtailReducer:PigtailConflictReducer;
		
		// used for switching the way of showing history loop
		public static var name:String = "change color";
		
		public function KGestureRecognizer(facade:KModelFacade, appState:KAppState, 
										   canvas:KCanvas, executor:KCommandExecutor, 
										   selectInteractor:KLoopSelectInteractor)
		{
			super();
			_appState = appState;
			_canvas = canvas;
			_executor = executor;
			
			// Change the color of loop stroke after pausing from red to oranger
			//	_tempView = new KFilteredLoopView(0xff0000);
			
			_tempView = new KFilteredLoopView(0xff0000);
			
			_intelliGuess = new KIntelligentArbiter(facade.root);
			_simpleGuess = new KSimpleArbiter(facade.root);
			_selectInteractor = selectInteractor;
			
			_preSelectionRecognizer = new Recognizer(getLib(_appState.gestureDesignName, true));
			_postSelectionRecognizer = new Recognizer(getLib(_appState.gestureDesignName, false));
			
			_pigtailDetector = new PigtailDetector();
			
			_timer = new Timer(PEN_PAUSE_TIME, 1);
			_timeoutTimer = new Timer(TIMEOUT_DELAY, 1);
			_tooglePen = false;
			
			_tempLoopPoint= new KFilteredLoopView();
			_historyLoop = new Vector.<Point>();
			_historyShape = new Shape();
			
			_selectionPigtail = new Vector.<KTimestampPoint>;
			//_selectionPigtailClone = new Vector.<KTimestampPoint>;
			_selectionPigtailDetector = new PigtailDetector();
			// set to be false at the initial stage; After a flick gesture is mounted, it's changed to true
			_validFlick = false;
			
			_pigtailReducer = new PigtailConflictReducer();
			_button = new Button();
		}
		
		private static function getLib(designName:String, preSelection:Boolean):Library
		{
			if(designName == GestureDesign.design1.name)
			{
				if(preSelection)
					return _preDesign1Lib;
				else
					return _postDesign1Lib;
			}
			else if(designName == GestureDesign.design2.name)
			{
				if(preSelection)
					return _preDesign2Lib;
				else
					return _postDesign2Lib;
			}
			else if(designName == GestureDesign.design3.name)
			{
				if(preSelection)
					return _preDesign3Lib;
				else
					return _postDesign3Lib;
			}
			else if(designName == GestureDesign.design4.name)
			{
				if(preSelection)
					return _preDesign4Lib;
				else
					return _postDesign4Lib;
			}
				
			else
				throw new Error("Undefined gesture design set: "+designName);
		}
		
		public function get decorated():IInteractor
		{
			return _selectInteractor;
		}
		
		public function activate():void
		{
			decorated.activate();
			// show the new loop
			_canvas.gestureLayer.addChild(_historyShape);
			_canvas.contentContainer.addChild(_tempView);
		}
		
		public function deactivate():void
		{
			decorated.deactivate();
			_canvas.contentContainer.removeChild(_tempView);
			
			//remove the new loop
			_canvas.gestureLayer.removeChild(_historyShape);
		}
		
		public function begin(point:Point):void
		{
			_mode = MODE_PRE_GESTURE;
			
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			
			_appState.gesture = "";
			_appState.score = 0;
			_appState.selectedItem = "";
			
			_pigtailDetector.clearPoints(); //clear the points for the pigtail detector
			
			_savedSelection = _appState.selection;
			_preSelectionRecognizer.library = getLib(_appState.gestureDesignName, true);
			_postSelectionRecognizer.library = getLib(_appState.gestureDesignName, false);
			
			if(_appState.cyclingEnabled)
				_selectInteractor.arbiter = _intelliGuess;
			else
				_selectInteractor.arbiter = _simpleGuess;
			
			//record history point
			_tempLoopPoint.record(point);
			
			decorated.begin(point);
			
			_gesture = new Vector.<Point>();
			_gesture.push(point);
			_tooglePen = false;
			
			_lastLoopPoint = point;
			
			//record every point in the selection loop with time stamp
			_selectionPigtail.push(new KTimestampPoint(new Date().time, point.x, point.y));
			
			//_selectionPigtailClone.push(new KTimestampPoint(new Date().time, point.x, point.y));
		}
		
		public function update(point:Point):void
		{
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
			
			if(_mode == MODE_PIGTAIL)
				update_pigtail(point);
			else if(_mode == MODE_DELAY_AFTER_PAUSE)
				update_delayAfterPause(point);
			else if(_mode == MODE_PRE_GESTURE)
				update_pregesture(point);
			else
				update_selecting(point);
		}
		
		private function enterPigtailMode(point:Point, loop:Vector.<KTimestampPoint>):void
		{
			if(_log != null)
			{
				var subLog:KGestureSubLog = new KGestureSubLog(loop, KPlaySketchLogger.PIGTAIL, new Date());
				_log.addSubLog(subLog);
			}
			
			_mode = MODE_PIGTAIL;
			_pigtailDetector.clearPoints();
			
			//clear the pigtail of selection loop 
			_selectionPigtailDetector.clearPoints();
			
			_executor.doGestureCommand(KCommandExecutor.PIGTAIL_CONTEXT_MENU, point);
		}
		
		/*** Updates the recogniser when in pre-selecture gesture Mode
		 * (1) Detects a pigtail when performing any pre selection gestures - 
		 * 		and opens pen toogle menu when a pigtail(in any orientation) is detected
		 * (2) If no pigtail is detected, $N recogniser is activated to check with the 
		 * 		pre-selection gesture library.
		 * @param point		
		 */
		private function update_pregesture(point:Point):void
		{
			if(_timer.running)
				_timer.stop();
			
			//record history point
			_tempLoopPoint.record(point);
			
			//record every point in selection loop with timestamp
			_selectionPigtail.push(new KTimestampPoint(new Date().time, point.x, point.y));
			
			//_selectionPigtailClone.push(new KTimestampPoint(new Date().time, point.x, point.y));
			
			decorated.update(point);
			
			_lastLoopPoint = point;
			
			if(_appState.selection != null && _appState.selection.objects.length() != 0)
			{
				_gesture = null;
				_mode = MODE_SELECTING;
			}
			else
			{
				_gesture.push(point);
				
				//for pen toggle menu
				//check for pigtail loop if there is no selection
				var loop:Vector.<KTimestampPoint> = _pigtailDetector.newPoint(point);
				
				if(loop != null){
					
					//Aspect ratio check
					//Pass if height of (bounding box/width of bounding box) > 1
					var loopBoundingBox:Rectangle = _pigtailDetector.pigtailBoundingBox(loop);
					
					var aspectRatio:Number = (loopBoundingBox.bottom - loopBoundingBox.top)/(loopBoundingBox.right - loopBoundingBox.left);
					
					//Check if aspect ratio is greater than a specified ratio
					if(aspectRatio > PEN_TOGGLE_ASPECT_RATIO){
						
						//Check to make sure that the intersection point is above the starting point.						
						if(_gesture[0].y > _pigtailDetector.intersectionPoint.y){
							
							//set _tooglePen to true to disable further $N recogniser checks
							//Another way would be to remove the NAME_PRE_SHOW_CONTEXT_MENU template in the template library
							//But the template may have other uses
							_tooglePen = true;
							
							//fire menu pen selection menu here
							_executor.doGestureCommand(GestureDesign.NAME_PRE_SELECT_PEN, point);					
						}
					}
				}
			}
		}
		
		private function update_selecting(point:Point):void
		{
			_lastLoopPoint = point;
			
			//record every point in selection loop with timestamp
			_selectionPigtail.push(new KTimestampPoint(new Date().time, point.x, point.y));
			
			//_selectionPigtailClone.push(new KTimestampPoint(new Date().time, point.x, point.y));
			
			if(_timer.running)
				_timer.stop();
			
			if(_guess != null)
				_appState.interactingSelection = _guess;
			else
				// revised
			{
				//record history point
				_tempLoopPoint.record(point);
				
				decorated.update(point);
				
				if(_appState.selection == null || _appState.selection.objects.length() == 0)
					return;
				
				// if with selection
				// detect pigtail
				var loop:Vector.<KTimestampPoint> = _pigtailDetector.newPoint(point);
				if(loop != null){
					enterPigtailMode(point, loop);
				}else if(_appState.cyclingEnabled)
				{
					if(_postGesture != null)
						_postGesture.push(new KTimestampPoint(new Date().time, point.x, point.y));
					// restart timing
					_timer = new Timer(PEN_PAUSE_TIME, 1);
					_timer.addEventListener(TimerEvent.TIMER, onPenPaused);
					_timer.start();
				}
			}
			
		}
		private function update_delayAfterPause(point:Point):void
		{
			
			if(_timer.running)
				_timer.stop();
			
			if(!_timeoutTimer.running) // just start to move after pausing
			{				
				_timeoutTimer = new Timer(TIMEOUT_DELAY, 1);
				_timeoutTimer.addEventListener(TimerEvent.TIMER, function(event:Event):void
				{	
					if(_guess == null)
					{
						for each(var p:Point in _postGesture)
						{
							//record history point
							_tempLoopPoint.record(p);
							
							decorated.update(p);
						}
					}
					
					_tempView.clear();
					_postGesture = null;
					_mode = MODE_SELECTING;
				});
				_timeoutTimer.start();
			}
			
			_tempView.add(point);
			var loop:Vector.<KTimestampPoint> = _pigtailDetector.newPoint(point);
			
			var noTimestampLoop:Vector.<Point> = new Vector.<Point>();
			
			if(loop != null) 
			{
				for(var y:uint=0;y<loop.length;y++)
				{
					var point4:KTimestampPoint = loop[y];
					var noTimestampPoint:Point = new Point(point4.x,point4.y)
					noTimestampLoop.push(noTimestampPoint);
				}
				_pigtailReducer.loop = noTimestampLoop;
				
				if(_pigtailReducer.proceed())
				{
					_timeoutTimer.stop();
					enterPigtailMode(point, loop);
				}	
			}
			else
			{
				_postGesture.push(new KTimestampPoint(new Date().time, point.x, point.y));
				
				var selectionLoop:Vector.<KTimestampPoint>;
				
				if(_validFlick) //if flick gesture has been mounted
				{    
				/*	
					call the method, newPoint1, to decide if selection loop is intersected with pigtail loop
					Caution: DO NOT call the method, newPoint2 if flick gesture has been mount because the line
					(its start point is the end point of selection loop and the end point is the start point of pigtail loop)
					is ALWAYS intersected with pigtial loop. It causes the BUG that pigtail is detected although there is no 
					any interesection between selection loop and pigtial loop
				*/
					selectionLoop = _selectionPigtailDetector.newPoint1(point,_selectionPigtail.length);
				}
				else // if flick gesture has never been mounted
				{
					selectionLoop = _selectionPigtailDetector.newPoint2(point);
				}
				
				
				if(selectionLoop !=null)
				{
					_timeoutTimer.stop();
					enterPigtailMode(point,selectionLoop);
				}
				else
				{			
					//trace("selection loop is null" + point.x +" "+ point.y);
					
					// restart timing
					_timer = new Timer(PEN_PAUSE_TIME, 1);
					_timer.addEventListener(TimerEvent.TIMER, onPenPaused);
					_timer.start();
				}
				//clear the new loop
				if(_postGesture != null)
				{
					var distance:Number = KMathUtil.distanceOf(point, _postGesture[0]);
					/*
					 if the pen-movement is longer than the default threshold, clean the history loop; 
					 if not, do not not clear the history loop because it may result from the slight 
					 pen movement while pausing it prevents the color flashing of history loop at the pausing point
					*/
					if(distance > DEFAULT_THRESHOLD)
						_historyShape.graphics.clear();
				}
			}
		}
		
		private function update_pigtail(point:Point):void
		{
		}
		
		public function end(point:Point):void
		{
			update(point);
			
			_tempView.clear();
			_pigtailDetector.clearPoints();
			
			//clear the _points in the _selectionPigtailDetector
			_selectionPigtailDetector.clearPoints();
			
			//clear the selection pigtail
			_selectionPigtail = new Vector.<KTimestampPoint>();
			
			/*reset to be false. 
			 It allows that a pigtail can be detected while pigtail loop is 
			 intersected with selection loop at the new selection part even
			 if a flick gesture has been mounted before pening-up
			*/
			_validFlick = false;
			
			_tempLoopPoint = new KFilteredLoopView();
			
			if(_timer.running)
				_timer.stop();
			
			if(_mode == MODE_PIGTAIL)
				end_pigtail(point);
			else if(_mode == MODE_PRE_GESTURE)
				end_pregesture(point);
			else if(_mode == MODE_SELECTING)
				end_selecting(point);
			else
				end_delayAfterPause(point);
			
			_gesture = null;
			_postGesture = null;
			_guess = null;
			_lastLoopPoint = null;
			_savedSelection = null;
			
			if(_log != null)
			{
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
				_log = null;
			}
		}
		
		private function end_pigtail(point:Point):void
		{
			decorated.end(_lastLoopPoint);
			
			// clear new loop
			_historyShape.graphics.clear();
			
			if(_guess != null)
				_appState.selection = _guess;
			else
				_appState.selection = _appState.selection;
			if(_log != null && _appState.selection != null)
				_log.selected = _appState.selection.objects;
		}
		
		private function end_pregesture(point:Point):void
		{
			decorated.end(point);
			
			// clear new loop
			_historyShape.graphics.clear();
			
			_appState.selection = _savedSelection;
			
			var result:RecognizeResult = _preSelectionRecognizer.recognizeGesture(_gesture);
			
			// Need to log before doGestureCommand() so that it will be log by executor.
			if(_log != null)
				_log.preGestureRecognized = result;
			
			if(result != RecognizeResult.UNDEFINED)
			{
				_appState.gesture = result.type;
				_appState.score = result.score;
				_executor.doGestureCommand(result.type, point);
			}
		}
		
		private function end_selecting(point:Point):void
		{
			decorated.end(point);
			
			// clear new loop
			_historyShape.graphics.clear();
			
			if(_guess != null)
				_appState.selection = _guess;
			
			if(_log != null)
			{
				if(_appState.selection != null)
					_log.selected = _appState.selection.objects;
			}
			
			_intelliGuess.clear();
		}
		
		private function end_delayAfterPause(point:Point):void
		{
			
			if(_timeoutTimer.running)
				_timeoutTimer.stop();
			
			decorated.end(_lastLoopPoint);
			
			// clear new loop
			_historyShape.graphics.clear();
			
			_tempView.clear();
			
			if(_log != null)
			{
				if(_appState.selection != null)
					_log.selected = _appState.selection.objects;
			}
			
		}
		
		private function onPenPaused(event:TimerEvent):void //event:TimerEvent
		{	
			if(_timeoutTimer.running)
				_timeoutTimer.stop();
			
			var buttonPosition:Point = new Point();
			
			if(_postGesture != null) // not the first pause
			{
				var result:RecognizeResult = _postSelectionRecognizer.recognizeGesture(
					Vector.<Point>(_postGesture));
				
				buttonPosition.x = _postGesture[_postGesture.length-1].x-20;
				buttonPosition.y = _postGesture[_postGesture.length-1].y-25;
				
				if(result != RecognizeResult.UNDEFINED)
				{										
					_appState.gesture = result.type;
					_appState.score = result.score;
					
					var selection:KModelObjectList;
					if(result.type == GestureDesign.NAME_POST_CYCLE_NEXT)
						selection = _intelliGuess.cycleNext(_selectInteractor.portions, _appState.time);
					else if(result.type == GestureDesign.NAME_POST_CYCLE_PREV)
						selection = _intelliGuess.cyclePrevious(_selectInteractor.portions, _appState.time);
					else
						throw new Error("Unsupported Gesture: "+result.type);
					_guess = new KSelection(selection, _appState.time);
					_appState.interactingSelection = _guess;
					
					// show the new loop
					if(true)
					{
						for(var i:uint=0;i<_tempLoopPoint.historyPoints.length;i++)
						{
							_historyShape.graphics.beginFill(NEW_COLOR);
							_historyShape.graphics.lineStyle(1,NEW_COLOR);
							_historyShape.graphics.drawRect(
								_tempLoopPoint.historyPoints[i].x - _tempLoopPoint.radius, 
								_tempLoopPoint.historyPoints[i].y - _tempLoopPoint.radius, 
								_tempLoopPoint.radius * 2, _tempLoopPoint.radius * 2);
						}
					}
					
					/*At first, set the _validFlick to be true
					*Second, clear the _points in the _selectionPigtailDetector 
					*At last, push all the points in selection loop to _points in _selectionPigtailDetector
					*/
					_validFlick = true;
					_selectionPigtailDetector.clearPoints();
					for(var q:uint=0;q<_selectionPigtail.length;q++)
					{
						var point:KTimestampPoint = _selectionPigtail[q];
						_selectionPigtailDetector.points.push(point);
					}
					
				}
				else
				{
					if(_guess == null)
					{
						for each(var p:Point in _postGesture)
						{						
							//record history point
							_tempLoopPoint.record(p);
							
							decorated.update(p);
							
						}
					}
					
					// show the new loop
					for(var k:uint=0;k<_tempLoopPoint.historyPoints.length;k++)
					{
						_historyShape.graphics.beginFill(NEW_COLOR);
						_historyShape.graphics.lineStyle(1,NEW_COLOR);
						_historyShape.graphics.drawRect(
							_tempLoopPoint.historyPoints[k].x - _tempLoopPoint.radius, 
							_tempLoopPoint.historyPoints[k].y - _tempLoopPoint.radius, 
							_tempLoopPoint.radius * 2, _tempLoopPoint.radius * 2);
					}
					
					/* if flick gesture has been mounted, clear the old _points 
					(because it contains all the points that consists of flick gesture) 
					and then push a new vector into it
					*/
					if(_validFlick)
					{
						_selectionPigtailDetector.clearPoints();
						
						for(var m:uint=0;m<_selectionPigtail.length;m++)
						{
							var point1:KTimestampPoint = _selectionPigtail[m];
							_selectionPigtailDetector.points.push(point1);
						}
						
					}
					else
					{
						for(var t:uint=0;t<_postGesture.length;t++)
						{
							var point4:KTimestampPoint = _postGesture[t];
							_selectionPigtail.push(point4);
						}
					}
				}
				
				if(_log != null)
				{
					var subLog:KGestureSubLog;
					if(result != RecognizeResult.UNDEFINED)
						subLog = new KPostGestureLog(result, new Date(), 
							_postGesture, _appState.selection.objects);
					else
						subLog = new KGestureSubLog(_postGesture, KPlaySketchLogger.UNDEFINED, new Date());
					_log.addSubLog(subLog);
				}
			}
			else
			{
				buttonPosition.x = _lastLoopPoint.x-20;
				buttonPosition.y = _lastLoopPoint.y-25;
				
				if(true)
				{
					for(var j:uint=0;j<_tempLoopPoint.historyPoints.length;j++)
					{	
						_historyShape.graphics.beginFill(NEW_COLOR);
						_historyShape.graphics.lineStyle(1,NEW_COLOR);
						_historyShape.graphics.drawRect(
							_tempLoopPoint.historyPoints[j].x - _tempLoopPoint.radius, 
							_tempLoopPoint.historyPoints[j].y - _tempLoopPoint.radius, 
							_tempLoopPoint.radius * 2, _tempLoopPoint.radius * 2);
					}
				}
				
				//At the first pausing point, push the selection loop into 
				//_points of _selectionPigtailDetector
				for(var n:uint=0;n<_selectionPigtail.length;n++)
				{
					var point2:KTimestampPoint = _selectionPigtail[n];
					_selectionPigtailDetector.points.push(point2);
				}
				
			}
			
			if(true)
			{
				_button.label = "flick";
				_button.visible = true;
				_button.width = 40;
				_button.height = 30;
				_button.alpha = 0.5;
				_button.x = buttonPosition.x;
				_button.y = buttonPosition.y;
				
				_canvas.gestureLayer.addChild(_button);
				_button.addEventListener(MouseEvent.MOUSE_OUT,disappearButton);
			}
			
			_postGesture = new Vector.<KTimestampPoint>();
			_pigtailDetector.clearPoints();
			
			_tempView.clear();
			_mode = MODE_DELAY_AFTER_PAUSE;
			
		}
		
		public function enableLog():ILoggable
		{
			_log = new KGestureLog(new Vector.<KPathPoint>(),
				_appState.selection?_appState.selection.objects:null);
			return _log;
		}
		
		public function disappearButton(event:MouseEvent):void
		{
			_button.visible = false;
			_button.removeEventListener(MouseEvent.MOUSE_OUT,disappearButton);		
		}
	}
}
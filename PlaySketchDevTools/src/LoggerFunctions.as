/**------------------------------------------------
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab
*-------------------------------------------------*/
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.graphics.SolidColor;

import sg.edu.smu.ksketch.interactor.KLoggerCommandExecutor;
import sg.edu.smu.ksketch.logger.KLogger;

import spark.components.BorderContainer;
import spark.components.gridClasses.GridSelectionMode;
import spark.events.GridCaretEvent;
import spark.primitives.Rect;

private static const _COMMAND_NAME:String = "name";
private static const _PLAY_COMMAND:String = "Play";
private static const _STOP_COMMAND:String = "Stop";
private var _commandExecutor:KLoggerCommandExecutor;
private var _commandNodes:Vector.<XML>;
private var _startPlayTime:Number;
private var _playTimer:Timer;

public function initLogger(commandExecutor:KLoggerCommandExecutor,xml:XML):void
{
	_commandExecutor = commandExecutor;
	var commands:XMLList = xml.children();
	_commandNodes = new Vector.<XML>();
	var list:Array = new Array();
	for each (var command:XML in commands)
	{
		var obj:Object = new Object();
		obj[_COMMAND_NAME] = command.name();
		obj[KLogger.LOG_TIME] = command.attribute(KLogger.LOG_TIME);
		_commandNodes.push(command);
		list.push(obj);
	}
	_actionTable.dataProvider = new ArrayCollection(list);
	_actionTable.selectionMode = GridSelectionMode.SINGLE_ROW;
	_actionTable.ensureCellIsVisible(list.length-1);
	if (list.length > 0)
	{
		_actionSlider.minimum = KLogger.timeOf(list[0][KLogger.LOG_TIME]).valueOf();
		_actionSlider.maximum = KLogger.timeOf(list[list.length-1][KLogger.LOG_TIME]).valueOf();
		_setMarker(_markerBar,list,_actionSlider.minimum,_actionSlider.maximum);
	}
}

private function _initCommands(e:MouseEvent):void
{
	_actionText.removeEventListener(MouseEvent.CLICK,_initCommands);
	_actionTable.addEventListener(GridCaretEvent.CARET_CHANGE,_selectedRowChanged);	
	var length:uint = _actionTable.dataProviderLength;
	for (var i:int; i < length; i++)
		_commandExecutor.initCommand(_getCommand(i),_commandNodes[i]);
	_actionTable.selectedIndex = 0;
	for (var j:int=length-1; j > 0; j--)
		_undoCommand(j);
	_enablePlayback();
}

private function _enablePlayback():void
{
	_firstButton.enabled = true;
	_prevButton..enabled = true;
	_playButton..enabled = true;
	_nextButton..enabled = true;
	_lastButton..enabled = true;
	_actionTable..enabled = true;
}

private function _firstCommand(e:MouseEvent):void
{
	_actionTable.selectedIndex = 0;
}

private function _prevCommand(e:MouseEvent):void
{
	if (_actionTable.selectedIndex == -1)
		_actionTable.selectedIndex = 0;
	if (_actionTable.selectedIndex > 0)
		_actionTable.selectedIndex--;
}
		
private function _nextCommand(e:MouseEvent):void
{
	if (_actionTable.selectedIndex < _actionTable.dataProviderLength-1)
		_actionTable.selectedIndex++;
}

private function _lastCommand(e:MouseEvent):void
{
	_actionTable.selectedIndex = _actionTable.dataProviderLength - 1;
}		

private function _playCommand(e:MouseEvent):void
{
	if (_playButton.label == _PLAY_COMMAND)
	{
		_playButton.label = _STOP_COMMAND;
		_actionTable.selectedIndex = 0;
		_playTimer = new Timer(50,0);
		_playTimer.addEventListener(TimerEvent.TIMER,_updateTimeLine);
		_playTimer.start();
		_startPlayTime = new Date().valueOf();
	}
	else if (_playButton.label == _STOP_COMMAND)
	{
		_playButton.label = _PLAY_COMMAND;
		_playTimer.stop();
		_playTimer.removeEventListener(TimerEvent.TIMER,_updateTimeLine);
	}
}

private function _selectedRowChanged(e:GridCaretEvent):void
{
	if (0 <= e.oldRowIndex && e.oldRowIndex < e.newRowIndex)
		for (var i:int=e.oldRowIndex+1; i <= e.newRowIndex; i++)
			_redoCommand(i);
	else if (e.oldRowIndex > e.newRowIndex)
		for (var j:int=e.oldRowIndex; j > e.newRowIndex; j--)
			_undoCommand(j);
	_actionSlider.value = _getLogTime(_actionTable.selectedIndex);
	_actionTable.ensureCellIsVisible(_actionTable.selectedIndex);
}

private function _redoCommand(index:int):void
{
	_actionText.text = _commandNodes[index].toXMLString();
	_commandExecutor.redoCommand(_getCommand(index),_commandNodes[index]);
}

private function _undoCommand(index:int):void
{
	_actionText.text = _commandNodes[index-1].toXMLString();
	_commandExecutor.undoCommand(_getCommand(index),_commandNodes[index]);
}		

private function _getCommand(index:int):String
{
	return _actionTable.dataProvider[index][_COMMAND_NAME]
}

private function _updateTimeLine(e:TimerEvent):void
{
	var value:Number = new Date().valueOf() - _startPlayTime + _actionSlider.minimum;
	var next:Number = _getLogTime(_actionTable.selectedIndex + 1);
	if (value > next)
		_actionTable.selectedIndex++;
	if (value >= _actionSlider.maximum)
	{
		_playButton.label = _PLAY_COMMAND;
		(e.target as Timer).stop();
		(e.target as Timer).removeEventListener(TimerEvent.TIMER,_updateTimeLine);
	}
}

private function _getLogTime(index:int):Number
{
	return KLogger.timeOf(_commandNodes[index].attribute(KLogger.LOG_TIME)).valueOf();
}

private function _setMarker(markerBar:BorderContainer,data:Array,min:Number,max:Number):void
{
	markerBar.removeAllElements();
	var range:Number = min < max ? max - min : 1;
	for (var i:int = 0; i < data.length; i++)
	{
		var di:Number = KLogger.timeOf(data[i][KLogger.LOG_TIME]).valueOf();
		markerBar.addElement(_createMarker(_actionTable.width*(di-min)/range));
	}
}
	
private function _createMarker(x:Number):Rect
{
	var rect:Rect = new Rect();
	rect.x = x;
	rect.y = 0;
	rect.width = 3;
	rect.height = 7;
	rect.fill = new SolidColor(0x000000);
	return rect;
}
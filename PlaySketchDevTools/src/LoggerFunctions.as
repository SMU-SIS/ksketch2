/**------------------------------------------------
 *Copyright 2010-2012 Singapore Management University
 *Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 *-------------------------------------------------*/
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.graphics.SolidColor;

import sg.edu.smu.ksketch.components.KCanvas;
import sg.edu.smu.ksketch.interactor.KSystemCommandExecutor;
import sg.edu.smu.ksketch.logger.KLogger;

import spark.components.BorderContainer;
import spark.components.CheckBox;
import spark.events.GridCaretEvent;
import spark.primitives.Rect;

private static const _SYSTEM_COMMAND_PREFIX:String = "sys";
private static const _COMMAND_NAME:String = "name";
private static const _PLAY_COMMAND:String = "Play";
private static const _STOP_COMMAND:String = "Stop";
private var _commandExecutor:KSystemCommandExecutor;
private var _commandNodes:Vector.<XML>;
private var _systemCommandNodes:Vector.<XML>;
private var _startPlayTime:Number;
private var _playTimer:Timer;
private var _canvas:KCanvas;

public function initLogger(canvas:KCanvas,commandExecutor:KSystemCommandExecutor):void
{
	_canvas = canvas;
	_commandExecutor = commandExecutor;
	_initLogger(true,true);
}

private function _initLogger(showSystemEvent:Boolean,showUserEvent:Boolean):void
{
	_canvas.resetCanvas();
	_commandNodes = new Vector.<XML>();
	_systemCommandNodes = new Vector.<XML>();
	var commands:XMLList = KLogger.logFile.children();
	var list:Array = new Array();
	for each (var command:XML in commands)
	{
		var systemCommand:Boolean = _isSystemCommand(command.name());
		if (systemCommand)
			_systemCommandNodes.push(command);
		if ((showSystemEvent && systemCommand) || (showUserEvent && !systemCommand))
		{
			_commandNodes.push(command);
			var obj:Object = new Object();
			obj[_COMMAND_NAME] = command.name();
			obj[KLogger.LOG_TIME] = command.attribute(KLogger.LOG_TIME);
			list.push(obj);
		}
	}
	if (list.length > 0)
	{
		_actionSlider.minimum = KLogger.timeOf(list[0][KLogger.LOG_TIME]).valueOf();
		_actionSlider.maximum = KLogger.timeOf(list[list.length-1][KLogger.LOG_TIME]).valueOf();
		_setMarker(_markerBar,list,_actionSlider.minimum,_actionSlider.maximum);
	}
	for (var i:int=0; i < _systemCommandNodes.length; i++)
		if (_isLoadCommand(_systemCommandNodes[i].name().toString()))
			break;
		else
			_commandExecutor.initCommand(_systemCommandNodes[i]);
	_commandExecutor.undoAllCommand();
	_actionTable.removeEventListener(GridCaretEvent.CARET_CHANGE,_selectedRowChanged);
	_actionTable.ensureCellIsVisible(list.length-1);
	_actionTable.dataProvider = new ArrayCollection(list);
	_actionTable.selectedIndex = 0;
	_actionTable.addEventListener(GridCaretEvent.CARET_CHANGE,_selectedRowChanged);	
}

private function _isLoadCommand(command:String):Boolean
{
	return command.indexOf(KLogger.SYSTEM_LOAD) == 0;
}

private function _isSystemCommand(command:String):Boolean
{
	return command.indexOf(_SYSTEM_COMMAND_PREFIX) == 0;
}

private function _filterEvent(e:Event):void
{
	_initLogger(_systemEvent.selected,_userEvent.selected);
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
	if (_actionTable.selectedIndex != e.newRowIndex)
		_actionTable.selectedIndex = e.newRowIndex;
	
	_actionText.text = _commandNodes[_actionTable.selectedIndex].toXMLString();
	
	if (_isLoadCommand(_getCommand(e.newRowIndex)))
	{
		_commandExecutor.load(_commandNodes[e.newRowIndex]);
		_initLogger(_systemEvent.selected,_userEvent.selected);
	}
	if (0 <= e.oldRowIndex && e.oldRowIndex < e.newRowIndex)
	{
		for (var i:int=0; i < _systemCommandNodes.length; i++)
		{
			if (_getLogTime(_systemCommandNodes[i]) <= _getLogTime(_commandNodes[_actionTable.selectedIndex]))
				_redoCommand2(_systemCommandNodes[i].name().toString());
		}
				
	}
	else if (e.oldRowIndex > e.newRowIndex)
	{
		for (var j:int=_systemCommandNodes.length-1; j > 0; j--)
			if ( _getLogTime(_systemCommandNodes[j]) > _getLogTime(_commandNodes[_actionTable.selectedIndex]))
				_undoCommand2(_systemCommandNodes[j].name().toString());
	}
	if (_actionTable.selectedIndex >=0)
	{
		_actionSlider.value = _getLogTime(_commandNodes[_actionTable.selectedIndex]);
		_actionTable.ensureCellIsVisible(_actionTable.selectedIndex);
	}
}

private function _redoCommand2(command:String):void
{
	if (command == KLogger.SYSTEM_UNDO)
		_commandExecutor.undoSystemCommand();
	else
		_commandExecutor.redoSystemCommand();
}

private function _undoCommand2(command:String):void
{
	if (command == KLogger.SYSTEM_UNDO)
		_commandExecutor.redoSystemCommand()
	else
		_commandExecutor.undoSystemCommand();
}		

private function _getCommand(index:int):String
{
	return _actionTable.dataProvider[index][_COMMAND_NAME];
}

private function _updateTimeLine(e:TimerEvent):void
{
	var value:Number = new Date().valueOf() - _startPlayTime + _actionSlider.minimum;
	var next:Number = _getLogTime(_commandNodes[_actionTable.selectedIndex + 1]);
	if (value > next)
		_actionTable.selectedIndex++;
	if (value >= _actionSlider.maximum)
	{
		_playButton.label = _PLAY_COMMAND;
		(e.target as Timer).stop();
		(e.target as Timer).removeEventListener(TimerEvent.TIMER,_updateTimeLine);
	}
}

private function _getLogTime(xml:XML):Number
{
	return KLogger.timeOf(xml.attribute(KLogger.LOG_TIME)).valueOf();
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
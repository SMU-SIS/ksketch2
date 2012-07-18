/**------------------------------------------------
 *Copyright 2010-2012 Singapore Management University
 *Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 *-------------------------------------------------*/
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.graphics.SolidColor;

import sg.edu.smu.ksketch.components.KCanvas;
import sg.edu.smu.ksketch.event.KFileLoadedEvent;
import sg.edu.smu.ksketch.interactor.KSystemCommandExecutor;
import sg.edu.smu.ksketch.io.KFileLoader;
import sg.edu.smu.ksketch.io.KFileParser;
import sg.edu.smu.ksketch.logger.KLogger;

import spark.components.BorderContainer;
import spark.components.CheckBox;
import spark.events.GridCaretEvent;
import spark.primitives.Rect;

private static const _COMMAND_NAME:String = "name";
private static const _PLAY_COMMAND:String = "Play";
private static const _STOP_COMMAND:String = "Stop";
private var _commandExecutor:KSystemCommandExecutor;
private var _commandNodes:Vector.<XML>;
private var _systemCommandNodes:Vector.<XML>;
private var _startPlayTime:Number;
private var _startPlayIndex:int;
private var _playTimer:Timer;
private var _canvas:KCanvas;

public function initLogger(canvas:KCanvas,commandExecutor:KSystemCommandExecutor):void
{
	_canvas = canvas;
	_commandExecutor = commandExecutor;
	_playTimer = new Timer(100,0);
	_playTimer.addEventListener(TimerEvent.TIMER,_updateTimeLine);
	_actionTable.dataProvider = new ArrayCollection();
	_initLogger(true,true);
	_actionTable.addEventListener(GridCaretEvent.CARET_CHANGE,_selectedRowChanged);	
}

private function _initLogger(showSystemEvent:Boolean,showUserEvent:Boolean):void
{
	_actionTable.dataProvider.removeAll();
	_canvas.resetCanvas();
	_commandNodes = new Vector.<XML>();
	_systemCommandNodes = new Vector.<XML>();
	var commands:XMLList = KLogger.logFile.children();
	for each (var command:XML in commands)
	{
		var systemCommand:Boolean = KSystemCommandExecutor.isSystemCommand(command.name());
		if (systemCommand)
			_systemCommandNodes.push(command);
		if ((showSystemEvent && systemCommand) || (showUserEvent && !systemCommand))
		{
			_commandNodes.push(command);
			var obj:Object = new Object();
			obj[_COMMAND_NAME] = command.name();
			obj[KLogger.LOG_TIME] = command.attribute(KLogger.LOG_TIME);
			_actionTable.dataProvider.addItem(obj);
		}
	}
	if (_actionTable.dataProviderLength > 0)
	{
		var list:IList = _actionTable.dataProvider;
		_enableInteraction(true);
		_actionSlider.minimum = KLogger.timeOf(list[0][KLogger.LOG_TIME]).valueOf();
		_actionSlider.maximum = KLogger.timeOf(list[list.length-1][KLogger.LOG_TIME]).valueOf();
		_setMarker(_markerBar,list,_actionSlider.minimum,_actionSlider.maximum);
		_actionTable.ensureCellIsVisible(_actionTable.dataProviderLength-1);
		_actionTable.selectedIndex = 0;
		for (var i:int=0; i < _systemCommandNodes.length; i++)
		{
			var node:XML = _systemCommandNodes[i];
			if (KSystemCommandExecutor.isLoadCommand(node.name()))
				break;
			else
				_commandExecutor.initCommand(node);
		}
		_commandExecutor.undoAllCommand();
		if (_getLogTime(_systemCommandNodes[0]) <= _getLogTime(_commandNodes[0]) && 
			KSystemCommandExecutor.isOperationCommand(_systemCommandNodes[0].name().toString()))
			_commandExecutor.redoSystemCommand();
	}
}

private function _selectedRowChanged(e:GridCaretEvent):void
{
	if (e.newRowIndex < 0)
		_commandExecutor.undoAllCommand();
	else
	{
		var node:XML = _commandNodes[e.newRowIndex];
		if (KSystemCommandExecutor.isLoadCommand(node.name()))
			return _loadKMVFile(node);
		var oldTime:Number = e.oldRowIndex >= 0 ? _getLogTime(_commandNodes[e.oldRowIndex]) : 0;
		var newTime:Number = e.newRowIndex >= 0 ? _getLogTime(_commandNodes[e.newRowIndex]) : 0;
		if (0 <= e.oldRowIndex && e.oldRowIndex < e.newRowIndex)
			_forwardCommand(oldTime,newTime);
		else if (e.oldRowIndex > e.newRowIndex)
			_backwardCommand(oldTime,newTime);
		if (_actionTable.selectedIndex >=0)
		{
			_actionTable.ensureCellIsVisible(_actionTable.selectedIndex);
			_actionText.text = node.toXMLString();
			_actionSlider.value = _getLogTime(node);
		}
	}
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
		_startPlayer();
	else if (_playButton.label == _STOP_COMMAND)
		_stopPlayer();
}

private function _updateTimeLine(e:TimerEvent):void
{
	if (_actionTable.selectedIndex < _actionTable.dataProviderLength-1)
	{
		var start:Number = _getLogTime(_commandNodes[_startPlayIndex]);
		var next:Number = _getLogTime(_commandNodes[_actionTable.selectedIndex + 1]);
		var dt:Number = new Date().valueOf() - _startPlayTime; 
		if (dt > next - start)
			_actionTable.selectedIndex++;
		_actionSlider.value = start + dt;
	}
	else
		_stopPlayer();
}

private function _startPlayer():void
{
	_playButton.label = _STOP_COMMAND;
	_startPlayTime = new Date().valueOf();
	_startPlayIndex = _actionTable.selectedIndex;
	_playTimer.start();
	_enableInteraction(false);
}

private function _stopPlayer():void
{
	_playButton.label = _PLAY_COMMAND;
	_playTimer.stop();
	_enableInteraction(true);
}

private function _loadKMVFile(commandNode:XML):void
{
	if (_playTimer.running)
		_playTimer.stop();
	
	var filename:String = commandNode.attribute(KLogger.FILE_NAME);
	var location:String = commandNode.attribute(KLogger.FILE_LOCATION);
	if (_fileExist(filename,location))
	{
		_commandExecutor.load(commandNode);
		_initLogger(_systemEvent.selected,_userEvent.selected);
		if (_playButton.label == _STOP_COMMAND)
			_startPlayer();
	}
	else
	{
		_enableInteraction(true);
		Alert.show("Unable to find the file " + filename + 
			" in location " + location + "\n\nReload manually?",
			"File Not Found",Alert.YES|Alert.NO,this,_reloadFile);
	}
}

private function _reloadFile(e:CloseEvent):void
{
	if (e.detail == Alert.YES)
	{
		var loader:KFileLoader = new KFileLoader();
		loader.addEventListener(KFileLoadedEvent.EVENT_FILE_LOADED,_kmvLoaded);
		loader.loadKMV();		
	}
}

private function _kmvLoaded(e:KFileLoadedEvent):void
{
	var kmv:XML = new XML(e.content);
	KLogger.setLogFile(new XML(kmv.child(KLogger.COMMANDS)));
	_initLogger(_systemEvent.selected,_userEvent.selected);
	if (_playButton.label == _STOP_COMMAND)
		_startPlayer();
}

private function _fileExist(filename:String,location:String):Boolean
{
	return KFileParser.resolvePath(filename,
		location ? location : KLogger.FILE_DESKTOP_DIR).exists;
}

private function _forwardCommand(oldTime:Number,newTime:Number):void
{
	for (var i:int=0; i < _systemCommandNodes.length; i++)
	{
		var ti:Number = _getLogTime(_systemCommandNodes[i]); 
		if (oldTime < ti && ti <= newTime)
			_redoCommand(_systemCommandNodes[i]);
	}
}

private function _backwardCommand(oldTime:Number,newTime:Number):void
{
	for (var i:int=_systemCommandNodes.length-1; i >= 0; i--)
	{
		var ti:Number = _getLogTime(_systemCommandNodes[i]); 
		if (newTime < ti &&	ti <= oldTime)
			_undoCommand(_systemCommandNodes[i]);
	}
}

private function _redoCommand(commandNode:XML):void
{
	var command:String = commandNode.name();
	if (command == KLogger.SYSTEM_UNDO)
		_commandExecutor.undoSystemCommand();
	else if (KSystemCommandExecutor.isOperationCommand(command))
		_commandExecutor.redoSystemCommand();
	else if (KSystemCommandExecutor.isPlayerCommand(command))
		_commandExecutor.redoPlayerCommand(commandNode);
}

private function _undoCommand(commandNode:XML):void
{
	var command:String = commandNode.name();
	if (command == KLogger.SYSTEM_UNDO)
		_commandExecutor.redoSystemCommand()
	else if (KSystemCommandExecutor.isOperationCommand(command))
		_commandExecutor.undoSystemCommand();
	else if (KSystemCommandExecutor.isPlayerCommand(command))
		_commandExecutor.undoPlayerCommand(commandNode);
}		

private function _getLogTime(xml:XML):Number
{
	return KLogger.timeOf(xml.attribute(KLogger.LOG_TIME)).valueOf();
}

private function _enableInteraction(b:Boolean):void
{
	_actionTable.enabled = b;
	_firstButton.enabled = b;
	_prevButton.enabled = b;
	_nextButton.enabled = b;
	_lastButton.enabled = b;
	_userEvent.enabled = b;
	_systemEvent.enabled = b;
}

private function _setMarker(markerBar:BorderContainer,data:IList,min:Number,max:Number):void
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
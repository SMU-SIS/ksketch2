/**------------------------------------------------
 *Copyright 2010-2012 Singapore Management University
 *Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 *-------------------------------------------------*/
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.graphics.SolidColor;

import sg.edu.smu.ksketch.components.KCanvas;
import sg.edu.smu.ksketch.event.KFileLoadedEvent;
import sg.edu.smu.ksketch.interactor.KSystemCommandExecutor;
import sg.edu.smu.ksketch.io.KFileAccessor;
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
	_actionTable.dataProvider.removeAll();
	_canvas.resetCanvas();
	_commandNodes = new Vector.<XML>();
	var commands:XMLList = KLogger.logFile.children();
	for each (var command:XML in commands)
	{
		var obj:Object = new Object();
		obj[_COMMAND_NAME] = command.name();
		obj[KLogger.LOG_TIME] = command.attribute(KLogger.LOG_TIME);
		_actionTable.dataProvider.addItem(obj);
		_commandNodes.push(command);
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
		for (var i:int=0; i < _commandNodes.length; i++)
		{
			if (_isLoadCommand(_commandNodes[i]) || _isSwitchContentCommand(_commandNodes[i]))
				break;
			else
				_commandExecutor.initCommand(_commandNodes[i]);
		}
		_commandExecutor.undoAllCommand();
		if (_commandNodes.length > 0 && _isOperationCommand(_commandNodes[0]))
			_commandExecutor.redoSystemCommand();
	}
	_actionTable.addEventListener(GridCaretEvent.CARET_CHANGE,_selectedRowChanged);
	_highlightUserEvent(_skipSystemEventCheckBox.selected);
}

private function _selectedRowChanged(e:GridCaretEvent):void
{
	if (e.newRowIndex < 0)
		_commandExecutor.undoAllCommand();
	else
	{
		var node:XML = _commandNodes[e.newRowIndex];
		if (_isLoadCommand(node))
			return _loadKMVFile(node);
		else if (_isSwitchContentCommand(node))
			return _switchContent(node);
		if (0 <= e.oldRowIndex && e.oldRowIndex < e.newRowIndex)
			_forwardCommand(e.oldRowIndex+1,e.newRowIndex);
		else if (e.oldRowIndex > e.newRowIndex)
			_backwardCommand(e.oldRowIndex,e.newRowIndex+1);
		if (_actionTable.selectedIndex >=0)
		{
			_actionTable.ensureCellIsVisible(_actionTable.selectedIndex);
			_actionText.text = node.toXMLString();
			_actionSlider.value = _getLogTime(node);
		}
	}
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
	var length:int = _actionTable.dataProviderLength;
	if (_actionTable.selectedIndex < length-1)
		_actionTable.selectedIndex++;
	while (_skipSystemEventCheckBox.selected &&	_actionTable.selectedIndex < length-1 && 
		_isSystemCommand(_commandNodes[_actionTable.selectedIndex]))
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

private function _switchContent(commandNode:XML):void
{
	_commandExecutor.switchContent(commandNode);
}

private function _loadKMVFile(commandNode:XML):void
{
	if (_playTimer.running)
		_playTimer.stop();
	
	var filename:String = commandNode.attribute(KLogger.FILE_NAME);
	var location:String = commandNode.attribute(KLogger.FILE_LOCATION);
	if (_fileExist(filename,location))
	{
		_commandExecutor.load(filename,location);
		if (_playButton.label == _STOP_COMMAND)
			_startPlayer();
	}
	else
	{
		_enableInteraction(true);
		Alert.show("Unable to find the file " + filename + " in location " + location + 
			"\n\nReload manually?","File Not Found",Alert.YES|Alert.NO,this,_reloadFile);
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
	if (_playButton.label == _STOP_COMMAND)
		_startPlayer();
}

private function _fileExist(filename:String,location:String):Boolean
{
	return (KFileAccessor.resolvePath(filename,
		location ? location : KLogger.FILE_DESKTOP_DIR) as File).exists;
}

private function _forwardCommand(from:int,to:int):void
{
	for (var i:int=from; i <= to; i++)
		_redoCommand(_commandNodes[i]);
}

private function _backwardCommand(from:int,to:int):void
{
	for (var i:int=from; i >= to; i--)
		_undoCommand(_commandNodes[i]);
}

private function _redoCommand(commandNode:XML):void
{
	if (commandNode.name().toString() == KLogger.SYSTEM_UNDO)
		_commandExecutor.undoSystemCommand();
	else if (_isOperationCommand(commandNode))
		_commandExecutor.redoSystemCommand();
	else if (_isPlayerCommand(commandNode))
		_commandExecutor.redoPlayerCommand(commandNode);
	else if (_isSelectionCommand(commandNode))
		_commandExecutor.redoSelectionCommand(commandNode);
}

private function _undoCommand(commandNode:XML):void
{
	if (commandNode.name().toString() == KLogger.SYSTEM_UNDO)
		_commandExecutor.redoSystemCommand()
	else if (_isOperationCommand(commandNode))
		_commandExecutor.undoSystemCommand();
	else if (_isPlayerCommand(commandNode))
		_commandExecutor.undoPlayerCommand(commandNode);
	else if (_isSelectionCommand(commandNode))
		_commandExecutor.undoSelectionCommand(commandNode);
}		

private function _isLoadCommand(commandNode:XML):Boolean
{
	return KSystemCommandExecutor.isLoadCommand(commandNode.name());
}

private function _isSystemCommand(commandNode:XML):Boolean
{
	return KSystemCommandExecutor.isSystemCommand(commandNode.name());
}

private function _isOperationCommand(commandNode:XML):Boolean
{
	return KSystemCommandExecutor.isOperationCommand(commandNode.name());
}

private function _isPlayerCommand(commandNode:XML):Boolean
{
	return KSystemCommandExecutor.isPlayerCommand(commandNode.name());
}

private function _isSwitchContentCommand(commandNode:XML):Boolean
{
	return KSystemCommandExecutor.isSwitchContentCommand(commandNode.name());
}

private function _isSelectionCommand(commandNode:XML):Boolean
{
	return KSystemCommandExecutor.isSelectionCommand(commandNode.name());
}

private function _getLogTime(xml:XML):Number
{
	return KLogger.timeOf(xml.attribute(KLogger.LOG_TIME)).valueOf();
}

private function _highlightUserEvent(b:Boolean):void
{
	KSystemCommandExecutor.highlightUserEvent = b;
	(_actionTable.dataProvider as ArrayCollection).refresh();
	_setMarker(_markerBar,_actionTable.dataProvider,_actionSlider.minimum,_actionSlider.maximum);

}

private function _enableInteraction(b:Boolean):void
{
	_actionTable.enabled = b;
	_firstButton.enabled = b;
	_prevButton.enabled = b;
	_nextButton.enabled = b;
	_lastButton.enabled = b;
}

private function _setMarker(markerBar:BorderContainer,data:IList,min:Number,max:Number):void
{
	markerBar.removeAllElements();
	var normal:uint = KSystemCommandExecutor.SYSTEM_EVENT_COLOR;
	var highlight:uint = KSystemCommandExecutor.USER_EVENT_COLOR;
	var selected:Boolean = _skipSystemEventCheckBox.selected;
	var range:Number = min < max ? max - min : 1;
	for (var i:int = 0; i < data.length; i++)
	{
		var di:Number = KLogger.timeOf(data[i][KLogger.LOG_TIME]).valueOf();
		var isSys:Boolean = data[i][_COMMAND_NAME].toString().indexOf("sys") > 0;
		var color:uint = selected && !isSys ? highlight : normal;
		markerBar.addElement(_createMarker(_actionTable.width*(di-min)/range,color));
	}
}

private function _createMarker(x:Number,color:uint):Rect
{
	var rect:Rect = new Rect();
	rect.x = x;
	rect.y = 0;
	rect.width = 3;
	rect.height = 7;
	rect.fill = new SolidColor(color);
	return rect;
}
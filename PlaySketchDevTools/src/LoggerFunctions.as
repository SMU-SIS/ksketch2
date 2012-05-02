/**------------------------------------------------
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 
*-------------------------------------------------*/
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;
import mx.graphics.SolidColor;

import sg.edu.smu.ksketch.event.KFileLoadedEvent;
import sg.edu.smu.ksketch.interactor.KLoggerCommandExecutor;
import sg.edu.smu.ksketch.logger.KLogger;
import sg.edu.smu.ksketch.io.KFileLoader;
import sg.edu.smu.ksketch.io.KFileSaver;

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
	_buttons.visible = false;
	load(xml);
}

public function load(xml:XML):void
{
	var commands:XMLList = xml.children();
	if (commands.length() == 0)
		return;
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
	_actionTable.removeEventListener(GridCaretEvent.CARET_CHANGE,_selectedRowChanged);
	_actionTable.dataProvider = new ArrayCollection(list);
	_actionTable.selectionMode = GridSelectionMode.NONE;
	_actionSlider.minimum = KLogger.timeOf(list[0][KLogger.LOG_TIME]).valueOf();
	_actionSlider.maximum = KLogger.timeOf(list[list.length-1][KLogger.LOG_TIME]).valueOf();
	_setMarker(_markerBar,list,_actionSlider.minimum,_actionSlider.maximum);
}

private function _openSaveWindow(event:MouseEvent):void
{
	new KFileSaver().saveLog(KLogger.logFile);
}

private function _openLoadWindow(event:MouseEvent):void
{
	var loader:KFileLoader = new KFileLoader();
	loader.addEventListener(KFileLoadedEvent.EVENT_FILE_LOADED, _loadLog);
	loader.loadLog();
}

private function _loadLog(e:KFileLoadedEvent):void
{
	_commandExecutor.newFile();
	_actionTable.addEventListener(FlexEvent.UPDATE_COMPLETE,_tableLoaded);
	_actionTable.removeEventListener(GridCaretEvent.CARET_CHANGE,_selectedRowChanged);
	load(new XML(e.content));
	_actionTable.selectionMode = GridSelectionMode.SINGLE_ROW;
}

private function _tableLoaded(e:FlexEvent):void
{
	for (var i:int = 0; i < _actionTable.dataProvider.length; i++)
		_commandExecutor.initCommand(
			_actionTable.dataProvider[i][_COMMAND_NAME],_commandNodes[i]);	
	for (var j:int = _actionTable.dataProvider.length-1; j >= 0 ; j--)
		_commandExecutor.undoCommand(
			_actionTable.dataProvider[j][_COMMAND_NAME],_commandNodes[j]);
	_redoCommand(_actionTable.selectedIndex = 0);
	_actionTable.removeEventListener(FlexEvent.UPDATE_COMPLETE,_tableLoaded);
	_actionTable.addEventListener(GridCaretEvent.CARET_CHANGE,_selectedRowChanged);
	_buttons.visible = true;
	_saveButton.enabled = false;
}

private function _selectedRowChanged(e:GridCaretEvent):void
{
	if (e.oldRowIndex < e.newRowIndex)
		for (var i:int=e.oldRowIndex+1; i <= e.newRowIndex; i++)
			_redoCommand(i);
	else if (e.oldRowIndex > e.newRowIndex)
		for (var j:int=e.oldRowIndex; j > e.newRowIndex; j--)
			_undoCommand(j);
}

private function _redoCommand(index:int):void
{
	_actionText.text = _commandNodes[index].toXMLString();
	_commandExecutor.redoCommand(
		_actionTable.dataProvider[index][_COMMAND_NAME],_commandNodes[index]);
}

private function _undoCommand(index:int):void
{
	_actionText.text = _commandNodes[index-1].toXMLString();
	_commandExecutor.undoCommand(
		_actionTable.dataProvider[index][_COMMAND_NAME],_commandNodes[index]);
}		

private function _firstCommand(e:MouseEvent):void
{
	_actionTable.selectedIndex = 0;
}

private function _prevCommand(e:MouseEvent):void
{
if (_actionTable.selectedIndex > 0)
	_actionTable.selectedIndex--;
}
		
private function _nextCommand(e:MouseEvent):void
{
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
		_actionTable.selectedIndex = -1;
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

private function _updateTimeLine(e:TimerEvent):void
{
	var value:Number = new Date().valueOf() - _startPlayTime + _actionSlider.minimum;
	var node:XML = _commandNodes[_actionTable.selectedIndex + 1];
	var next:Number = KLogger.timeOf(node.attribute(KLogger.LOG_TIME)).valueOf(); 
	_actionSlider.value = value < _actionSlider.maximum ? value : _actionSlider.maximum;
	if (value > next)
		_actionTable.selectedIndex++;
	if (value >= _actionSlider.maximum)
	{
		_playButton.label = _PLAY_COMMAND;
		(e.target as Timer).stop();
		(e.target as Timer).removeEventListener(TimerEvent.TIMER,_updateTimeLine);
	}
}

private function _setMarker(markerBar:BorderContainer,data:Array,min:Number,max:Number):void
{
	markerBar.removeAllElements();
	if (min < max)
	{
		for (var i:int = 0; i < data.length; i++)
		{
			var di:Number = KLogger.timeOf(data[i][KLogger.LOG_TIME]).valueOf();
			markerBar.addElement(_createMarker((this.width-15)*(di-min)/(max-min)));
		}
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

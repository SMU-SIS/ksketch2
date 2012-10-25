/***************************************************
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
****************************************************/

package sg.edu.smu.ksketch.interactor
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.core.Container;
	import mx.utils.ObjectUtil;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.components.KFilteredLoopView;
	import sg.edu.smu.ksketch.logger.ILoggable;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.logger.KWithSelectionLog;
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.model.KImage;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.model.geom.KPathPoint;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	import sg.edu.smu.ksketch.utilities.KAppState;
	import sg.edu.smu.ksketch.utilities.KModelObjectList;
	
	import spark.components.BorderContainer;
	
	public class KSelectInteractor implements IInteractor
	{
		private static const THRESHOLD_BOUNDING_SCALE:Number = 0.6;
		
		private var _container:KCanvas;
		
		private var _rectBounding:Vector.<Point>;
		private var _circleBounding:Vector.<Point>;
		
		private var _log:KWithSelectionLog;
		
		protected var _appState:KAppState;
		
		public function KSelectInteractor(canvas:KCanvas, appState:KAppState)
		{
			_container = canvas;
			_appState = appState;
			
			_circleBounding = new Vector.<Point>();
			for(var i:int = 0;i<4;i++)
				_circleBounding.push(new Point());
			
			_rectBounding = new Vector.<Point>();
			for(var j:int = 0;j<8;j++)
				_rectBounding.push(new Point());
		}
		
		protected function get areaShape():DisplayObject
		{
			return null;
		}
		
		public function activate():void
		{	_container.gestureLayer.addChild((areaShape as KFilteredLoopView).clone());
			_container.contentContainer.addChild(areaShape);
		}
		
		public function deactivate():void
		{
			_container.contentContainer.removeChild(areaShape);
		}
		
		public function begin(point:Point):void
		{
		}
		
		public function update(point:Point):void
		{
		}
		
		public function end(point:Point):void
		{
		}
		
		protected function updateLog(point:Point):void
		{
			if(_log != null)
				_log.addPoint(new KPathPoint(point.x, point.y, _appState.time));
		}
		
		protected function endLog():void
		{
			if(_log != null)
			{
				if(_appState.selection != null)
					_log.selected = _appState.selection.objects as KModelObjectList;
				_log = null;
			}
		}
		
		protected function testPointsCount(object:KObject):uint
		{
			if(object is KStroke)
				return (object as KStroke).points.length;
			else if(object is KImage)
				return KImage.NUM_BOUNDING_POINTS;
			else throw new Error("not supported kobject: "+object);
		}
		
		protected function scaledBoundingBox(object:KObject):Vector.<Point>
		{
			if(object is KStroke)
				return (object as KStroke).points;
			else throw new Error("not supported kobject: "+object);
		}
		
		public function get name():String
		{
			return null;
		}
		
		public function enableLog():ILoggable
		{
			_log = new KWithSelectionLog(new Vector.<KPathPoint>(), 
				name, _appState.selection.objects as KModelObjectList);
			return _log;
		}
	}
}
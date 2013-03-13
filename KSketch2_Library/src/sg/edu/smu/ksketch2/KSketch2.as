/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.events.KTimeChangedEvent;
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.data_structures.KSceneGraph;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KImage;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	import sg.edu.smu.ksketch2.operators.KGroupingUtil;
	import sg.edu.smu.ksketch2.operators.KStaticGroupingUtil;
	import sg.edu.smu.ksketch2.operators.operations.KCompositeOperation;
	import sg.edu.smu.ksketch2.operators.operations.KEditKeyTimeOperation;
	
	/**
	 * KSketch 2 Singleton. All the logging will be done here!
	 */
	public class KSketch2 extends EventDispatcher
	{
		public static const STUDY_K:int = 0;
		public static const STUDY_P:int = 1;
		public static const STUDY_PK:int = 2;
		
		public static var studyMode:int = STUDY_P;
		public static var discardTransitionTimings:Boolean = false;
		public static var addInterpolationKeys:Boolean = false;
		public static var returnTranslationInterpolationToZero:Boolean = true;
		public static var returnRotationInterpolationToZero:Boolean = false;
		public static var returnScaleInterpolationToZero:Boolean = false;
		
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		
		public static const CANONICAL_WIDTH:Number = 1280;
		public static const CANONICAL_HEIGHT:Number = 720;
		public static const TRANSFORM_TRANSLATION:int = 0;
		public static const TRANSFORM_ROTATION:int = 1;
		public static const TRANSFORM_SCALE:int = 2;
		
		public static const TRANSITION_INTERPOLATED:int = 0;
		public static const TRANSITION_DEMONSTRATED:int = 1;
		
		public static var ANIMATION_INTERVAL:Number = 40;
		
		private var _groupingUtil:KGroupingUtil;
		
		private var _sceneGraph:KSceneGraph;
		private var _time:int;
		
		public var log:XML;
		public var logStartTime:Number;
		
		public function KSketch2()
		{
			//This super statement is important, do not miss it for goodness's sake
			super(this);
			
			init();
		}
		
		//General Functions
		public function init():void
		{
			_sceneGraph = new KSceneGraph();
			_time = 0;
			_groupingUtil = new KStaticGroupingUtil();
		}
		
		public function reset():void
		{
			init();
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_KSKETCH_INIT));
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED));
		}
		
		public function get sceneXML():XML
		{
			return _sceneGraph.serialize();
		}
		
		public function beginSession():void
		{
			log = <session/>;
			
			var date:Date = new Date();
			logStartTime = date.time;
			log.@date = date.toString();
			
			switch(studyMode)
			{	
				case STUDY_K:
					log.@mode = "K"
					break;
				case STUDY_P:
					log.@mode = "P"
					break;
				case STUDY_PK:
					log.@mode = "PK"
					break;
			}
		}
		
		public function get sessionLog():XML
		{
			if(!log)
				throw new Error("Session not initiated");
			
			return log;
		}
		
		public function generateSceneFromXML(xml:XML):void
		{
			if(_sceneGraph.root.children.length() != 0)
				throw new Error("The scene graph is not clean. clear up the scene graph before loading!");
			_sceneGraph.deserialize(xml);
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED));
		}
		
		public function get root():KGroup
		{
			return _sceneGraph.root;
		}
		
		public function get time():int
		{
			return _time;
		}
		
		public function set time(value:int):void
		{
			var timeChangedEvent:KTimeChangedEvent = new KTimeChangedEvent(KTimeChangedEvent.EVENT_TIME_CHANGED, _time, value);
			_time = value;
			dispatchEvent(timeChangedEvent);
		}
		
		public function get maxTime():int
		{
			return _sceneGraph.maxTime;
		}
		
		//Functions to add objects to KSketch
		/**
		 * Adds a KStroke Image to the model's root
		 * Also Adds an operation to the operation stack
		 */
		public function object_Add_Stroke(points:Vector.<Point>, time:int, color:uint, thickness:Number, op:KCompositeOperation):KStroke
		{
			var newStroke:KStroke = new KStroke(_sceneGraph.nextHighestID, points, color, thickness);
			_sceneGraph.registerObject(newStroke, op);
			newStroke.init(time, op);
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _sceneGraph.root));
			return newStroke;
		}
	
		public function object_Add_Image(imgData:BitmapData, time:int):KImage
		{
			var newImage:KImage = new KImage(_sceneGraph.nextHighestID, imgData);
			_sceneGraph.registerObject(newImage, null);
			newImage.init(time, null);
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _sceneGraph.root));
			
			return newImage;
		}
		
		//Functions to modify the model hierarchy
		/**
		 * Groups the given list of object and modifies the model up till
		 * given groupTime. Modificiations to the model and its objects are subjected to the active grouping mode.
		 * If breakToRoot is true, the new group will be parented under the root.
		 */
		public function hierarchy_Group(objects:KModelObjectList, groupTime:int, breakToRoot:Boolean, op:KCompositeOperation):KModelObjectList
		{
			var commonParent:KGroup;
			if(1 < objects.length() && !breakToRoot)
				commonParent = _groupingUtil.lowestCommonParent(objects);
			else
				commonParent = _sceneGraph.root;
			
			//Do grouping first
			var groupResult:KObject = _groupingUtil.group(objects,commonParent, groupTime, _sceneGraph, op);

			_groupingUtil.removeSingletonGroups(root, _sceneGraph, op);
			
			var result:KModelObjectList = new KModelObjectList();
			
			if(groupResult)
			{
				result.add(groupResult);
				dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _sceneGraph.root));
			}
			
				
			return result;
		}
		
		/**
		 * Ungroup the given group and parents all its direct children into its parent.
		 * Effects are dependent on the active grouping mode.
		 * Returns a list of objects that were ungrouped.
		 * Objects that were not ungrouped will not be returned.
		 * Returns a list of ungrouped objects
		 */
		public function hierarchy_Ungroup(toUngroup:KGroup, ungroupTime:int, op:KCompositeOperation):KModelObjectList
		{
			var result:KModelObjectList = _groupingUtil.ungroup(toUngroup, ungroupTime, _sceneGraph, op);
			_groupingUtil.removeSingletonGroups(root, _sceneGraph, op);
			
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _sceneGraph.root));
			return result;
		}
		
		//Transform functions
		public function beginTransform(object:KObject, transitionType:int, op:KCompositeOperation):void
		{
			object.transformInterface.beginTransition(time, transitionType, op);
		}
		
		public function updateTransform(object:KObject, dx:Number, dy:Number, dTheta:Number, dScale:Number):void
		{
			object.transformInterface.updateTransition(time, dx, dy, dTheta, dScale);
		}
		
		public function endTransform(object:KObject, op:KCompositeOperation):void
		{
			object.transformInterface.endTransition(time, op);
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _sceneGraph.root));
		}
		
		/**
		 * Function to change key time
		 * It's really just here for the sake of logging things
		 */
		public function editKeyTime(object:KObject, key:IKeyFrame, newTime:int, op:KCompositeOperation):void
		{ 
			if(key.time != newTime)
			{
				op.addOperation(new KEditKeyTimeOperation(object, key, newTime, key.time)); 
				(key as KKeyFrame).retime(newTime, op);
				object.transformInterface.dirty = true;
			}
		}
	}
}
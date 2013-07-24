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
	 * The KSketch2 class serves as the singleton K-Sketch object. All
	 * logging is done here.
	 */
	public class KSketch2 extends EventDispatcher
	{
		// ##########
		// # Fields #
		// ##########
		
		/**
		 * Study mode K(ey-frames).
		 */
		public static const STUDY_K:int = 0;
		
		/**
		 * Study mode P(erformance).
		 */
		public static const STUDY_P:int = 1;
		
		/**
		 * Study mode P(erformance and)K(ey-frames).
		 */
		public static const STUDY_PK:int = 2;
		
		public static var studyMode:int = STUDY_PK;									// the study mode value
		public static var discardTransitionTimings:Boolean = false;					// the discard transition timings state flag
		public static var addInterpolationKeys:Boolean = false;						// the add interpolation keys state flag
		public static var returnTranslationInterpolationToZero:Boolean = true;		// the return translation interpolation to zero state flag
		public static var returnRotationInterpolationToZero:Boolean = false;		// the return rotation interpolation to zero state flag
		public static var returnScaleInterpolationToZero:Boolean = false;			// the return scale interpolation to zero state flag
		
		public var scaleX:Number = 1;		// the x-scaling value
		public var scaleY:Number = 1;		// the y-scaling value
		
		/**
		 * The canonical width.
		 */
		public static const CANONICAL_WIDTH:Number = 1280;
		
		/**
		 * The canonical height.
		 */
		public static const CANONICAL_HEIGHT:Number = 720;
		
		/**
		 * The translation transform.
		 */
		public static const TRANSFORM_TRANSLATION:int = 0;
		
		/**
		 * The rotation transform.
		 */
		public static const TRANSFORM_ROTATION:int = 1;
		
		/**
		 * The scale transform.
		 */
		public static const TRANSFORM_SCALE:int = 2;
		
		/**
		 * The interpolated transition.
		 */
		public static const TRANSITION_INTERPOLATED:int = 0;
		
		/**
		 * The demonstrated transition.
		 */
		public static const TRANSITION_DEMONSTRATED:int = 1;
		
		/**
		 * The animation interval.
		 */
		public static var ANIMATION_INTERVAL:Number = 40;
		
		private var _groupingUtil:KGroupingUtil;			// the grouping utility
		private var _sceneGraph:KSceneGraph;				// the scene graph
		private var _time:int;								// the time
		
		public var log:XML;									// the log
		public var logStartTime:Number;						// the log's start time
		
		
		
		// ###############
		// # Constructor #
		// ###############
		
		/**
		 * The main constructor of the KSketch2 class.
		 */
		public function KSketch2()
		{
			// this super statement is important, do not miss it for goodness's sake
			super(this);
			
			// initialize the ksketch
			init();
		}
		
		
		
		// ###################
		// # General Methods #
		// ###################
		
		/**
		 * Initializes the ksketch.
		 */
		public function init():void
		{
			// initialize the scene graph
			_sceneGraph = new KSceneGraph();
			
			// initialize the time
			_time = 0;
			
			// initialize the grouping utility
			_groupingUtil = new KStaticGroupingUtil();
		}
		
		/**
		 * Resets the ksketch object.
		 */
		public function reset():void
		{
			// reinitialize the ksketch
			init();
			
			// broadcast the initialized ksketch and updated model
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_KSKETCH_INIT));
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED));
		}
		
		/**
		 * Gets the ksketch's serialized scene graph.
		 * 
		 * @return The ksketch's serialized scene graph.
		 */
		public function get sceneXML():XML
		{
			return _sceneGraph.serialize();
		}
		
		/**
		 * Begins the ksketch session.
		 */
		public function beginSession():void
		{
			// log the session start
			log = <session/>;
			
			// log the time and date
			var date:Date = new Date();
			logStartTime = date.time;
			log.@date = date.toString();
			
			// log the study mode
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
		
		/**
		 * Gets the session log.
		 * 
		 * @return The session log.
		 */
		public function get sessionLog():XML
		{
			// case: the session log doesn't exist
			// throw an error
			if(!log)
				throw new Error("Session not initiated");
			
			// return the session log
			return log;
		}
		
		/**
		 * Generate the ksketch's scene graph from the given XML file.
		 * 
		 * @param The target XML file.
		 */
		public function generateSceneFromXML(xml:XML):void
		{
			// case: the scene graph has children
			// throw an error
			if(_sceneGraph.root.children.length() != 0)
				throw new Error("The scene graph is not clean. clear up the scene graph before loading!");
			
			// deserialize the scene graph's XML representation
			_sceneGraph.deserialize(xml);
			
			// broadcast the updated model
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED));
		}
		
		/**
		 * Gets the root node of the ksketch's scene graph.
		 * 
		 * @return The root node of the ksketch's scene graph. 
		 */
		public function get root():KGroup
		{
			return _sceneGraph.root;
		}
		
		/**
		 * Gets the ksketch's current time.
		 * 
		 * @return The ksketch's current time.
		 */
		public function get time():int
		{
			return _time;
		}
		
		/**
		 * Sets the ksketch's current time.
		 * 
		 * @param value The current time.
		 */
		public function set time(value:int):void
		{
			// initialize the time changed event
			var timeChangedEvent:KTimeChangedEvent = new KTimeChangedEvent(KTimeChangedEvent.EVENT_TIME_CHANGED, _time, value);
			
			// set the new current time
			_time = value;
			
			// broadcast the time changed
			dispatchEvent(timeChangedEvent);
		}
		
		/**
		 * Get the scene graph's maximum time.
		 * 
		 * @return The scene graph's maximum time.
		 */
		public function get maxTime():int
		{
			return _sceneGraph.maxTime;
		}

		
		
		// #################
		// # Object Adders #
		// #################
		
		/**
		 * Adds the stroke to the model's root node and corresponding
		 * composite operation to the operation stack.
		 * 
		 * @param points The target list of points.
		 * @param time The target time.
		 * @param color The target color.
		 * @param thickness The target thickness.
		 * @param op The corresponding composite operation.
		 * @return The resultant stroke.
		 */
		public function object_Add_Stroke(points:Vector.<Point>, time:int, color:uint, thickness:Number, op:KCompositeOperation):KStroke
		{
			var newStroke:KStroke = new KStroke(_sceneGraph.nextHighestID, points, color, thickness);
			_sceneGraph.registerObject(newStroke, op);
			newStroke.init(time, op);
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _sceneGraph.root));
			return newStroke;
		}
	
		/**
		 * Adds the image to the model's root node and corresponding
		 * composite operation to the operation stack.
		 * 
		 * @param imgData
		 * @param time
		 * @param op The corresponding composite operation.
		 * @return The resultant image.
		 */
		public function object_Add_Image(imgData:BitmapData, time:int, op:KCompositeOperation):KImage
		{
			var centerX:Number = (KSketch2.CANONICAL_WIDTH * scaleX)/2;
			var centerY:Number = (KSketch2.CANONICAL_HEIGHT * scaleY)/2;
			var imgX:Number = centerX - (imgData.width/2);
			var imgY:Number = centerY - (imgData.height/2);
			
			var newImage:KImage = new KImage(_sceneGraph.nextHighestID, imgData, imgX, imgY);
			_sceneGraph.registerObject(newImage, op);
			newImage.init(time, op);
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _sceneGraph.root));
			
			return newImage;
		}
		
		
		
		// #############################
		// # Model Hierarchy Modifiers # 
		// #############################
		
		/**
		 * Groups the given list of objects and modifies the model until the
		 * given group time. Modifications to the model and its objects are
		 * subjected to the active grouping mode. If the boolean flag to
		 * break to root is true, then the new group's parent will be the
		 * scene graph's root node.
		 * 
		 * @param objects The target list of objects.
		 * @param groupTime The target group time.
		 * @param breakToRoot The boolean flag to immediately group the list of objects directly under the scene graph's root node if true.
		 * @param op The corresponding composite operation.
		 * @return The hierarchical grouping of the given list of objects up to the given time.
		 */
		public function hierarchy_Group(objects:KModelObjectList, groupTime:int, breakToRoot:Boolean, op:KCompositeOperation):KModelObjectList
		{
			// create the common parent
			var commonParent:KGroup;
			
			// there is more than one object in the list and the break to root boolean flag is disabled
			// set the common parent to be the lowest common parent in the list of objects
			if(1 < objects.length() && !breakToRoot)
				commonParent = _groupingUtil.lowestCommonParent(objects);
			
			// case: the break to root boolean flag is enabled
			// set the common parent to be the scene graph's root node
			else
				commonParent = _sceneGraph.root;
			
			// perform the grouping first
			var groupResult:KObject = _groupingUtil.group(objects,_sceneGraph.root, groupTime, _sceneGraph, op);

			// remove singleton groups
			_groupingUtil.removeSingletonGroups(root, _sceneGraph, op);
			
			// initialize the hierarchical group
			var result:KModelObjectList = new KModelObjectList();
			
			// case: there exists a hierarchical grouping
			if(groupResult)
			{
				// add the grouping to the result
				result.add(groupResult);
				
				// broadcast that the model has been updated 
				dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _sceneGraph.root));
			}
			
			// return the hierarachical grouping, if any
			return result;
		}
		
		/**
		 * Ungroups the given group and places all its direct children into
		 * its parent. The results are dependent on the active grouping mode.
		 * Returns a list of ungrouped objects, where objects that were
		 * ungrouped are not returned.
		 * 
		 * @param toUngroupList The target list of objects to ungroup.
		 * @param ungroupTime The target ungroup time.
		 * @param op The corresponding composite operation.
		 * @return The list of ungrouped objects.
		 */
		public function hierarchy_Ungroup(toUngroupList:KModelObjectList, ungroupTime:int, op:KCompositeOperation):KModelObjectList
		{
			// get the list of ungrouped objects
			var result:KModelObjectList = _groupingUtil.ungroup(toUngroupList, ungroupTime, _sceneGraph, op);
			
			// remove any singleton groups
			_groupingUtil.removeSingletonGroups(root, _sceneGraph, op);
			
			// broadcast that the model was updated
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _sceneGraph.root));
			
			// return the list of ungrouped objects
			return result;
		}
		
		
		
		// ####################
		// # Tranform Methods #
		// ####################
		
		/**
		 * Begins the ksketch's transform.
		 * 
		 * @param object The target object.
		 * @param transition type The transition type.
		 * @param op The corresponding composite operation.
		 */
		public function beginTransform(object:KObject, transitionType:int, op:KCompositeOperation):void
		{
			object.transformInterface.beginTransition(time, transitionType, op);
		}
		
		/**
		 * Updates the ksketch's transform.
		 * 
		 * @param object The target object.
		 * @param dx The x-position displacement.
		 * @param dy The y-position displacement.
		 * @param dTheta The rotation displacement.
		 * @param dScale The scaling displacement.
		 */
		public function updateTransform(object:KObject, dx:Number, dy:Number, dTheta:Number, dScale:Number):void
		{
			object.transformInterface.updateTransition(time, dx, dy, dTheta, dScale);
		}
		
		/**
		 * Ends the ksketch's transform.
		 * 
		 * @param object The target object.
		 * @param op The corresponding composite operation.
		 */
		public function endTransform(object:KObject, op:KCompositeOperation):void
		{
			object.transformInterface.endTransition(time, op);
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _sceneGraph.root));
		}
		
		/**
		 * Moves the center of the ksketch.
		 * 
		 * @param object The target object.
		 * @param dx The x-position displacement.
		 * @param dy The y-position displacement.
		 */
		public function moveCenter(object:KObject, dx:Number, dy:Number):void
		{
			// move the object
			object.transformInterface.moveCenter(dx, dy, time);
			
			// broadcast the updated model
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_MODEL_UPDATED, _sceneGraph.root));
		}
		
		/**
		 * Edits the key frame time. Used primarily for logging purposes.
		 * 
		 * @param object The target object.
		 * @param key The target key frame.
		 * @param newTime The new time.
		 * @param op The corresponding composite operation.
		 */
		public function editKeyTime(object:KObject, key:IKeyFrame, newTime:int, op:KCompositeOperation):void
		{ 
			// case: the key frame's time differs from the new time
			// change the key frame's time
			if(key.time != newTime)
			{
				// add the key frame time change to the composite operation
				op.addOperation(new KEditKeyTimeOperation(object, key, newTime, key.time)); 
				
				// retime the key frame
				(key as KKeyFrame).retime(newTime, op);
				
				// dirty the cache in the object's transform
				object.transformInterface.dirty = true;
			}
		}
	}
}
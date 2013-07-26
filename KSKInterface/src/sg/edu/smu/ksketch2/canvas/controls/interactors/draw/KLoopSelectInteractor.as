/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.draw
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import spark.core.SpriteVisualElement;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.controls.IInteractionControl;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.selectors.ISelectionArbiter;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.selectors.KPortion;
	import sg.edu.smu.ksketch2.canvas.controls.interactors.draw.selectors.KSimpleArbiter;
	import sg.edu.smu.ksketch2.model.data_structures.KModelObjectList;
	import sg.edu.smu.ksketch2.model.objects.KGroup;
	import sg.edu.smu.ksketch2.model.objects.KImage;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.model.objects.KStroke;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	import sg.edu.smu.ksketch2.utils.KSelection;
	import sg.edu.smu.ksketch2.canvas.components.view.KFilteredLoopView;
	
	/**
	 * The KLoopSelectInteractor class serves as the concrete class for
	 * loop select interactors in K-Sketch.
	 */
	public class KLoopSelectInteractor extends KInteractor
	{
		/**
		 * The gesture display.
		 */
		public var gestureDisplay:SpriteVisualElement;
		
		/**
		 * The intel model status.
		 */
		public static const MODE:String = "INTEL";
		
		private static const RADIUS:Number = 2;					// the loop selection radius
		private static const COLOR:uint = 0xf38400;				// the loop selection color
		
		/**
		 * The loop selection threshold distance.
		 */
		private static const THRESHOLD_DISTANCE:int = 5;
		
		private var _loopStart:Point;							// the loop selection start point
		private var _secondToLast:Point;						// the loop selection second-to-last point
		private var _loopEnd:Point;								// the loop selection end point
		
		private var _lastChecked:int;
		private var _all:ByteArray;								
		private var _last:ByteArray;
		
		private var _root:KGroup;								// the grouped objects' root node
		private var _portions:Dictionary;						// the objects' portions
		private var _arbiter:ISelectionArbiter;					// the selection arbiter
		
		private var _loopView:KFilteredLoopView;				// the loop view
		private var _gestureComponent:SpriteVisualElement		// the gesture component
		
		/**
		 * The main constructor of the KLoopSelectInteractor class.
		 * 
		 * @param KSketch2 The ksketch instance.
		 * @param gestureComponent The gesture component.
		 * @param interactionControl The interaction control. 
		 */
		public function KLoopSelectInteractor(KSketchInstance:KSketch2, gestureComponent:SpriteVisualElement, interactionControl:IInteractionControl)
		{
			super(KSketchInstance, interactionControl);
			_loopView = new KFilteredLoopView();
			_gestureComponent = gestureComponent;
			reset();
		}
		
		override public function reset():void
		{
			_lastChecked = -1;
			_all = new ByteArray();
			_last = new ByteArray();
			_arbiter = new KSimpleArbiter();
			_loopView.clear();
		}
		
		override public function interaction_Begin(point:Point):void
		{
			_reset();
			
			_root = _KSketch.root;
			_gestureComponent.addChild(_loopView);
			_loopView.add(point);
			
			_portions = new Dictionary();
			
			_loopStart = point;
			_secondToLast = point;
			_loopEnd = point;
		}
		
		override public function interaction_Update(point:Point):void
		{
			_lastChecked = -1;
			
			if(point == null)
				return;
			
			_secondToLast = _loopEnd;
			_loopEnd = point;
			
			// updates the loop view only, no selection here
			_loopView.add(point);
			
			checkAllObjects();
			
			// selection happens here
			// a new set of selection is gather on every update
			var selectedObjects:KModelObjectList = (_arbiter as KSimpleArbiter).bestGuess(_portions, _KSketch.time, _root);
			_interactionControl.selection = new KSelection(selectedObjects);
		}
		
		override public function interaction_End():void
		{
			_reset();
			_gestureComponent.removeChild(_loopView);
		}
		
		/**
		 * Resets the loop selection's settings for the start and end of
		 * the interaction.
		 */
		private function _reset():void
		{
			_loopEnd = null;
			_loopStart = null;
			_secondToLast = null;
			
			_lastChecked = -1;
			_all = new ByteArray();
			_last = new ByteArray();
			
			_loopView.clear();
			_portions = null;
		}
		
		/**
		 * Checks all the objects in the model and computes their
		 * selection threshold.
		 */
		private function checkAllObjects():void
		{
			var objects:KModelObjectList = _KSketch.root.getAllNonGroupObjects();
			var object:KObject;
			var selectedPnts:uint;
			var totalPnts:uint;
			
			var i:int;
			var length:int = objects.length();
			
			for(i = 0; i < length; i++)
			{
				object = objects.getObjectAt(i);
				selectedPnts = hitTest(object, _KSketch.time);
				totalPnts = testPointsCount(object);
				if(selectedPnts > 0)
					_portions[object] = new KPortion(totalPnts, selectedPnts);
				else if(_portions[object] != null)
					delete _portions[object];
			}
		}
		
		/**
		 * Does a hit test on the given object and sees how much of the
		 * given object is intersected with the selection loop.
		 * 
		 * @param target The target object.
		 * @kskTime The ksketch instance's time.
		 */
		private function hitTest(target:KObject, kskTime:Number):uint
		{
			if(target is KStroke)
				return updateByteArray(scaledBoundingBox(target), target.fullPathMatrix(kskTime), _loopStart, _secondToLast, _loopEnd);
			else if(target is KImage)
				return updateByteArray(scaledBoundingBox(target), target.fullPathMatrix(kskTime), _loopStart, _secondToLast, _loopEnd);
			else
				throw new Error("not supported kobject!");
		}
		
		/**
		 * Performs an intersection test for the given object.
		 * 
		 * @param points The list of points.
		 * @param transform The transform matrix.
		 * @param startPoint The start point.
		 * @param oldEnd The old endpoint.
		 * @param newEnd The new endpoint.
		 * @return The inside count of the intersection.
		 */
		private function updateByteArray(points:Vector.<Point>, transform:Matrix, startPoint:Point, oldEnd:Point, newEnd:Point):uint
		{
			var i:int = 0, j:int;
			var check:int;
			var newLast:int, newAll:int;
			var insideCount:uint;
			var p:Point;
			var pnts:int = points.length;
			var arrayLength:int = _all.length;
			while( i < pnts)
			{
				_lastChecked ++;
				check = 1;
				newLast = 0;
				if(_lastChecked < arrayLength)
					newAll = _all[_lastChecked] ^ _last[_lastChecked];
				else
					newAll = 0;
				for(j = 0; j < 8; j++, i++)
				{
					if(i > pnts - 1)
						break;
					p = transform.transformPoint(points[i]);
					if(KMathUtil.hasIntersection(p, startPoint, newEnd))
					{
						newLast ^= check;
						newAll ^= check;
					}
					if(KMathUtil.hasIntersection(p, oldEnd, newEnd))
						newAll ^= check;
					
					if((newAll & check) != 0)
						insideCount ++ ;
					
					check <<= 1;
				}
				_all[_lastChecked] = newAll;
				_last[_lastChecked] = newLast;
			}
			return insideCount;
		}
		
		/**
		 * Gets the total number of points being tested for selection
		 * intersection.
		 * 
		 * @param object The target object.
		 * @return The total number of points being tested for selection intersection.
		 */
		protected function testPointsCount(object:KObject):uint
		{
			// case: the object is a stroke
			// return the stroke's number of points
			if(object is KStroke)
				return (object as KStroke).points.length;
			
			// case: the object is an image
			// return the image's number of points
			else if(object is KImage)
				return (object as KImage).points.length;
			
			// case: the object is something else
			// return an error
			else
				throw new Error("not supported kobject: "+object);
		}
		
		/**
		 * Gets the set of points that are used for selection
		 * intersection.
		 * 
		 * @param object The target object.
		 * @return The set of points that are used for selection intersection.
		 */
		protected function scaledBoundingBox(object:KObject):Vector.<Point>
		{
			// case: the object is a stroke
			// return the stroke's set of points
			if(object is KStroke)
				return (object as KStroke).points;
			
			// case: the object is an image
			// return the image's set of points
			else if(object is KImage)
				return (object as KImage).points;
			
			// case: the object is something else
			// return an error
			else
				throw new Error("not supported kobject: "+object);
		}
	}
}
/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.operation.implementations
{
	import flash.geom.Point;

	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.model.KStroke;
	import sg.edu.smu.ksketch.operation.IModelOperation;
	
	public class KChangeStrokeOperation implements IModelOperation
	{
		private var _stroke:KStroke;
		private var _oldPoints:Vector.<Point>;
		private var _newPoints:Vector.<Point>;
		
		/**
		 * Operation to change the geometry of the stroke. 
		 */
		public function KChangeStrokeOperation(stroke:KStroke, newPoints:Vector.<Point>)
		{
			_stroke = stroke;
			_newPoints = newPoints;
			_oldPoints = new Vector.<Point>();
			for (var i:int; i < _stroke.points.length; i++)
				_oldPoints.push(_stroke.points[i]);
		}
		
		public function apply():void
		{
			_stroke.setPoints(_newPoints);
			_stroke.dispatchEvent(new KObjectEvent(_stroke,KObjectEvent.EVENT_POINTS_CHANGED));
		}
		
		public function undo():void
		{
			_stroke.setPoints(_oldPoints);
			_stroke.dispatchEvent(new KObjectEvent(_stroke,KObjectEvent.EVENT_POINTS_CHANGED));
		}
	}
}
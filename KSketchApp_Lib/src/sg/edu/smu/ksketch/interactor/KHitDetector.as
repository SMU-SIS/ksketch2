package sg.edu.smu.ksketch.interactor
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.components.KCanvas;
	import sg.edu.smu.ksketch.components.KGroupView;
	import sg.edu.smu.ksketch.components.KImageView;
	import sg.edu.smu.ksketch.components.KObjectView;
	import sg.edu.smu.ksketch.components.KPathView;
	import sg.edu.smu.ksketch.components.KStrokeView;
	import sg.edu.smu.ksketch.model.KObject;
	
	/**
	 * Created by KOH Quee Boon on 2 Aug 2011. 
	 * <p>A subclass of KOperationMgr to support Visibility operations in KModelFacade.</p>
	 */	
	public class KHitDetector
	{	
		private var _x:Number, _y:Number;
		private var _lastPathView:KPathView;
		private var _canvas:KCanvas;
		
		public function get lastPathView():KPathView
		{
			return _lastPathView;
		}
		
		public function KHitDetector(canvas:KCanvas)
		{
			_canvas = canvas;
		}
		
		public function reset(p:Point):void
		{
			_x = p.x;
			_y = p.y;
		}		
		
		/**
		 * Loop through clip children to detect if any of the strokes or images hits point p.
		 * If hits, return the stroke. When used in facade, each visible stroke will not be
		 * detected more than once, as the visibility will be set to zero by facade.
		 */
		public function detect(p:Point):KObject
		{	
			var view:KObjectView = _detect(_canvas.objectRoot,_x,_y,p.x,p.y) as KObjectView;
			_x = p.x;
			_y = p.y;
			return view ? view.object : null;
		}
		
		private function _detect(displayObject:DisplayObject,x1:Number,y1:Number,
								 x2:Number,y2:Number):DisplayObjectContainer
		{
	//		var x:Number =  Math.min(x1,x2);
	//		var y:Number =  Math.min(y1,y2);
	//		var rect:Rectangle = new Rectangle(x,y,Math.abs(x2-x1),Math.abs(y2-y1));
	//		if (!rect.intersects(displayObject.getBounds(canvas)))
	//			return null;
			var detectedView:DisplayObjectContainer;
			var view:DisplayObjectContainer = displayObject as DisplayObjectContainer;
			if (displayObject is KGroupView || !(displayObject is KObjectView))
			{
				view = displayObject is KGroupView ? displayObject as KGroupView : view;				
				for(var i:int = 0; i < view.numChildren; i++)
					if ((detectedView = _detect(view.getChildAt(i),x1,y1,x2,y2)))
						return detectedView;
			}
			else if (displayObject is KObjectView)
			{ 
				view = displayObject as KObjectView;
				return view.alpha > KObjectView.GHOST_ALPHA && _hit(view,x1,y1,x2,y2) && 
					(view is KStrokeView || view is KImageView) ? view : null;
			}
			return null;
		}

		// Obtain the hit test of the obj for each pixel on the line from (x1,y1) to (x2,y2).
		private function _hit(obj:DisplayObject,x1:Number,y1:Number,x2:Number,y2:Number):Boolean
		{
			obj.cacheAsBitmap = true;
			if (x1 == x2 && y1 == y2 || Math.abs(x1 - x2) > 20 || Math.abs(y1 - y2) > 20)
				return obj.hitTestPoint(x2,y2,true);
			var distance:Number = Math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
			var number_of_points:Number = Math.floor(distance);
			var dx:Number = (x2-x1)/number_of_points;
			var dy:Number = (y2-y1)/number_of_points;
			for (var i:int = 0; i <= number_of_points; i++)
				if (obj.hitTestPoint(x1+i*dx,y1+i*dy,true))
					return true;
			return false;
		}		
	}	
}
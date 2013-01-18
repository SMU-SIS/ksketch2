package views.canvas.components
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.widgets.IWidget;
	import sg.edu.smu.ksketch2.utils.KSelection;
	import sg.edu.smu.ksketch2.view.KModelDisplay;
	
	public class KMobileWidget extends MultiTouchTransformWidget implements IWidget
	{
		public var display:KModelDisplay;
		private var _interactionControl:IInteractionControl;
		
		public function KMobileWidget()
		{
			super();
		}
		
		public function init(interactionControl:IInteractionControl):void
		{
			visible = false;
			_interactionControl = interactionControl;	
		}
		
		public function get center():Point
		{
			return new Point(x, y);
		}
		
		public function set isMovingCenter(value:Boolean):void{}
		
		public function get isMovingCenter():Boolean{return false;}
		
		public function highlightSelection(selection:KSelection, time:int):void
		{
			if(!selection)
			{
				visible = false;
				return;
			}
			
			if(!selection.isVisible(time))
			{
				visible = false;
				return;
			}
			else
				visible = true;
			
			var length:int = selection.objects.length();
			
			if(length == 0)
			{
				visible = false;
				return;
			}
			
			var selectionCentroid:Point = selection.centerAt(time);
			
			x = selectionCentroid.x;
			y = selectionCentroid.y;
			
			if(display)
			{
				var point:Point = display.localToGlobal(center);
				point = parent.globalToLocal(point);
				x = point.x;
				y = point.y;
			}
			
/*			if(selection.selectionTransformable(time)|| (_interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED))
				_enableWidget();
			else
				_disableWidget();*/
		}
	}
}
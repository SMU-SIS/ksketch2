package views.canvas.interactors
{
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactors.KTransitionInteractor;
	
	public class KOrientToPathInteractor extends KTransitionInteractor
	{
		public function KOrientToPathInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl)
		{
			super(KSketchInstance, interactionControl);
		}
		
		override protected function _prepareTransition():void
		{
			super._prepareTransition();
		}
		
		override protected function _updateTransition(point:Point):void
		{
			
		}
		
		override protected function _endTransition():void
		{
			super._endTransition();
		}
	}
}
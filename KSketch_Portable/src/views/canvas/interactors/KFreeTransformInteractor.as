package views.canvas.interactors
{
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactioncontrol.IInteractionControl;
	import sg.edu.smu.ksketch2.controls.interactors.KTransitionInteractor;
	
	public class KFreeTransformInteractor extends KTransitionInteractor
	{
		public function KFreeTransformInteractor(KSketchInstance:KSketch2, interactionControl:IInteractionControl)
		{
			super(KSketchInstance, interactionControl);
		}
		
		override protected function _prepareTransition():void
		{
			
		}
		
		override protected function _endTransition():void
		{
			
		}
		
		public function transform(dx:Number, dy:Number, dTheta:Number, dScale:Number):void	
		{
			
		}
	}
}
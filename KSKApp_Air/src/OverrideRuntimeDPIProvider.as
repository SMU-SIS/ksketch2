package
{
	import flash.system.Capabilities;
	
	import mx.core.RuntimeDPIProvider;
	import sg.edu.smu.ksketch2.KSketchStyleSheet;
	
	public class OverrideRuntimeDPIProvider extends RuntimeDPIProvider
	{
		override public function get runtimeDPI():Number
		{
			trace("Screen X: " + Capabilities.screenResolutionX);
			trace("Screen Y: " + Capabilities.screenResolutionY);
			
			if(Capabilities.screenResolutionX > 1280 && Capabilities.screenResolutionY > 1500)
			{
				KSketchStyleSheet.scaleHome(2);	
				KSketchStyleSheet.scaleCanvas(1.8);
				KSketchStyleSheet.scaleFont(2);	
			}
			else if(Capabilities.screenResolutionX > 1280 && Capabilities.screenResolutionY < 1500)
			{
				KSketchStyleSheet.scaleHome(2);
				KSketchStyleSheet.scaleCanvas(1.4);
				KSketchStyleSheet.scaleFont(2);	
			}
			
			return super.runtimeDPI;
		}
	}
}
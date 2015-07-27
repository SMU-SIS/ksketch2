package
{
	import flash.system.Capabilities;
	
	import mx.core.RuntimeDPIProvider;
	import sg.edu.smu.ksketch2.KSketchStyles;
	
	public class OverrideRuntimeDPIProvider extends RuntimeDPIProvider
	{
		override public function get runtimeDPI():Number
		{
			trace("Screen X: " + Capabilities.screenResolutionX);
			trace("Screen Y: " + Capabilities.screenResolutionY);
			
			if(Capabilities.screenResolutionX > 1280 && Capabilities.screenResolutionY > 1500)
			{
				//KSketchStyles.scaleHome(2);	
				//KSketchStyles.scaleCanvas(1.8);
				//KSketchStyles.scaleFont(2);	
			}
			else if(Capabilities.screenResolutionX > 1280 && Capabilities.screenResolutionY < 1500)
			{
				//KSketchStyles.scaleHome(2);
				//KSketchStyles.scaleCanvas(1.4);
				//KSketchStyles.scaleFont(2);	
			}
			
			return super.runtimeDPI;
		}
	}
}
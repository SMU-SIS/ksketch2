package
{
	import flash.system.Capabilities;
	
	import mx.core.RuntimeDPIProvider;
	import sg.edu.smu.ksketch2.KSketchStyles;
	
	public class OverrideRuntimeDPIProvider extends RuntimeDPIProvider
	{
		override public function get runtimeDPI():Number
		{
			//For iPad retina display
			if(Capabilities.version.indexOf('IOS') > -1)
			{
				if (Capabilities.screenResolutionX > 1500)
				{
					KSketchStyles.scaleUp(2);
				}	
			}
			
			return super.runtimeDPI;
		}
	}
}
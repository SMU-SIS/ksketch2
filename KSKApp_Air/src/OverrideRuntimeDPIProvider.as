package
{
	import flash.system.Capabilities;
	
	import mx.core.RuntimeDPIProvider;
	import sg.edu.smu.ksketch2.KSketchStyles;
	
	public class OverrideRuntimeDPIProvider extends RuntimeDPIProvider
	{
		public function OverrideRuntimeDPIProvider()
		{
		}
		
		override public function get runtimeDPI():Number
		{
			//For retina display
			if (Capabilities.screenResolutionX > 1500)
			{
				KSketchStyles.scaleUp(2);
			}
			
			return super.runtimeDPI;
		}
	}
}
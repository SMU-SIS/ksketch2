package sg.edu.smu.ksketch2.canvas.components.popup
{
	import spark.skins.spark.TitleWindowSkin;
	
	public class HeaderlessSkin extends TitleWindowSkin
	{
		public function HeaderlessSkin()
		{
			super();
			topGroup.includeInLayout = false;
		}
	}
}
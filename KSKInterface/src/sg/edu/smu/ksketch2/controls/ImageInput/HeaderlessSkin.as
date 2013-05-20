package sg.edu.smu.ksketch2.controls.ImageInput
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
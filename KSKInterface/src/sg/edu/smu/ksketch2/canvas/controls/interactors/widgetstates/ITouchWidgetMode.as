package sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates
{
	public interface ITouchWidgetMode
	{
		function init():void;
		function activate():void;
		function deactivate():void;
		function set demonstrationMode(demo:Boolean):void
		function set enabled(enable:Boolean):void;
	}
}
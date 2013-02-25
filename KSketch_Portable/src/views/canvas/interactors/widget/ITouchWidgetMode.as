package views.canvas.interactors.widget
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
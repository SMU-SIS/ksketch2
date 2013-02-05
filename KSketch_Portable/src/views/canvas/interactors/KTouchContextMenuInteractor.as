package views.canvas.interactors
{
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TapGesture;
	
	import views.canvas.components.transformWidget.TouchWidgetTemplate;

	public class KTouchContextMenuInteractor
	{
		private var _widget:TouchWidgetTemplate;

		private var _doubleTap:TapGesture; //Gesture for activating context menu
		private var _tap:TapGesture; // Gesture for tap to exit
		
		public function KTouchContextMenuInteractor(widget:TouchWidgetTemplate)
		{
			_widget = widget;
			
			_doubleTap = new TapGesture(widget.freeTransformTrigger);
			_doubleTap.numTapsRequired = 2;
			_doubleTap.maxTapDelay = 200;
			_doubleTap.addEventListener(GestureEvent.GESTURE_RECOGNIZED, showContextMenu);
			
			_tap = new TapGesture(widget.contextMenuOverlay);
			_tap.addEventListener(GestureEvent.GESTURE_RECOGNIZED, hideContextMenu);
		}
		
		public function showContextMenu(event:GestureEvent):void
		{
			_widget.showContextMenu();
		}
		
		public function hideContextMenu(event:GestureEvent):void
		{
			_widget.hideContextMenu();
		}
		
		public function contextMenuTrigger1():void
		{
			trace("Context menu trigger 1");	
		}
		
		public function contextMenuTrigger2():void
		{
			trace("Context menu trigger 2");
		}
	}
}
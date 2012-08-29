package sg.edu.smu.ksketch.gestures
{
	import flash.utils.Dictionary;
	
	public class GestureDesign extends Object
	{
		public static const NAME_PRE_UNDO:String = "Undo";
		public static const NAME_PRE_REDO:String = "Redo";
		public static const NAME_PRE_CUT:String = "Cut";
		public static const NAME_PRE_COPY:String = "Copy";
		public static const NAME_PRE_PASTE:String = "Paste";
		//paste with motions
		public static const NAME_PRE_PASTE_WITH_MOTIONS:String = "Paste With Motions";
		
		//	public static const NAME_PRE_TOGGLE:String = "Toggle-Pen-and-Erase";
		public static const NAME_PRE_TOGGLE:String = "Switch-to-Eraser";
		public static const NAME_PRE_SELECT_PEN:String = "Open-Pen-Selection-Menu";
		public static const NAME_PRE_SHOW_CONTEXT_MENU:String = "Open-Context-Menu";
		public static const NAME_PRE_CYCLE_NEXT:String = "Cycle-Next-After-Selecting";
		public static const NAME_PRE_CYCLE_PREV:String = "Cycle-Previous-After-Selecting";
		
		public static const NAME_POST_CYCLE_NEXT:String = "Cycle-Next-During-Selecting";
		public static const NAME_POST_CYCLE_PREV:String = "Cycle-Previous-During-Selecting";
		
		[Bindable]
		public var name:String;
		private var _mapping:Object;
		
		private static var _design1:GestureDesign;
		private static var _design2:GestureDesign;
		private static var _design3:GestureDesign;
		private static var _design4:GestureDesign;
		
		public function GestureDesign(designName:String)
		{
			name = designName;
			_mapping = new Object();
		}
		
		public function get mapping():Object
		{
			return _mapping;
		}
		
		public static function get design1():GestureDesign
		{
			if(_design1 == null)
			{
				_design1 = new GestureDesign("design1");
				_design1.mapping[NAME_PRE_UNDO] = GestureDefs.instance.LINE_LEFT;
				_design1.mapping[NAME_PRE_REDO] = GestureDefs.instance.LINE_RIGHT;
				_design1.mapping[NAME_PRE_COPY] = GestureDefs.instance.ALPHABET_C;
				_design1.mapping[NAME_PRE_TOGGLE] = GestureDefs.instance.LINE_UP;
				_design1.mapping[NAME_PRE_SELECT_PEN] = GestureDefs.instance.PIGTAIL_BOTTOM_UP;
				_design1.mapping[NAME_PRE_SHOW_CONTEXT_MENU] = GestureDefs.instance.TAP;
				_design1.mapping[NAME_PRE_CYCLE_NEXT] = GestureDefs.instance.POLYLINE_RIGHT_LEFT;
				_design1.mapping[NAME_PRE_CYCLE_PREV] = GestureDefs.instance.POLYLINE_LEFT_RIGHT;
				
				//new added gestures
				_design1.mapping[NAME_PRE_CUT] = GestureDefs.instance.ALPHABET_Z;
				_design1.mapping[NAME_PRE_PASTE] = GestureDefs.instance.ALPHABET_V;
				//paste with motions
				_design1.mapping[NAME_PRE_PASTE_WITH_MOTIONS] = GestureDefs.instance.ALPHABET_M;
				
				
				_design1.mapping[NAME_POST_CYCLE_NEXT] = GestureDefs.instance.POLYLINE_RIGHT_LEFT;
				_design1.mapping[NAME_POST_CYCLE_PREV] = GestureDefs.instance.POLYLINE_LEFT_RIGHT;
			}
			return _design1;
		}
		
		public static function get design2():GestureDesign
		{
			if(_design2 == null)
			{
				_design2 = new GestureDesign("design2");
				_design2.mapping[NAME_PRE_UNDO] = GestureDefs.instance.LINE_LEFT;
				_design2.mapping[NAME_PRE_REDO] = GestureDefs.instance.LINE_RIGHT;
				
				_design2.mapping[NAME_PRE_CUT] = GestureDefs.instance.ALPHABET_X;
				//  _design2.mapping[NAME_PRE_CUT] = GestureDefs.instance.ALPHABET_Z;
				
				_design2.mapping[NAME_PRE_COPY] = GestureDefs.instance.ALPHABET_C;
				
				_design2.mapping[NAME_PRE_PASTE] = GestureDefs.instance.ALPHABET_V;
				//  _design2.mapping[NAME_PRE_PASTE] = GestureDefs.instance.LINE_DOWN;
				
				_design2.mapping[NAME_PRE_TOGGLE] = GestureDefs.instance.POLYLINE_UP_DOWN;   
				
				_design2.mapping[NAME_PRE_SELECT_PEN] = GestureDefs.instance.LINE_UP; 
				_design2.mapping[NAME_PRE_SHOW_CONTEXT_MENU] = GestureDefs.instance.TAP;
				_design2.mapping[NAME_PRE_CYCLE_NEXT] = GestureDefs.instance.POLYLINE_RIGHT_LEFT;
				_design2.mapping[NAME_PRE_CYCLE_PREV] = GestureDefs.instance.POLYLINE_LEFT_RIGHT;
				
				_design2.mapping[NAME_POST_CYCLE_NEXT] =  GestureDefs.instance.POLYLINE_RIGHT_LEFT;
				_design2.mapping[NAME_POST_CYCLE_PREV] = GestureDefs.instance.POLYLINE_LEFT_RIGHT;
			}
			return _design2;
		}
		
		public static function get design3():GestureDesign
		{
			if(_design3 == null)
			{
				_design3 = new GestureDesign("design3");
				_design3.mapping[NAME_PRE_UNDO] = GestureDefs.instance.LINE_LEFT;
				_design3.mapping[NAME_PRE_REDO] = GestureDefs.instance.LINE_RIGHT;
				
				_design3.mapping[NAME_PRE_COPY] = GestureDefs.instance.LEFT_DOWN_RIGHT;
				_design3.mapping[NAME_PRE_PASTE] = GestureDefs.instance.DOWN_RIGHT_UP;
				_design3.mapping[NAME_PRE_CUT] = GestureDefs.instance.DOWN_RIGHT_INTERSECT_UP;
				
				_design3.mapping[NAME_PRE_TOGGLE] = GestureDefs.instance.LINE_UP;
				_design3.mapping[NAME_PRE_SELECT_PEN] = GestureDefs.instance.PIGTAIL;
				_design3.mapping[NAME_PRE_SHOW_CONTEXT_MENU] = GestureDefs.instance.TAP;
				_design3.mapping[NAME_PRE_CYCLE_NEXT] = GestureDefs.instance.POLYLINE_RIGHT_LEFT;
				_design3.mapping[NAME_PRE_CYCLE_PREV] = GestureDefs.instance.POLYLINE_LEFT_RIGHT;
				
				
				_design3.mapping[NAME_POST_CYCLE_NEXT] = GestureDefs.instance.POLYLINE_RIGHT_LEFT;
				_design3.mapping[NAME_POST_CYCLE_PREV] = GestureDefs.instance.POLYLINE_LEFT_RIGHT;
			}
			return _design3;
		}
		
		public static function get design4():GestureDesign
		{
			if(_design4 == null)
			{
				_design4 = new GestureDesign("design4");
				_design4.mapping[NAME_PRE_UNDO] = GestureDefs.instance.LINE_LEFT;
				_design4.mapping[NAME_PRE_REDO] = GestureDefs.instance.LINE_RIGHT;
				
				_design4.mapping[NAME_PRE_COPY] = GestureDefs.instance.LEFT_DOWN_RIGHT;
				_design4.mapping[NAME_PRE_PASTE] = GestureDefs.instance.DOWN_RIGHT_UP;
				_design4.mapping[NAME_PRE_CUT] = GestureDefs.instance.DOWN_RIGHT_INTERSECT_UP;
				
				_design4.mapping[NAME_PRE_TOGGLE] = GestureDefs.instance.ALPHABET_Z;
				_design4.mapping[NAME_PRE_SELECT_PEN] = GestureDefs.instance.LINE_UP;
				_design4.mapping[NAME_PRE_SHOW_CONTEXT_MENU] = GestureDefs.instance.TAP;
				_design4.mapping[NAME_PRE_CYCLE_NEXT] = GestureDefs.instance.POLYLINE_RIGHT_LEFT;
				_design4.mapping[NAME_PRE_CYCLE_PREV] = GestureDefs.instance.POLYLINE_LEFT_RIGHT;
				
				
				_design4.mapping[NAME_POST_CYCLE_NEXT] = GestureDefs.instance.POLYLINE_RIGHT_LEFT;
				_design4.mapping[NAME_POST_CYCLE_PREV] = GestureDefs.instance.POLYLINE_LEFT_RIGHT;
			}
			return _design4;
		}
		
		public static function isPreGesture(gestureName:String):Boolean
		{
			switch(gestureName)
			{
				case NAME_PRE_UNDO:
				case NAME_PRE_REDO:
				case NAME_PRE_CUT:
				case NAME_PRE_COPY:
				case NAME_PRE_PASTE:
				case NAME_PRE_PASTE_WITH_MOTIONS:
				case NAME_PRE_TOGGLE:
				case NAME_PRE_SELECT_PEN:
				case NAME_PRE_SHOW_CONTEXT_MENU:
				case NAME_PRE_CYCLE_NEXT:
				case NAME_PRE_CYCLE_PREV:
					return true;
				case NAME_POST_CYCLE_NEXT:
				case NAME_POST_CYCLE_PREV:
					return false;
			}
			return false;
		}
		public static function isPostGesture(gestureName:String):Boolean
		{
			return !isPreGesture(gestureName);
		}
	}
}
package sg.edu.smu.ksketch.gestures
{
	public class GestureDefs
	{
		public const ALPHABET_C:String = "Alphabet_C";
		
		public const ALPHABET_V:String = "Alphabet_V";
		//paste with motions
		public const ALPHABET_M:String = "Alphabet_M";
	   
		//new added gesture
		public const LINE_DOWN:String  = "Line_down";   
		
		public const ALPHABET_X:String = "Alphabet_X";
		
		//new added gesture
		public const ALPHABET_Z:String = "Alphabet_Z";  
		
		public const LINE_RIGHT:String = "Line_right";
		public const LINE_LEFT:String = "Line_left";
		
		//revised gesture: using pigtail replace with line_up
		public const PIGTAIL_BOTTOM_UP:String = "Pigtail_bottom_up";
		
		public const LINE_UP:String = "Line_up";
		
		public const POLYLINE_RIGHT_LEFT:String = "Polyline_right_left";
		public const POLYLINE_LEFT_RIGHT:String = "Polyline_left_right";
		public const POLYLINE_UP_DOWN:String = "Polyline_up_down";
		
		public const PIGTAIL:String = "Pigtail";
		
		public const TAP:String = "Tap";
		
		/*
		  New gesture design set for Copy, Paste and Cut
		 */
		
		//Copy gesture
		public const LEFT_DOWN_RIGHT:String = "Left_down_right";
		
		//Paste gesture
		public const DOWN_RIGHT_UP:String = "Down_right_up"; 
		
		//Cut gesture
		public const DOWN_RIGHT_INTERSECT_UP:String = "Down_right_intersect_up";
		
		public const VERTICAL_LINE:String = "Vertical_line";
		
		public static const instance:GestureDefs = new GestureDefs();
	}
}
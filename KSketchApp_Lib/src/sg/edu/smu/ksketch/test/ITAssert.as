/**------------------------------------------------
* Copyright 2012 Singapore Management University
* All Rights Reserved
*
*-------------------------------------------------*/

package sg.edu.smu.ksketch.test
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.utilities.KMathUtil;

	public class ITAssert
	{
		public static function assertNullKeyframe(object:KObject, kskTime:int, type:String):void
		{
	//		if(object.timeline.getKeyframeAt(kskTime, type) != null)
	//			throw new Error("Keyframe expected: Null but is NotNull: "+type+" keyframe of object \""+object.name+"\" at time "+kskTime);
		}
		
		public static function assertNotNullKeyframe(object:KObject, kskTime:int, type:String):void
		{
	//		if(object.timeline.getKeyframeAt(kskTime, type) == null)
	//			throw new Error("Keyframe expected: NotNull but is Null: "+type+" keyframe of object \""+object.name+"\" at time "+kskTime);
		}
		
		public static function assertKeyframeCenter(object:KObject, kskTime:int, type:String, center:Point):void
		{
	//		var keyframe:KCenteredKeyframe = object.timeline.getKeyframeAt(kskTime, type) as KCenteredKeyframe;
	//		if(keyframe == null)
	//			throw new Error("KObject keyframe is null: "+type+" keyframe of object \""+object.name+"\" at time "+kskTime);
			
	//		if(!keyframe.center.equals(center))
	//			throw new Error("Center expected: "+center.toString()+" but was "+keyframe.center.toString());
			
		}
		/**
		 * Check if two Numbers equal. You can designate the tolerance, the default tolerance is 0.00001. If the
		 * absolute value of the difference of two numbers is greater than the tolerance, the return value will 
		 * be false.
		 * @param expected Expected value.
		 * @param actual Actual value.
		 * @param d The tolerance value, default value is 0.00001;
		 * 
		 */		
		public static function assertEquals(expected:Number, actual:Number, d:Number=0.00001):void
		{
			if(Math.abs(expected - actual) > d)
				throw new Error("Expected value: "+expected+"+-"+d+", but was: "+actual);
		}
		/**
		 * Check if two Matrixes equal. You should designate three tolerance values which are used for translation, 
		 * scale and rotation comparision.
		 * @param expected The expected matrix.
		 * @param actual The actual matrix.
		 * @param ttol The tolerance for translation comparision.
		 * @param rtol The tolerance for rotatioin comparision.
		 * @param stol The tolerance for scale comparision.
		 * 
		 */		
		public static function assertMatrixEquals(expected:Matrix, actual:Matrix, ttol:Number, rtol:Number, stol:Number):void
		{
			if(expected.a == Number.POSITIVE_INFINITY || expected.a == Number.NEGATIVE_INFINITY ||
				expected.b == Number.POSITIVE_INFINITY || expected.b == Number.NEGATIVE_INFINITY ||
				expected.c == Number.POSITIVE_INFINITY || expected.c == Number.NEGATIVE_INFINITY ||
				expected.d == Number.POSITIVE_INFINITY || expected.d == Number.NEGATIVE_INFINITY ||
				expected.tx == Number.POSITIVE_INFINITY || expected.tx == Number.NEGATIVE_INFINITY ||
				expected.ty == Number.POSITIVE_INFINITY || expected.ty == Number.NEGATIVE_INFINITY ||
				actual.a == Number.POSITIVE_INFINITY || actual.a == Number.NEGATIVE_INFINITY ||
				actual.b == Number.POSITIVE_INFINITY || actual.b == Number.NEGATIVE_INFINITY ||
				actual.c == Number.POSITIVE_INFINITY || actual.c == Number.NEGATIVE_INFINITY ||
				actual.d == Number.POSITIVE_INFINITY || actual.d == Number.NEGATIVE_INFINITY ||
				actual.tx == Number.POSITIVE_INFINITY || actual.tx == Number.NEGATIVE_INFINITY ||
				actual.ty == Number.POSITIVE_INFINITY || actual.ty == Number.NEGATIVE_INFINITY )
				throw new Error("expected matrix: "+expected.toString()+", but was: "+actual.toString());
			if(ttol < 0 || rtol < 0 || stol < 0)
				throw new Error("MathTools.matrixEqual, tolerance should be greater than 0 or equal 0!");
			
			var pExpected:Point = KMathUtil.getOffset(expected);
			var pActual:Point = KMathUtil.getOffset(actual);
			var rExpected:Number = KMathUtil.getRotation(expected);
			var rActual:Number = KMathUtil.getRotation(actual);
			var sExpected:Number = KMathUtil.getScale(expected);
			var sActual:Number = KMathUtil.getScale(actual);
			
			if(Math.abs(pExpected.x - pActual.x) > ttol)
				throw new Error("expected offset x: "+pExpected.x+ "+-"+ttol+", but was: "+pActual.x);
			
			if( Math.abs(pExpected.y - KMathUtil.getOffset(actual).y) > ttol)
				throw new Error("expected offset y: "+pExpected.y+ "+-"+ttol+", but was: "+pActual.y);
			
			if( Math.abs(rExpected - rActual) > rtol)
				throw new Error("expected rotation: "+rExpected+ "+-"+rtol+", but was: "+rActual);
			
			if( Math.abs(sExpected - sActual) > stol)
				throw new Error("expected scale: "+sExpected+ "+-"+stol+", but was: "+sActual);
			
		}
	}
}
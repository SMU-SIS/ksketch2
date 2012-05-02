/**------------------------------------------------
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 
*-------------------------------------------------*/
package test
{
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.events.FlexEvent;
	
	import sg.edu.smu.ksketch.event.KDataLoadedEvent;
	import sg.edu.smu.ksketch.event.KDataSavedEvent;
	import sg.edu.smu.ksketch.event.KObjectEvent;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.model.KObject;
	import sg.edu.smu.ksketch.test.ITAssert;
	
	public class ITTestUtil
	{
		private static const DEFAULT_TOLERANCE_TRANSLATE:Number = 0.01;
		private static const DEFAULT_TOLERANCE_ROTATE:Number = 0.01;
		private static const DEFAULT_TOLERANCE_SCALE:Number = 0.01;

		private var _playSketchCanvas:PlaySketchCanvas
		private var _nameToBeSet:String;

		public function get application():PlaySketchCanvas
		{
			return _playSketchCanvas;
		}
		
		public function startApplication():void
		{
			_playSketchCanvas = new PlaySketchCanvas();
		//	_playSketchCanvas.appState.centerMode = KAppState.CENTER_REFACTOR;
			
			_playSketchCanvas.addEventListener(FlexEvent.CREATION_COMPLETE, _init);
		}

		private function _init(event:FlexEvent):void
		{
			_playSketchCanvas.appInit(1200, 580, 10, 10);
			
			_playSketchCanvas.facade.addEventListener(KObjectEvent.EVENT_OBJECT_ADDED, setObjectName);
			_playSketchCanvas.update_interface();
			_playSketchCanvas.appState.userOption.showConfirmWindow = false;
			_playSketchCanvas.appCanvas.setFocus();
		}
		
		public function assertMatrix(command:XML):void
		{
			if(command.attribute(KLogger.ASSERTION_OBJECT_NAME).length() <= 0)
				throw new Error(KLogger.ASSERT_MATRIX+" tag error: attribute \""+KLogger.ASSERTION_OBJECT_NAME+"\" is missing");
			var object:KObject = getObjectByName(command.attribute(KLogger.ASSERTION_OBJECT_NAME)[0]);
			if(object == null)
				throw new Error(KLogger.ASSERT_MATRIX+" tag error: no kobject named "
					+ command.attribute(KLogger.ASSERTION_OBJECT_NAME)[0].toString());
			
			var time:int;
			if(command.attribute(KLogger.ASSERTION_TIME).length() <= 0)
				throw new Error(KLogger.ASSERT_MATRIX+" tag error: attribute \""+KLogger.ASSERTION_TIME+"\" is missing");
			else
				time = parseInt(command.attribute(KLogger.ASSERTION_TIME)[0]);
			
			var ttol:Number;
			if(command.attribute(KLogger.MATRIX_TOLERANCE_TRANSLATE).length() > 0)
				ttol = new Number(command.attribute(KLogger.MATRIX_TOLERANCE_TRANSLATE)[0]);
			else
				ttol = DEFAULT_TOLERANCE_TRANSLATE;
			
			var rtol:Number;
			if(command.attribute(KLogger.MATRIX_TOLERANCE_ROTATE).length() > 0)
				rtol = new Number(command.attribute(KLogger.MATRIX_TOLERANCE_ROTATE)[0]);
			else 
				rtol = DEFAULT_TOLERANCE_ROTATE;
			var stol:Number;
			if(command.attribute(KLogger.MATRIX_TOLERANCE_SCALE).length() > 0)
				stol = new Number(command.attribute(KLogger.MATRIX_TOLERANCE_SCALE)[0]);
			else
				stol = DEFAULT_TOLERANCE_SCALE;
			
			var expected:Matrix;
			if(command.attribute(KLogger.MATRIX_A).length() > 0 
				|| command.attribute(KLogger.MATRIX_B).length() > 0 
				|| command.attribute(KLogger.MATRIX_C).length() > 0
				|| command.attribute(KLogger.MATRIX_D).length() > 0 
				|| command.attribute(KLogger.MATRIX_TX).length() > 0
				|| command.attribute(KLogger.MATRIX_TY).length() > 0)
				if(!(command.attribute(KLogger.MATRIX_A).length() > 0 
					&& command.attribute(KLogger.MATRIX_B).length() > 0 
					&& command.attribute(KLogger.MATRIX_C).length() > 0
					&& command.attribute(KLogger.MATRIX_D).length() > 0 
					&& command.attribute(KLogger.MATRIX_TX).length() > 0
					&& command.attribute(KLogger.MATRIX_TY).length() > 0))
					throw new Error(KLogger.ASSERT_MATRIX+" tag error: attribute " + 
						"\""+KLogger.MATRIX_A+"\""+ 
						", \""+KLogger.MATRIX_B+"\""+ 
						", \""+KLogger.MATRIX_C+"\""+ 
						", \""+KLogger.MATRIX_D+"\""+ 
						", \""+KLogger.MATRIX_TX+"\""+ 
						" or \""+KLogger.MATRIX_TY+"\""+" is missing");
				else
					expected = new Matrix(new Number(command.attribute(KLogger.MATRIX_A)[0]),
						new Number(command.attribute(KLogger.MATRIX_B)[0]),
						new Number(command.attribute(KLogger.MATRIX_C)[0]),
						new Number(command.attribute(KLogger.MATRIX_D)[0]),
						new Number(command.attribute(KLogger.MATRIX_TX)[0]),
						new Number(command.attribute(KLogger.MATRIX_TY)[0]));
				else
				{
					expected = new Matrix();
					var strArr:Array;
					var x:Number;
					var y:Number;
					if(command.attribute(KLogger.MATRIX_ROTATE).length() > 0)
					{
						strArr = command.attribute(KLogger.MATRIX_ROTATE).toString().split(" ");
						if(strArr.length == 3)
						{
							x = new Number(strArr[1].toString());
							y = new Number(strArr[2].toString());
							var rotate:Number = (new Number(strArr[0].toString())) /180 * Math.PI;
							expected.translate(-x, -y);
							expected.rotate(rotate);
							expected.translate(x, y);
						}
						else
							throw new Error(KLogger.ASSERT_MATRIX+" tag error: rotate attribute 3 parameters expected but was "
								+ command.attribute(KLogger.MATRIX_ROTATE)[0].toString());
					}
					if(command.attribute(KLogger.MATRIX_SCALE).length() > 0)
					{
						strArr = command.attribute(KLogger.MATRIX_SCALE).toString().split(" ");
						if(strArr.length == 3)
						{
							x = new Number(strArr[1].toString());
							y = new Number(strArr[2].toString());
							var scale:Number = new Number(strArr[0].toString());
							expected.translate(-x, -y);
							expected.scale(scale, scale);
							expected.translate(x, y);
						}
						else
							throw new Error(KLogger.ASSERT_MATRIX+" tag error: scale attribute 3 parameters expected but was "
								+ command.attribute(KLogger.MATRIX_SCALE)[0].toString());
						
					}
					if(command.attribute(KLogger.MATRIX_TRANSLATE).length() > 0)
					{
						strArr = command.attribute(KLogger.MATRIX_TRANSLATE).toString().split(" ");
						if(strArr.length == 2)
							expected.translate(new Number(strArr[0].toString()), new Number(strArr[1].toString()));
						else
							throw new Error(KLogger.ASSERT_MATRIX+" tag error: translate attribute 2 parameters expected but was "
								+ command.attribute(KLogger.MATRIX_TRANSLATE).toString());
					}
				}
			var actual:Matrix = object.getFullPathMatrix(time); //object.getMatrix(time);
			try
			{
				ITAssert.assertMatrixEquals(expected,actual,ttol,rtol,stol);
			}
			catch(e:Error)
			{
				e.message = "Assertion: "+command.toXMLString()+"\n"+e.message;
				throw e;
			}
		}
		
		public function assertKeyframe(command:XML):void
		{
			var list:XMLList = command.attribute(KLogger.ASSERTION_OBJECT_NAME);
			if(list.length() != 1)
				throw new Error(KLogger.ASSERT_KEYFRAME+" element error: no attribute or more than 1 attribute named \""+KLogger.ASSERTION_OBJECT_NAME+"\"");
			var object:KObject = getObjectByName(list[0]);
			if(object == null)
				throw new Error(KLogger.ASSERT_KEYFRAME+" tag error: no kobject named "
					+ list[0].toString());
			
			var time:int;
			list = command.attribute(KLogger.ASSERTION_TIME);
			if(list.length() <= 0)
				throw new Error(KLogger.ASSERT_KEYFRAME+" tag error: attribute \""+KLogger.ASSERTION_TIME+"\" is missing");
			time = parseInt(list[0]);
			
			var type:String;
			if(command.attribute(KLogger.KEYFRAME_TYPE).length() <= 0)
				throw new Error(KLogger.ASSERT_KEYFRAME+" tag error: attribute \""+KLogger.KEYFRAME_TYPE+"\" is missing");
			type = command.attribute(KLogger.KEYFRAME_TYPE)[0];
			
			var isNull:Boolean = false;
			list = command.attribute(KLogger.KEYFRAME_IS_NULL);
			if(list.length() > 1)
				throw new Error(KLogger.ASSERT_KEYFRAME+" tag error: more than 1 attribute named \""+KLogger.KEYFRAME_IS_NULL+"\"");
			else if(list.length() == 1 && list[0].toString() == "true")
				isNull = true;
			
			try
			{
				if(isNull)
					ITAssert.assertNullKeyframe(object, time, type);
				else
					ITAssert.assertNotNullKeyframe(object, time, type);
			}
			catch(e:Error)
			{
				e.message = "Assertion: "+command.toXMLString()+"\n"+e.message;
				throw e;
			}
			
			list = command.attribute(KLogger.KEYFRAME_CENTER);
			if(list.length() > 0)
			{
				//	if(command.attribute(KLogger.KEYFRAME_CENTER).length() > 1)
				//		throw new Error(KLogger.ASSERT_KEYFRAME+" tag error: more than 1 attribute named \""+KLogger.KEYFRAME_CENTER+"\"");
				//	else if(isNull || type != KRotationKeyframe.KEYFRAME_ROTATION && type != KScaleKeyframe.KEYFRAME_SCALE)
				//		throw new Error(KLogger.ASSERT_KEYFRAME+" tag error: invalid tag \""+KLogger.KEYFRAME_CENTER
				//			+"\" with isNull=\""+isNull +"\" and type=\"" + type+"\"");
				var center:Point = _parsePoint(list[0]);
				try
				{
					ITAssert.assertKeyframeCenter(object, time, type, center);
				}
				catch(e:Error)
				{
					e.message = "Assertion: "+command.toXMLString()+"\n"+e.message;
					throw e;
				}
			}
		}
		
		private function _parsePoint(points:String):Point
		{
			var txy:Array = points.split(",");
			if(txy.length==2)
				return new Point(new Number(txy[0]), new Number(txy[1]));
			else
				throw new Error("The point(x,y) cannot be "+points);
		}
		
		public function setObjectName(event:KObjectEvent):void
		{
			if(_nameToBeSet != null)
			{
				_playSketchCanvas.facade.setObjectName(event.object, _nameToBeSet);
				_nameToBeSet = null;
			}
		}
		
		public function getObjectByName(name:String):KObject
		{
			return _playSketchCanvas.facade.getObjectByName(name);
		}
		
		public function dispatchKeyboardEvent(e:KeyboardEvent):void
		{
			_playSketchCanvas.systemManager.stage.dispatchEvent(e);
		}
		
		public function set nameToBeSet(value:String):void
		{
			if(_nameToBeSet != null)
				throw new Error("Last name not set, "+
					"errors probably occured while creating object: "+_nameToBeSet);
			
			_nameToBeSet = value;
		}
		
		public function addFileLoadedListener(fun:Function):void
		{
			_playSketchCanvas.addEventListener(KDataLoadedEvent.EVENT_DATA_LOADED, fun);
		}
		
		public function addFileSavedListener(fun:Function):void
		{
			_playSketchCanvas.addEventListener(KDataSavedEvent.EVENT_DATA_SAVED, fun);
		}
	}
}
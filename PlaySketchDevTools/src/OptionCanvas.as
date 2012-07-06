/**------------------------------------------------
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 
*-------------------------------------------------*/
package 
{
	import flash.events.Event;
	
	import mx.containers.ViewStack;
	import mx.controls.Button;
	import mx.core.IVisualElement;
	
	import sg.edu.smu.ksketch.gestures.GestureDesign;
	import sg.edu.smu.ksketch.gestures.Recognizer;
	import sg.edu.smu.ksketch.interactor.KGestureRecognizer;
	import sg.edu.smu.ksketch.interactor.UserOption;
	import sg.edu.smu.ksketch.logger.KLogger;
	import sg.edu.smu.ksketch.logger.KPlaySketchLogger;
	import sg.edu.smu.ksketch.operation.KModelFacade;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.NavigatorContent;
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	import spark.components.TabBar;
	import spark.components.TextInput;
	import spark.components.VGroup;
	import spark.events.TextOperationEvent;
	
	public class OptionCanvas extends Group
	{						
		public function OptionCanvas(mainCanvas:PlaySketchCanvas)
		{				
			super();
			var appState:KAppState = mainCanvas.appState;
			var stack:ViewStack = new ViewStack();
			stack.addElement(_createNavigatorContent("Group",_createGroupingGroup(mainCanvas)));
			stack.addElement(_createNavigatorContent("Gesture",_createGestureGroup(appState)));
			stack.addElement(_createNavigatorContent("Animation",_createAnimationGroup(mainCanvas)));
			stack.addElement(_createNavigatorContent("Other",_createOtherGroup(mainCanvas)));
			var tabs:TabBar = new TabBar();
			tabs.dataProvider = stack;
			var vg:VGroup = _createVGroup([tabs,stack]);
			vg.paddingTop = 10;
			vg.paddingBottom = 10;
			vg.paddingLeft = 10;
			vg.paddingRight = 10;
			addElement(vg);
		}
		
		private function _createNavigatorContent(title:String,vg:VGroup):NavigatorContent
		{
			vg.paddingTop = 20;
			vg.paddingLeft = 20;
			var content:NavigatorContent = new NavigatorContent();
			content.label = title;
			content.addElement(vg);
			return content;
		}
		
		private function _createGroupingGroup(mainCanvas:PlaySketchCanvas):VGroup
		{
			var vg:VGroup = new VGroup();
			vg.addElement(_createLabel("Selection Mode"));
			vg.addElement(_addSelectionMode(mainCanvas.appState));
			vg.addElement(_createLabel(""));
			vg.addElement(_createLabel("Grouping Mode"));
			vg.addElement(_addGroupingMode(mainCanvas));
			return vg; 
		}
		
		private function _createGestureGroup(appState:KAppState):VGroup
		{
			var vg:VGroup = new VGroup();
			vg.addElement(_createLabel("Gesture Design Set"));
			vg.addElement(_addDesignGroup(appState));
			vg.addElement(_createLabel(""));
			vg.addElement(_addTimeoutGroup());
			vg.addElement(_createLabel(""));
			vg.addElement(_addAcceptScore());
			return vg; 
		}
		
		private function _createAnimationGroup(mainCanvas:PlaySketchCanvas):VGroup
		{
			var vg:VGroup = new VGroup();
			vg.addElement(_createLabel("Motion Path Visibility"));
			vg.addElement(_addShowMotionPath(mainCanvas.appState));
			vg.addElement(_createLabel(""));
			vg.addElement(_createLabel("Animation Creation Mode"));
			vg.addElement(_addCreationMode(mainCanvas.appState));
			vg.addElement(_createLabel(""));
			vg.addElement(_createLabel("Correct Future Motion"));
			vg.addElement(_addCorrectFutureMode());
			// vg.addElement(_createLabel(""));
			// vg.addElement(_createLabel("Demo Merge Mode"));
			// vg.addElement(_addDemoMergeMode(mainCanvas.facade));
			return vg; 
		}
		
		private function _createOtherGroup(mainCanvas:PlaySketchCanvas):VGroup
		{
			var vg:VGroup = new VGroup();
			//vg.addElement(_createLabel("Canvas Aspect Ratios"));
			//vg.addElement(_addAspectRatio(mainCanvas));
			vg.addElement(_createLabel("Other Options"));
			vg.addElement(_addRightMouseEnabled(mainCanvas.appState));
			vg.addElement(_addShowConfirmWindow(mainCanvas.appState));
			//vg.addElement(_addEnablelog());
			return vg; 
		}
		
		private function _addSelectionMode(appState:KAppState):IVisualElement
		{
			var modes:RadioButtonGroup = new RadioButtonGroup();
			modes.addEventListener(Event.CHANGE, function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_SELECTION_MODE,
					KPlaySketchLogger.CHANGE_SELECTION_MODE_FROM,appState.groupSelectMode,
					KPlaySketchLogger.CHANGE_SELECTION_MODE_TO,modes.selectedValue.toString());
				appState.groupSelectMode = modes.selectedValue.toString();
			});
			var buttons:Array = new Array();
			var selections:Array = [KAppState.SELECTION_GROUP,
				KAppState.SELECTION_STROKE,KAppState.SELECTION_GROUP_AND_STROKE];
			for (var i:int = 0; i < selections.length; i++)
				buttons.push(_createRadioButton(selections[i],selections[i],
					appState.groupSelectMode == selections[i], modes));
			return _createVGroup(buttons);
		}
		
		private function _addGroupingMode(mainCanvas:PlaySketchCanvas):IVisualElement
		{
			var impMode:String = KAppState.GROUPING_IMPLICIT_DYNAMIC;
			var expMode:String = KAppState.GROUPING_EXPLICIT_DYNAMIC;
			var staMode:String = KAppState.GROUPING_EXPLICIT_STATIC;
			var appState:KAppState = mainCanvas.appState;
			var modes:RadioButtonGroup = new RadioButtonGroup();
			modes.addEventListener(Event.CHANGE, function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_GROUPING_MODE, 
					KPlaySketchLogger.CHANGE_GROUPING_MODE_FROM, appState.groupingMode,
					KPlaySketchLogger.CHANGE_GROUPING_MODE_TO, modes.selectedValue.toString());
				appState.groupingMode = modes.selectedValue.toString();
				appState.fireGroupingEnabledChangedEvent();
				if(appState.groupingMode == impMode)
				{
					mainCanvas.group_groupOps.includeInLayout = false;
					mainCanvas.group_groupOps.visible = false;
				}
				else
				{
					mainCanvas.group_groupOps.includeInLayout = true;
					mainCanvas.group_groupOps.visible = true;
				}
			});
			var buttons:Array = new Array();
			var groupings:Array = [impMode,expMode,staMode];
			for (var i:int = 0; i < groupings.length; i++)
				buttons.push(_createRadioButton(groupings[i],groupings[i],
					appState.groupingMode == groupings[i], modes));
			return _createVGroup(buttons);
		}
				
		private function _addCreationMode(appState:KAppState):IVisualElement
		{
			var modes:RadioButtonGroup = new RadioButtonGroup();
			modes.addEventListener(Event.CHANGE, function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_CREATION_MODE, 
					KPlaySketchLogger.CHANGE_CREATION_MODE_FROM, appState.creationMode,
					KPlaySketchLogger.CHANGE_CREATION_MODE_TO, modes.selectedValue.toString());
				appState.creationMode = modes.selectedValue.toString();
			});
			var buttons:Array = new Array();
			var creations:Array = [KAppState.CREATION_INTERPOLATE,
				KAppState.CREATION_DEMONSTRATE,KAppState.CREATION_INTERPOLATE_DEMONSTRATE];
			for (var i:int = 0; i < creations.length; i++)
				buttons.push(_createRadioButton(creations[i],creations[i],
					appState.creationMode == creations[i], modes));
			return _createVGroup(buttons);
		}
		
		private function _addShowMotionPath(appState:KAppState):IVisualElement
		{
			var modes:RadioButtonGroup = new RadioButtonGroup();
			modes.addEventListener(Event.CHANGE, function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_PATH_VISIBILITY, 
					KPlaySketchLogger.CHANGE_PATH_VISIBILITY_FROM, appState.userOption.showPath,
					KPlaySketchLogger.CHANGE_PATH_VISIBILITY_TO, modes.selectedValue.toString());
				appState.userOption.showPath = modes.selectedValue.toString();
			});
			var buttons:Array = new Array();
			var labels:Array = ["Show all motion paths for this object",
				"Show the active motion paths for this object","Do not show motion paths"];
			var options:Array = [UserOption.SHOW_PATH_ALL,
				UserOption.SHOW_PATH_ACTIVE,UserOption.SHOW_PATH_NONE];
			for (var i:int = 0; i < options.length; i++)
				buttons.push(_createRadioButton(labels[i],options[i],
					appState.userOption.showPath == options[i], modes));
			return _createVGroup(buttons);
		}
		
		private function _addCorrectFutureMode():IVisualElement
		{
			var modes:RadioButtonGroup = new RadioButtonGroup();
			modes.addEventListener(Event.CHANGE, function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_CORRECT_FUTURE_MOTION, 
					KPlaySketchLogger.CHANGE_CORRECT_FUTURE_MOTION_FROM, KAppState.erase_real_time_future,
					KPlaySketchLogger.CHANGE_CORRECT_FUTURE_MOTION_TO, modes.selectedValue.toString());
				KAppState.erase_real_time_future = modes.selectedValue;
			});
			var buttons:Array = new Array();
			var labels:Array = ["Keep Future Motion","Erase Future Motion"];
			var options:Array = [false,true];
			for (var i:int = 0; i < options.length; i++)
				buttons.push(_createRadioButton(labels[i],options[i],
					KAppState.erase_real_time_future == options[i], modes));
			return _createVGroup(buttons);
		}
		
		/*	
		private function _addDemoMergeMode(facade:KModelFacade):IVisualElement
		{
		var modes:RadioButtonGroup = new RadioButtonGroup();
		modes.addEventListener(Event.CHANGE, function(event:Event):void
		{
		KLogger.log(KLogger.CHANGE_DEMO_MERGE_MODE,
		KLogger.CHANGE_DEMO_MERGE_MODE_FROM, facade.getDemoMergeMode(),
		KLogger.CHANGE_DEMO_MERGE_MODE_TO, modes.selectedValue.toString());
		facade.setDemoMergeMode(modes.selectedValue.toString());
		});
		var buttons:Array = new Array();
		var futures:Array = [KModelFacade.ERASE_SAME,KModelFacade.KEEP_THRESHOLD];
		for (var i:int = 0; i < futures.length; i++)
		buttons.push(_createRadioButton(futures[i],futures[i],
		facade.getDemoMergeMode() == futures[i], modes));
		return _createVGroup(buttons);
		}		
		*/	
		private function _addDesignGroup(appState:KAppState):IVisualElement
		{
			var modes:RadioButtonGroup = new RadioButtonGroup();
			modes.addEventListener(Event.CHANGE, function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_GESTURE_DESIGN,
					KPlaySketchLogger.CHANGE_GESTURE_DESIGN_FROM, appState.gestureDesignName,
					KPlaySketchLogger.CHANGE_GESTURE_DESIGN_TO, modes.selectedValue.toString());
				appState.gestureDesignName = modes.selectedValue.toString();
			});
			var buttons:Array = new Array();
			var designs:Array = [GestureDesign.design1.name,GestureDesign.design2.name];
			var labels:Array = ["Use gesture design:"+designs[0],"Use gesture design:"+designs[1]];
			for (var i:int = 0; i < designs.length; i++)
				buttons.push(_createRadioButton(labels[i],designs[i],
					appState.gestureDesignName == designs[i], modes));
			return _createVGroup(buttons);
		}
		
		private function _addTimeoutGroup():IVisualElement
		{
			var lbl_timeout:Label = new Label();
			lbl_timeout.text = "Gesture recognition time out (milliseconds): ";
			var ipt_timeout:TextInput = new TextInput();
			ipt_timeout.text = KGestureRecognizer.PEN_PAUSE_TIME.toString();
			ipt_timeout.restrict = "0-9";
			ipt_timeout.addEventListener(TextOperationEvent.CHANGE,function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_GESTURE_RECOGNITION_TIMEOUT,
					KPlaySketchLogger.CHANGE_GESTURE_RECOGNITION_TIMEOUT_FROM, 
					KGestureRecognizer.PEN_PAUSE_TIME,
					KPlaySketchLogger.CHANGE_GESTURE_RECOGNITION_TIMEOUT_TO, ipt_timeout.text);
				KGestureRecognizer.PEN_PAUSE_TIME = Number(ipt_timeout.text);
			});
			return _createVGroup([lbl_timeout,ipt_timeout]);
		}
		
		private function _addAcceptScore():IVisualElement
		{
			var lbl_score:Label = new Label();
			lbl_score.text = "Gesture accepted if score is above: ";
			var ipt_accepted:TextInput = new TextInput();
			ipt_accepted.text = Recognizer.ACCEPT_SCORE.toString();
			ipt_accepted.restrict = ".0-9";
			ipt_accepted.addEventListener(TextOperationEvent.CHANGE,function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_GESTURE_ACCEPTANCE_SCORE,
					KPlaySketchLogger.CHANGE_GESTURE_ACCEPTANCE_SCORE_FROM, 
					Recognizer.ACCEPT_SCORE.toString(),
					KPlaySketchLogger.CHANGE_GESTURE_ACCEPTANCE_SCORE_TO, ipt_accepted.text);
				Recognizer.ACCEPT_SCORE = Number(ipt_accepted.text);
			});
			return _createVGroup([lbl_score,ipt_accepted]);
		}
		
		private function _addAspectRatio(mainCanvas:PlaySketchCanvas):VGroup
		{
			var modes:RadioButtonGroup = new RadioButtonGroup();
			modes.addEventListener(Event.CHANGE, function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_ASPECT_RATIO,
					KPlaySketchLogger.CHANGE_ASPECT_RATIO_FROM, mainCanvas.stageAspectRatio,
					KPlaySketchLogger.CHANGE_ASPECT_RATIO_TO, modes.selectedValue);
				mainCanvas.stageAspectRatio = modes.selectedValue;
			});
			var buttons:Array = new Array();
			var labels:Array = ["4:3","16:9"];
			var aspects:Array = [false,true];
			for (var i:int = 0; i < aspects.length; i++)
				buttons.push(_createRadioButton(labels[i],aspects[i],
					aspects[i], modes));
			return _createVGroup(buttons);
		}
		
		private function _addRightMouseEnabled(appState:KAppState):IVisualElement
		{
			var rightMouseEnabled:CheckBox = new CheckBox();
			rightMouseEnabled.label = "Right mouse button enabled (Desktop version only)";
			rightMouseEnabled.enabled = KAppState.IS_AIR;
			rightMouseEnabled.selected = appState.userOption.rightMouseButtonEnabled;
			rightMouseEnabled.addEventListener(Event.CHANGE, function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_RIGHT_MOUSE_ENABLED,
					KPlaySketchLogger.CHANGE_RIGHT_MOUSE_ENABLED_FROM, 
					appState.userOption.rightMouseButtonEnabled,
					KPlaySketchLogger.CHANGE_RIGHT_MOUSE_ENABLED_TO, rightMouseEnabled.selected);
				appState.userOption.rightMouseButtonEnabled = rightMouseEnabled.selected;
			});
			return rightMouseEnabled;
		}
		
		private function _addShowConfirmWindow(appState:KAppState):IVisualElement
		{
			var showConfirmWindow:CheckBox = new CheckBox();
			showConfirmWindow.label = "Show confirm dialog when tap on the handle center";
			showConfirmWindow.selected = appState.userOption.showConfirmWindow;
			showConfirmWindow.addEventListener(Event.CHANGE, function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_CONFIRM_DIALOG_ENABLED,
					KPlaySketchLogger.CHANGE_CONFIRM_DIALOG_ENABLED_FROM, 
					appState.userOption.showConfirmWindow,
					KPlaySketchLogger.CHANGE_CONFIRM_DIALOG_ENABLED_TO, showConfirmWindow.selected);		
				appState.userOption.showConfirmWindow = showConfirmWindow.selected;
			});
			return showConfirmWindow;
		}
		
		private function _addEnablelog():IVisualElement
		{
			var enableLog:CheckBox = new CheckBox();
			enableLog.label = "Enable application log";
			enableLog.selected = KLogger.enabled;
			enableLog.addEventListener(Event.CHANGE, function(event:Event):void
			{
				KLogger.log(KPlaySketchLogger.CHANGE_APPLICATION_LOG_ENABLED,
					KPlaySketchLogger.CHANGE_APPLICATION_LOG_ENABLED_FROM, KLogger.enabled,
					KPlaySketchLogger.CHANGE_APPLICATION_LOG_ENABLED_TO, enableLog.selected);				
				KLogger.enabled = enableLog.selected;
			});
			return enableLog;			
		}
		
		private function _createLabel(txt:String):Label
		{
			var label:Label = new Label();
			label.text = txt;
			label.setStyle("textDecoration","underline");
			return label;
		}
		
		private function _createVGroup(elements:Array):VGroup
		{
			var vg:VGroup = new VGroup();
			for each (var e:IVisualElement in elements)
			vg.addElement(e);
			return vg;
		}
		
		private function _createRadioButton(label:String,value:Object,selected:Boolean,
											radio_group:RadioButtonGroup):RadioButton
		{
			var button:RadioButton = new RadioButton();
			button.label = label;
			button.value = value;
			button.selected = selected;
			button.group = radio_group;
			return button;
		}				
	}
}
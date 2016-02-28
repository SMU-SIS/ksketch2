/**
 * Copyright 2010-2015 Singapore Management University
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	
	import sg.edu.smu.ksketch2.KSketchAssets;

	public class KSoundControl
	{
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _transform:SoundTransform;
		
		private var _diffActivity:Boolean;
		private var _activity:String = "INTRO";
		
		public function KSoundControl()
		{
			_sound = new KSketchAssets.therapy_sound_background_canvas();
			_channel = new SoundChannel();
			_transform = new SoundTransform(1,0);
		}
		
		public function playSound(numRepeat:int):void
		{
			if(_diffActivity)
			{
				stopSound();
				_channel = _sound.play(0,numRepeat,_transform);
			}
		}
		
		public function playSound_Recall(right:Boolean):void
		{
			if(right)
				_sound = new KSketchAssets.therapy_sound_button_right();
			else
				_sound = new KSketchAssets.therapy_sound_button_wrong();
			
			_channel = _sound.play();
		}
		
		public function stopSound():void
		{
			SoundMixer.stopAll();
		}
		
		public function set result(stars:int):void
		{
			if(stars == 3)
				_sound = new KSketchAssets.therapy_sound_background_win3();
			else if(stars == 2 || stars == 1)
				_sound = new KSketchAssets.therapy_sound_background_win();
			else
				_sound = new KSketchAssets.therapy_sound_background_lose();
			
			_channel = _sound.play();
		}
		
		public function set activity(activity:String):void
		{
			if(_activity != activity)
			{
				_diffActivity = true;
				
				if (activity == "RECALL" || activity == "TRACK")
					_sound = new KSketchAssets.therapy_sound_background_canvas2();
				else
					_sound = new KSketchAssets.therapy_sound_background_canvas();
			}
			else
				_diffActivity = false;
			
			_activity = activity;
		}
	}
}
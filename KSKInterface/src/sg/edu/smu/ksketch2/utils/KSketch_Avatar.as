/**
 * Copyright 2010-2015 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.utils
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import spark.components.Image;	
	import sg.edu.smu.ksketch2.KSketchAssets;

	public class KSketch_Avatar
	{		
		public static var AVATAR_DEFAULT:String = "KSketchAssets.texture_therapy_login";
		
		private static var _avatar_Dictionary:Dictionary;
		public static function get AVATAR_DICTIONARY():Dictionary { return _avatar_Dictionary ? _avatar_Dictionary : getAvatars(); }
		
		private static var _avatar_Negative:Dictionary;
		public static function get AVATAR_NEGATIVE():Dictionary { return _avatar_Negative ? _avatar_Negative : getAvatarsFromXML(false); }
		
		private static var _avatar_XML:Dictionary;
		public static function get AVATAR_XML():Dictionary { return _avatar_XML ? _avatar_XML : getAvatarsFromXML(true); }
		
		[Embed(source="/assets/resource_avatar.xml", mimeType="application/octet-stream")]  
		public var MyXMLData:Class; 		
		public var AVATAR_DATA:XML;
		
		public function KSketch_Avatar()
		{
			var byteArray:ByteArray = new MyXMLData() as ByteArray;  
			AVATAR_DATA = new XML(byteArray.readUTFBytes(byteArray.length));  
		}
		
		/*
			Load image classes for runtime usage
		*/
		private static function getAvatars():Dictionary
		{			
			var imgDic:Dictionary = new Dictionary();
			imgDic["KSketchAssets.texture_therapy_login"]= KSketchAssets.texture_therapy_login;
			imgDic["KSketchAssets.therapy_avatar_boy"] = KSketchAssets.therapy_avatar_boy;
			imgDic["KSketchAssets.therapy_avatar_boy_sad"] = KSketchAssets.therapy_avatar_boy_sad;
			imgDic["KSketchAssets.therapy_avatar_girl"] = KSketchAssets.therapy_avatar_girl;
			imgDic["KSketchAssets.therapy_avatar_girl_sad"] = KSketchAssets.therapy_avatar_girl_sad;
			imgDic["KSketchAssets.therapy_avatar_hamster1"] = KSketchAssets.therapy_avatar_hamster1;
			imgDic["KSketchAssets.therapy_avatar_hamster1_sad"] = KSketchAssets.therapy_avatar_hamster1_sad;
			imgDic["KSketchAssets.therapy_avatar_hamster2"] = KSketchAssets.therapy_avatar_hamster2;
			imgDic["KSketchAssets.therapy_avatar_hamster2_sad"] = KSketchAssets.therapy_avatar_hamster2_sad;
			imgDic["KSketchAssets.therapy_avatar_hamster3"] = KSketchAssets.therapy_avatar_hamster3;	
			imgDic["KSketchAssets.therapy_avatar_hamster3_sad"] = KSketchAssets.therapy_avatar_hamster3_sad;
			return imgDic;
		}
		
		/*
			Read avatar data from xml file then store in dictionary data type
		*/
		private static function getAvatarsFromXML(isPositive:Boolean):Dictionary
		{			
			var imgDic:Dictionary = new Dictionary();
			var avatar:KSketch_Avatar = new KSketch_Avatar();
			for(var i:int=0;i<avatar.AVATAR_DATA.children().length();i++)
			{
				var currentNode:XML = avatar.AVATAR_DATA.children()[i];
				var name:String = isPositive ? currentNode.className.toString() : currentNode.negativeClassName.toString();
				imgDic[currentNode.className.toString()] = AVATAR_DICTIONARY[name];
			}
			return imgDic;
		}
		
		/*
			Create and return an avatar image UIElement
		*/
		public static function generateAvatarImage(obj:Object, imageWidth:int):Image
		{
			var img:Image = new Image();
			img.id = obj.toString();
			img.width = imageWidth;
			var imgClass:Class = KSketch_Avatar.AVATAR_XML[obj] as Class;
			if(imgClass)
				img.source = imgClass;
			return img;
		}
	}
}
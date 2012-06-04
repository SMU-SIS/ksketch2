/**------------------------------------------------
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 
*-------------------------------------------------*/
package Audio
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	public class MicrophoneFunctions
	{	
		private var microphone:Microphone;		
		private var recording:ByteArray;		
		private var sound:Sound;
		private var loader:Loader;			
		private var _fileRef : FileReference;
		private var byteArr:ByteArray;
		
		
		public function startMicRecording():void			
		{									
			recording=new ByteArray();			
			microphone = Microphone.getMicrophone(0);
			//microphone.noiseSuppressionLevel=-30;
			//microphone.enableVAD=true;
			//microphone.setUseEchoSuppression(true);
			//microphone.framesPerPacket=10;//speex	
			microphone.codec="Nellymoser"			
			//microphone.encodeQuality=1;//speex						
			microphone.rate=9;
			microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, getMicAudio);							
		}
		
		private function getMicAudio(event:SampleDataEvent): void			
		{			
			recording.writeBytes(event.data);			
		}
		
		private function playRecorded(event:SampleDataEvent): void			
		{			
			if (!recording.bytesAvailable > 0)				
				return;			
			
			for (var i:int = 0; i < 2048; i++)
			{ 
				var sample:Number = 0; 
				if (recording.bytesAvailable > 0) 
					sample = recording.readFloat();  
				
				for (var j:uint = 0; j < 8; j++) 
				{          
					event.data.writeFloat(sample);
				}				
			} 											
		}			
		
		
		public function playbackData():void			
		{		
			if(recording)
			{
				recording.position = 0;				
				sound = new Sound();				
				sound.addEventListener(SampleDataEvent.SAMPLE_DATA, playRecorded);				
				var channel:SoundChannel	=new SoundChannel();			
				channel = sound.play();
			}
		}
		
		
		public function stopMicRecording():void
		{
			if(recording)
			{microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, getMicAudio);}
		}
		
		public function onbtnSaveSound(event:Event):void
		{										
			var base64Enc:Base64Encoder
			base64Enc=new Base64Encoder();	 
			var myString:String;				
			var bytes:ByteArray = new ByteArray();
			//bytes.writeUnsignedInt(recording.length);
			bytes.writeBytes(recording);			
			bytes.compress();					
			base64Enc.encodeBytes(bytes,0,0);
			myString=base64Enc.toString();					
			var filer:FileReference=new FileReference();		
			var xm:XML =<Sound></Sound>;
			var nodeName:String = "MICROPHONE";
			var xmlList:XMLList = XMLList("<"+nodeName+">"+myString+"</"+nodeName+">");
			xm.appendChild(xmlList);	 		 			
			filer.save(xm, "sound.xml");							
		}	
		
		public function onSaveSelected(event:Event):void
		{
			var soundTypes:FileFilter = new FileFilter("XML( *.xml)", "*.xml");
			var soundTypesArray:Array = new Array(soundTypes);
			_fileRef = new FileReference();
			_fileRef.browse(soundTypesArray);
			_fileRef.addEventListener(Event.SELECT, selectSoundHandler);	
		}
		
		private function selectSoundHandler(evt:Event):void
		{		
			_fileRef.addEventListener(Event.COMPLETE, loadBytesHandler);	
			_fileRef.load();
		}
		
		
		public function loadBytesHandler(event:Event):void
		{					
			if (event.type == Event.COMPLETE)
			{																									
				var prefsXML:XML = new XML(_fileRef.data.readUTFBytes(_fileRef.data.length));																								
				var base64Dec:Base64Decoder=new Base64Decoder();
				byteArr=new ByteArray();	
				base64Dec = new Base64Decoder();
				base64Dec.decode(prefsXML.MICROPHONE)
				byteArr = base64Dec.toByteArray();	
				byteArr.uncompress();	
				
				byteArr.position = 0;				
				sound = new Sound();				
				sound.addEventListener(SampleDataEvent.SAMPLE_DATA, playRecordedSoundFromXML);				
				var channel:SoundChannel=new SoundChannel();				
				channel = sound.play();					
			}	
		}
		
		
		private function playRecordedSoundFromXML(event:SampleDataEvent): void			
		{				
			
			if (!byteArr.bytesAvailable > 0)				
				return;			
			
			for (var i:int = 0; i < 2048; i++)
			{ 
				var sample:Number = 0; 
				if (byteArr.bytesAvailable > 0) 
					sample = byteArr.readFloat(); 
				
				for (var j:uint = 0; j < 8; j++) 
				{          
					event.data.writeFloat(sample); 			
				}													
			} 	
								
		}	
		
	}
}


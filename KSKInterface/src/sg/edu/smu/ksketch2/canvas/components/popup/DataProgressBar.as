/**
 * Copyright 2010-2015 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.components.popup
{
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	
	import spark.components.supportClasses.Range;
	
	/**
	 * A spark-based progress bar component.
	 */
	public class DataProgressBar extends Range
	{
		public function DataProgressBar()
		{
			super();
			snapInterval = 0;
			minimum = 0;
			maximum = 1;
		}
		
		private var _eventSource:IEventDispatcher;
		
		/**
		 * An optional IEventDispatcher dispatching progress events.  The progress events will
		 * be used to update the <code>value</code> and <code>maximum</code> properties.
		 */
		public function get eventSource():IEventDispatcher
		{
			return _eventSource;
		}
		
		/**
		 * @private
		 */
		public function set eventSource(value:IEventDispatcher):void
		{
			if (_eventSource != value)
			{
				removeEventSourceListeners();
				_eventSource = value;
				addEventSourceListeners();
			}
		}
		
		/**
		 * @private
		 * Removes listeners from the event source.
		 */
		protected function removeEventSourceListeners():void
		{
			if (eventSource)
				eventSource.removeEventListener(ProgressEvent.PROGRESS, eventSource_progressHandler);
		}
		
		/**
		 * @private
		 * Adds listeners to the event source.
		 */
		protected function addEventSourceListeners():void
		{
			if (eventSource)
				eventSource.addEventListener(ProgressEvent.PROGRESS, eventSource_progressHandler, false, 0, true);
		}
		
		/**
		 * @private
		 * Updates the <code>value</code> and <code>maximum</code> properties when progress
		 * events are dispatched from the <code>eventSource</code>.
		 */
		protected function eventSource_progressHandler(event:ProgressEvent):void
		{
			value = event.bytesLoaded;
			maximum = event.bytesTotal;
		}
	}
}
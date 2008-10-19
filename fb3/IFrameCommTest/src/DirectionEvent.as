package
{
	import flash.events.Event;

	public class DirectionEvent extends Event
	{
		public static const EVENT_DIRECTION:String = "DirectionEvent"		
		
		public var toValue:String= null;
		public var fromValue:String= null;
		
		public function DirectionEvent(toValue:String, fromValue:String):void
		{
			super(EVENT_DIRECTION, true);
			
			this.toValue = toValue;
			this.fromValue = fromValue;
		}
	}
}


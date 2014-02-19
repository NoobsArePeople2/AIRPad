package airpad
{
	import com.alexomara.ane.AIRControl.controllers.AIRControlController;
	import com.alexomara.ane.AIRControl.events.AIRControlEvent;
	
	public class AIRPadEvent extends AIRControlEvent
	{
		public static const CONNECT:String = "connect";
		public static const DISCONNECT:String = "disconnect";
		
		public var pad:IAIRPadDevice;
		
		public function AIRPadEvent(type:String, controller:AIRControlController, controllerIndex:uint, pad:IAIRPadDevice)
		{
			super(type, controller, controllerIndex);
			this.pad = pad;
		}
	}
}
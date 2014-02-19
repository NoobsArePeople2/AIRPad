package airpad
{
	import flash.utils.Dictionary;

	public interface IAIRPadDevice
	{
		function get name():String;
		function get friendlyName():String;
		function get id():uint;
		function get index():uint;
		function get vendorID():uint;
		function get productID():uint;
		function get deviceID():String;
		
		function get deadZone():Number;
		function set deadZone(value:Number):void;
		function set deadZoneMode(value:String):void;
		function get notes():Dictionary;
		
		function update():void;
		
		function isButtonDown(btn:String):Boolean;
		function wasButtonJustPressed(btn:String):Boolean;
		function wasButtonJustReleased(btn:String):Boolean;
		function setButtonDown(btn:String):void;
		function clearButtonDown(btn:String):void;
		function getStick(stick:String):AIRPadStick;
		function getTrigger(trigger:String):Number;
		function clearState():void;
		
		function bindCommand(command:String, btn:String):void;
		function clearBindings():void;
		function setStickNormalizer(func:Function):void;
		function setTriggerNormalizer(func:Function):void;
		function setMapping(mapping:String):void;
	}
}
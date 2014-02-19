package airpad
{
	import com.alexomara.ane.AIRControl.controllers.AIRControlController;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;

	public class AIRPadHelper
	{
		public static const MAJOR_VERSION:uint = 0;
		public static const MINOR_VERSION:uint = 1;
		public static const BUILD_VERSION:uint = 0;
		public static const VERSION:String = MAJOR_VERSION + '.' + MINOR_VERSION + '.' + BUILD_VERSION;		
		
		public static const PLATFORM_MAC:String = "mac";
		public static const PLATFORM_WIN:String = "win";
		
		private static const MAPPING_PATH:String = "airpad/controller_mappings/";
		
		//===============================
		// Embedded Mappings
		//===============================
		
		[Embed(source="/airpad/controller_mappings/mac-controller.json", mimeType="application/octet-stream")]
		private static var MacController:Class;
		
		[Embed(source="/airpad/controller_mappings/mac-playstation-r-3-controller.json", mimeType="application/octet-stream")]
		private static var MacPlayStation3Controller:Class;
		
		[Embed(source="/airpad/controller_mappings/mac-wiimote-classic-controller.json", mimeType="application/octet-stream")]
		private static var MacWiimoteClassicController:Class;
		
		[Embed(source="/airpad/controller_mappings/mac-wiimote-no-attachments-horizontal.json", mimeType="application/octet-stream")]
		private static var MacWiimoteNoAttachmentsHorizontal:Class;
		
		[Embed(source="/airpad/controller_mappings/mac-wiimote-with-nunchuck.json", mimeType="application/octet-stream")]
		private static var MacWiimoteWithNunchuck:Class;
		
		[Embed(source="/airpad/controller_mappings/win-controller-xbox-360-for-windows.json", mimeType="application/octet-stream")]
		private static var WinXbox360Wired:Class;
		
		[Embed(source="/airpad/controller_mappings/win-controller-xbox-360-wireless-receiver-for-windows.json", mimeType="application/octet-stream")]
		private static var WinXbox360Wireless:Class;
		
		[Embed(source="/airpad/controller_mappings/keyboards/us-english-qwerty.json", mimeType="application/octet-stream")]
		private static var KBUSEnglishQWERTY:Class;
		
		[Embed(source="/airpad/controller_mappings/keyboards/us-english-qwerty-two.json", mimeType="application/octet-stream")]
		private static var KBUSEnglishQWERTY_Two:Class;
		
		private static var mappings:Object = {
			"mac-controller": new MacController(),
			"mac-playstation-r-3-controller": new MacPlayStation3Controller(),
			"mac-wiimote-classic-controller": new MacWiimoteClassicController(),
			"mac-wiimote-no-attachments-horizontal": new MacWiimoteNoAttachmentsHorizontal(),
			"mac-wiimote-with-nunchuck": new MacWiimoteWithNunchuck(),
			
			"win-controller-xbox-360-for-windows": new WinXbox360Wired(),
			"win-controller-xbox-360-wireless-receiver-for-windows": new WinXbox360Wireless(),
			
			"keyboards/us-english-qwerty": new KBUSEnglishQWERTY(),
			"keyboards/us-english-qwerty-two": new KBUSEnglishQWERTY_Two()
		};
		
		/**
		 * Toggle debug mode.
		 */
		public static var debug:Boolean = false;
		
		/**
		 * Load a button mapping.
		 * 
		 * First it looks for mappings included with AIRPad. If a mapping
		 * is not found it looks for mappings <code>app-storage://airpad/controller_mappings/</code>.
		 * 
		 * @param string mappingFile The name of mapping file (without extension) to load.
		 * @return A JSON object if the mapping file is found, <code>null</code> if it's not found.
		 */
		public static function loadMapping(mappingFile:String):Object
		{
			var m:String = mappings[mappingFile];
			if (m)
			{
				return JSON.parse(m);
			}
			
			var path:String = MAPPING_PATH + mappingFile + ".json";
			var file:File = File.applicationStorageDirectory.resolvePath(path);
			if (!file.exists)
			{
				if (AIRPadHelper.debug) trace("Error: file '" + mappingFile + "' could not be found.");
				return null;
			}
			
			try
			{
				var fs:FileStream = new FileStream();
				fs.open(file, FileMode.READ);
				var contents:String = fs.readUTFBytes(file.size);
				fs.close();	
			}
			catch (e:Error)
			{
				if (AIRPadHelper.debug) trace("Error reading config file '" + mappingFile + "'");
				return null;
			}
			
			
			return JSON.parse(contents);
		}
		
		/**
		 * Is this running on a Mac?
		 */
		public static function isMac():Boolean
		{
			return (Capabilities.version.substr(0,3) == "MAC");
		}
		
		/**
		 * Is this running on Windows?
		 */
		public static function isWindows():Boolean
		{
			return (Capabilities.version.substr(0,3) == "WIN");
		}
		
		/**
		 * Normalized name of the platform.
		 * 
		 * Either:
		 * 
		 * <code>AIRPadHelper.PLATFORM_WIN</code> or
		 * <code>AIRPadHelper.PLATFORM_MAC</code>
		 */
		public static function platform():String
		{
			if (isMac()) return PLATFORM_MAC;
			
			return PLATFORM_WIN;
		}
		
		/**
		 * Helper function for generating a <code>deviceID</code>
		 * @see AIRPad.deviceID
		 */
		public static function deviceIDFromController(controller:AIRControlController):String
		{
			return controller.vendorID + "-" + controller.productID;
		}
	}
}
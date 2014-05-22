/**
 * Wrapper for keyboards that matches the AIRPad API.
 *
 * @author		Sean Monahan hello@seanmonahan.org
 * @created     2014-01-02
 * @version		1.0.0
 */
package airpad
{
	//==============================
	// Imports
	//==============================

	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	/**
	 * A keyboard with the same API as <code>AIRPad</code>.
	 */
	public class AIRKeyboard implements IAIRPadDevice
	{
		//==============================
		// Constants
		//==============================

		//==============================
		// Vars
		//==============================

		private var btns:Dictionary;
		private var btnMappings:Dictionary;
		private var bindings:Dictionary;

		private static var keys:Dictionary;

		private var dummyStick:AIRPadStick;
		private var _index:uint;
		private var _deviceID:String;

		//==============================
		// Properties
		//==============================

		public function get name():String
		{
			return "Keyboard";
		}

		public function get friendlyName():String
		{
			return "Keyboard";
		}

		public function get id():uint
		{
			return 0;
		}

		public function get index():uint
		{
			return _index;
		}

		public function get vendorID():uint
		{
			return 0;
		}

		public function get productID():uint
		{
			return 0;
		}

		public function get deviceID():String
		{
			return _deviceID;
		}

		public function get deadZone():Number
		{
			return 0;
		}

		public function set deadZone(value:Number):void {}
		public function set deadZoneMode(value:String):void {}
		public function get notes():Dictionary
		{
			return null;
		}

		//==============================
		// Constructor
		//==============================

		/**
		 * Constructor
		 */
		public function AIRKeyboard(index:uint = 1)
		{
			btns = new Dictionary();
			btnMappings = new Dictionary();
			bindings = new Dictionary();

			mapKeyboard("us-english-qwerty");

			dummyStick = new AIRPadStick();
			_index = index;
			_deviceID = "Keyboard-" + _index;
		}

		//==============================
		// Public Methods
		//==============================

		public function update():void
		{
			var key:String;

			for (key in btns)
			{
				if (btns[key] < 0)
				{
					btns[key] = AIRPadButton.BUTTON_UP;
				}
				else if (btns[key] > 1)
				{
					btns[key] = AIRPadButton.BUTTON_HELD;
				}
			}
		}

		public function isButtonDown(btn:String):Boolean
		{
			if (!btns[btn])
			{
				return false;
			}

			return btns[btn] > 0;
		}

		public function wasButtonJustPressed(btn:String):Boolean
		{
			if (!btns[btn])
			{
				return false;
			}

			return btns[btn] == AIRPadButton.BUTTON_JUST_PRESSED;
		}

		public function wasButtonJustReleased(btn:String):Boolean
		{
			if (!btns[btn])
			{
				return false;
			}

			return btns[btn] == AIRPadButton.BUTTON_JUST_RELEASED;
		}

		public function setButtonDown(btn:String):void
		{
			var key:String = btnMappings[btn];
			var cmd:String = bindings[key];
			if (btns[key] && btns[key] > 0)
			{
				btns[key] = AIRPadButton.BUTTON_HELD;
				if (cmd) btns[cmd] = AIRPadButton.BUTTON_HELD;
			}
			else
			{
				btns[key] = AIRPadButton.BUTTON_JUST_PRESSED;
				if (cmd) btns[cmd] = AIRPadButton.BUTTON_JUST_PRESSED;
			}
		}

		public function clearButtonDown(btn:String):void
		{
			var key:String = btnMappings[btn];
			var cmd:String = bindings[key];
			btns[key] = AIRPadButton.BUTTON_JUST_RELEASED;
			if (cmd) btns[cmd] = AIRPadButton.BUTTON_JUST_RELEASED;
		}

		public function getStick(stick:String):AIRPadStick
		{
			return dummyStick;
		}

		public function getTrigger(trigger:String):Number
		{
			return 0;
		}

		public function clearState():void
		{
			for (var btn:String in btns)
			{
				btns[btn] = AIRPadButton.BUTTON_UP;
			}
		}

		public function bindCommand(command:String, btn:String):void
		{
			bindings[btn] = command;
		}

		public function clearMapping():void
		{
			btnMappings = new Dictionary();
		}

		public function clearBindings():void
		{
			bindings = new Dictionary();
		}

		public function setStickNormalizer(func:Function):void {}
		public function setTriggerNormalizer(func:Function):void {}

		public function setMapping(mapping:String):void
		{
			clearState();
			clearMapping();
			clearBindings();
			mapKeyboard(mapping);
		}

		public static function lookUpKeyCode(keyCode:uint):String
		{
			if (!keys)
			{
				mapKeys();
			}
			return keys[keyCode];
		}

		//==============================
		// Private, Protected Methods
		//==============================

		private function mapKeyboard(mapping:String):void
		{
			var config:Object = AIRPadHelper.loadMapping("keyboards/" + mapping);
			if (!config)
			{
				return;
			}

			if (config.numKeyboards && config.numKeyboards > 1)
			{
				var num:uint = uint(config.numKeyboards);
				var buttons:Object = config.controllers[_index];
				if (!buttons || !buttons.buttons)
				{
					trace("[AIRKeyboard] no mapping found for index '" + _index + "'.");
					trace("[AIRKeyboard] not initializing keyboard.");
					return;
				}
				setKeys(buttons.buttons);
			}
			else
			{
				setKeys(config.buttons);
			}
		}

		private function setKeys(buttons:Object):void
		{
			var data:Object;
			for (var btn:String in buttons)
			{
				if (!btn) continue;
				data = buttons[btn];
				if (!data) continue;

				btnMappings[data.key] = btn;
			}
		}

		private static function mapKeys():void
		{
			keys = new Dictionary();

			keys[Keyboard.A] = "A";
			keys[Keyboard.B] = "B";
			keys[Keyboard.C] = "C";
			keys[Keyboard.D] = "D";
			keys[Keyboard.E] = "E";
			keys[Keyboard.F] = "F";
			keys[Keyboard.G] = "G";
			keys[Keyboard.H] = "H";
			keys[Keyboard.I] = "I";
			keys[Keyboard.J] = "J";
			keys[Keyboard.K] = "K";
			keys[Keyboard.L] = "L";
			keys[Keyboard.M] = "M";
			keys[Keyboard.N] = "N";
			keys[Keyboard.O] = "O";
			keys[Keyboard.P] = "P";
			keys[Keyboard.Q] = "Q";
			keys[Keyboard.R] = "R";
			keys[Keyboard.S] = "S";
			keys[Keyboard.T] = "T";
			keys[Keyboard.U] = "U";
			keys[Keyboard.V] = "V";
			keys[Keyboard.W] = "W";
			keys[Keyboard.X] = "X";
			keys[Keyboard.Y] = "Y";
			keys[Keyboard.Z] = "Z";

			keys[Keyboard.NUMBER_0] = "0";
			keys[Keyboard.NUMBER_1] = "1";
			keys[Keyboard.NUMBER_2] = "2";
			keys[Keyboard.NUMBER_3] = "3";
			keys[Keyboard.NUMBER_4] = "4";
			keys[Keyboard.NUMBER_5] = "5";
			keys[Keyboard.NUMBER_6] = "6";
			keys[Keyboard.NUMBER_7] = "7";
			keys[Keyboard.NUMBER_8] = "8";
			keys[Keyboard.NUMBER_9] = "9";

			keys[Keyboard.BACKQUOTE] = "`";
			keys[Keyboard.MINUS] = "-";
			keys[Keyboard.EQUAL] = "=";
			keys[Keyboard.LEFTBRACKET] = "[";
			keys[Keyboard.RIGHTBRACKET] = "]";
			keys[Keyboard.SEMICOLON] = ";";
			keys[Keyboard.COMMA] = ",";
			keys[Keyboard.PERIOD] = ".";
			keys[Keyboard.SLASH] = "/";
			keys[Keyboard.BACKSLASH] = "\\";
			keys[Keyboard.QUOTE] = "'";

			keys[Keyboard.ESCAPE] = "ESCAPE";
			keys[Keyboard.TAB] = "TAB";
			keys[Keyboard.SHIFT] = "SHIFT";
			keys[Keyboard.CONTROL] = "CTRL";
			keys[Keyboard.ALTERNATE] = "ALT";
			keys[Keyboard.COMMAND] = "CMD";
			keys[Keyboard.SPACE] = "SPACE";
			keys[Keyboard.ENTER] = "ENTER";

			keys[Keyboard.F1] = "F1";
			keys[Keyboard.F2] = "F2";
			keys[Keyboard.F3] = "F3";
			keys[Keyboard.F4] = "F4";
			keys[Keyboard.F5] = "F5";
			keys[Keyboard.F6] = "F6";
			keys[Keyboard.F7] = "F7";
			keys[Keyboard.F8] = "F8";
			keys[Keyboard.F9] = "F9";
			keys[Keyboard.F10] = "F10";
			keys[Keyboard.F11] = "F11";
			keys[Keyboard.F12] = "F12";

			keys[Keyboard.UP] = "UP";
			keys[Keyboard.RIGHT] = "RIGHT";
			keys[Keyboard.DOWN] = "DOWN";
			keys[Keyboard.LEFT] = "LEFT";

			keys[Keyboard.INSERT] = "INSERT";
			keys[Keyboard.DELETE] = "DELETE";
			keys[Keyboard.HOME] = "HOME";
			keys[Keyboard.END] = "END";
			keys[Keyboard.PAGE_UP] = "PAGE_UP";
			keys[Keyboard.PAGE_DOWN] = "PAGE_DOWN";
			keys[Keyboard.BACKSPACE] = "BACKSPACE";

			keys[Keyboard.NUMPAD_0] = "NUM0";
			keys[Keyboard.NUMPAD_1] = "NUM1";
			keys[Keyboard.NUMPAD_2] = "NUM2";
			keys[Keyboard.NUMPAD_3] = "NUM3";
			keys[Keyboard.NUMPAD_4] = "NUM4";
			keys[Keyboard.NUMPAD_5] = "NUM5";
			keys[Keyboard.NUMPAD_6] = "NUM6";
			keys[Keyboard.NUMPAD_7] = "NUM7";
			keys[Keyboard.NUMPAD_8] = "NUM8";
			keys[Keyboard.NUMPAD_9] = "NUM9";
			keys[Keyboard.NUMPAD_ADD] = "NUM_ADD";
			keys[Keyboard.NUMPAD_DECIMAL] = "NUM_PERIOD";
			keys[Keyboard.NUMPAD_DIVIDE] = "NUM_DIV";
			keys[Keyboard.NUMPAD_ENTER] = "NUM_ENTER";
			keys[Keyboard.NUMPAD_MULTIPLY] = "NUM_MULT";
			keys[Keyboard.NUMPAD_SUBTRACT] = "NUM_SUB";

		}
	}
}
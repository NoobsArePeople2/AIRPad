/**
 * Wrapper for AIRControl
 *
 * @author		Sean Monahan hello@seanmonahan.org
 * @created     2013-12-06
 * @version		1.0.0
 */
package airpad
{
    //==============================
    // Imports
    //==============================

    import com.alexomara.ane.AIRControl.controllers.AIRControlController;
    import com.alexomara.ane.AIRControl.controllers.elements.AIRControlControllerPOV;
    
    import flash.utils.Dictionary;

    /**
     * A gamepad.
     */
    public class AIRPad implements IAIRPadDevice
    {
        //==============================
        // Constants
        //==============================

		/**
		 * Normalized minimum allowed value for an analog stick.
		 */
		private static const STICK_MIN:Number = -1.0;

		/**
		 * Normalized maximum allowed value for an analog stick.
		 */
		private static const STICK_MAX:Number = 1.0;

		/**
		 * Normalized range of stick values.
		 */
		private static const STICK_RANGE:Number = STICK_MAX - STICK_MIN;

		/**
		 * Normalized minimum allowed value for a trigger.
		 */
		private static const TRIGGER_MIN:Number = 0.0;

		/**
		 * Normalized maximum allowed value for a trigger.
		 */
		private static const TRIGGER_MAX:Number = 1.0;

		/**
		 * Normalized range of trigger values.
		 */
		private static const TRIGGER_RANGE:Number = TRIGGER_MAX - TRIGGER_MIN;

		/**
		 * Compute dead zones axial.
		 */
		public static const DEAD_ZONE_AXIAL:String = "deadZoneAxial";

		/**
		 * Compute dead zones radially.
		 */
		public static const DEAD_ZONE_RADIAL:String = "deadZoneRadial";

//		/**
//		 * Compute dead zones radially and scale values.
//		 */
//		public static const DEAD_ZONE_RADIAL_SCALED:String = "deadZoneRadialScaled";

        //==============================
        // Vars
        //==============================

        private var btns:Dictionary;

		private var btnMappings:Dictionary;
		private var axisMappings:Dictionary;
		private var povMappings:Dictionary;
		private var btnActionMapping:Dictionary;
		private var _notes:Dictionary;

		private var bindings:Dictionary;

        public var leftStick:AIRPadStick;
        public var rightStick:AIRPadStick;

        public var leftTrigger:Number;
        public var rightTrigger:Number;

        private var _deadZone:Number = 0.1;

		/**
		 * When an analog value is greater than this
		 * it will register as a button press.
		 */
		public var analogButtonDeadZone:Number = 0.25;

		private var _name:String;
		private var _friendlyName:String;
		private var _id:uint;
		private var _index:uint;

		/**
		 * Combination of vendor and product IDs.
		 */
		private var _deviceID:String;

		private var _controller:AIRControlController;

		/**
		 * Function used to normalize analog stick values.
		 * Some pads report values from 0-1, others 0-100, others -100,100,
		 * this function puts everything in a 0-1 range.
		 *
		 * Signature: stickNormalizer(valueToNormalize:Number):Number;
		 */
		private var stickNormalizer:Function;

		/**
		 * Un-normalized stick minimum for this pad.
		 */
		private var stickMin:Number;

		/**
		 * Un-normalized stick maximum for this pad.
		 */
		private var stickMax:Number;

		/**
		 * Un-normalized stick range for this pad.
		 */
		private var stickRange:Number;

		/**
		 * Whether stick values should be normalized.
		 */
		private var shouldNormalizeStick:Boolean = false;

		/**
		 * Function used to normalize analog trigger values.
		 * Some pads report values from 0-1, others 0-100, others -100,100,
		 * this function puts everything in a 0-1 range.
		 *
		 * Signature: triggerNormalizer(valueToNormalize:Number):Number;
		 */
		private var triggerNormalizer:Function;

		/**
		 * Default trigger value when a controller is initialized.
		 * Note this may not be <code>triggerMin</code>. For example, using a 360 pad
		 * on Mac (with Tattiebogle driver) the default trigger value is <code>0</code>
		 * despite the fact that the minimum trigger value is <code>-1</code>. This throws
		 * off our normalization so we need to be able to account for it.
		 */
		private var triggerDefault:Number;

		/**
		 * Un-normalized trigger minimum for this pad.
		 */
		private var triggerMin:Number;

		/**
		 * Un-normalized trigger maximum for this pad.
		 */
		private var triggerMax:Number;

		/**
		 * Un-normalized trigger range for this pad.
		 */
		private var triggerRange:Number;

		/**
		 * Helpers for trigger normalization.
		 */
		private var leftTriggerHasBeenPressed:Boolean = false;
		private var rightTriggerHasBeenPressed:Boolean = false;

		/**
		 * Whether trigger values should be normalized.
		 */
		private var shouldNormalizeTrigger:Boolean = false;

		/**
		 * Dead zone mode to use.
		 */
		private var _deadZoneMode:String;
		private var calculateDeadZones:Function;

        //==============================
        // Properties
        //==============================

		/**
		 * Computer friendly name for the pad.
		 * Eliminates spaces and other characters from the pad name,
		 * use this when saving config files or referencing the pad
		 * by name in code.
		 */
		public function get name():String
		{
			return _name;
		}

		/**
		 * Human friendly name for the pad.
		 */
		public function get friendlyName():String
		{
			return _friendlyName;
		}

		/**
		 * ID assigned by AIRControl.
		 */
		public function get id():uint
		{
			return _id;
		}

		/**
		 * Index used by AIRPad.
		 */
		public function get index():uint
		{
			return _index;
		}

		/**
		 * ID of the product manufacturer.
		 */
		public function get vendorID():uint
		{
			return _controller.vendorID;
		}

		/**
		 * ID of the product.
		 */
		public function get productID():uint
		{
			return _controller.productID;
		}

		public function get deviceID():String
		{
			return _deviceID;
		}

		/**
		 * Set the dead zone for the sticks.
		 */
		public function get deadZone():Number
		{
			return _deadZone;
		}

		/**
		 * @private
		 */
		public function set deadZone(value:Number):void
		{
			_deadZone = value;
			leftStick.deadZone = value;
			rightStick.deadZone = value;
		}

		/**
		 * The dead zone mode being used.
		 */
		public function get deadZoneMode():String
		{
			return _deadZoneMode;
		}

		/**
		 * @private
		 */
		public function set deadZoneMode(value:String):void
		{
			switch (value)
			{
				case AIRPad.DEAD_ZONE_AXIAL:
					_deadZoneMode = AIRPad.DEAD_ZONE_AXIAL;
					calculateDeadZones = calculateDeadZonesAxial;
					break;

//				case AIRPad.DEAD_ZONE_RADIAL_SCALED:
//					_deadZoneMode = AIRPad.DEAD_ZONE_RADIAL_SCALED;
//					calculateDeadZones = calculateDeadZonesRadialScaled;
//					break;

				case AIRPad.DEAD_ZONE_RADIAL:
				default:
					_deadZoneMode = AIRPad.DEAD_ZONE_RADIAL;
					calculateDeadZones = calculateDeadZonesRadial;
					break;
			}
		}

		/**
		 * Notes about pad-specific settings/issues with a button or axis.
		 */
		public function get notes():Dictionary
		{
			return _notes;
		}

        //==============================
        // Constructor
        //==============================

		/**
		 * Constructor.
		 */
        public function AIRPad(controller:AIRControlController, index:uint, mapping:String = '', deadZoneMode:String = 'deadZoneRadial')
        {
			_controller = controller;
			_friendlyName = controller.name;
			_name = controller.name.replace('(', '-').replace(')', '-').replace(/\s/g, '-');
			_name = _name.replace('--', '-');
			if (_name.lastIndexOf('-') == _name.length - 1)
			{
				_name = _name.substring(0, _name.length - 1);
			}
			_name = _name.toLowerCase();

			if (mapping == '')
			{
				mapping = _name;
			}

			_id = controller.ID;
			_index = index;

			_deviceID = controller.vendorID + "-" + controller.productID;

			this.deadZoneMode = deadZoneMode;

            btns = new Dictionary();
            leftStick = new AIRPadStick();
            rightStick = new AIRPadStick();
			leftTrigger = 0;
			rightTrigger = 0;

			btnMappings = new Dictionary();
			axisMappings = new Dictionary();
			povMappings = new Dictionary();
			btnActionMapping = new Dictionary();
			_notes = new Dictionary();

			bindings = new Dictionary();

			mapController(getFullMappingName(mapping));
        }

        //==============================
        // Public Methods
        //==============================

		/**
		 * Update gamepad state.
		 */
		public function update():void
		{
			var i:uint;
			var key:String;
			var cmd:String;

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

			for (i = 0; i < _controller.buttonsTotal; ++i)
			{
				key = btnMappings[i];
				if (!key) continue;

				cmd = bindings[key];
				if (_controller.button(i).down)
				{
					setButtonDown(key);
					if (cmd) setButtonDown(cmd);
				}
				else
				{
					clearButtonDown(key);
					if (cmd) clearButtonDown(cmd);
				}
			}

			for (i = 0; i < _controller.povsTotal; ++i)
			{
				var pov:AIRControlControllerPOV = _controller.pov(i);
				var x:String = "X" + pov.X;
				var y:String = "Y" + pov.Y;

				key = povMappings[x];
				cmd = bindings[key];
				if (key)
				{
					setButtonDown(key);
					if (cmd) setButtonDown(cmd);
				}
				else
				{
					if (isButtonDown(AIRPadButton.DPAD_LEFT))
					{
						clearButtonDown(AIRPadButton.DPAD_LEFT);
						cmd = bindings[AIRPadButton.DPAD_LEFT]
						if (cmd) clearButtonDown(cmd);
					}
					else if (isButtonDown(AIRPadButton.DPAD_RIGHT))
					{
						clearButtonDown(AIRPadButton.DPAD_RIGHT);
						cmd = bindings[AIRPadButton.DPAD_RIGHT]
						if (cmd) clearButtonDown(cmd);	
					}
				}

				key = povMappings[y];
				cmd = bindings[key];
				if (key)
				{
					setButtonDown(key);
					if (cmd) setButtonDown(cmd);
				}
				else
				{
					if (isButtonDown(AIRPadButton.DPAD_UP))
					{
						clearButtonDown(AIRPadButton.DPAD_UP);
						cmd = bindings[AIRPadButton.DPAD_UP]
						if (cmd) clearButtonDown(cmd);
					}
					else if (isButtonDown(AIRPadButton.DPAD_DOWN))
					{
						clearButtonDown(AIRPadButton.DPAD_DOWN);
						cmd = bindings[AIRPadButton.DPAD_DOWN]
						if (cmd) clearButtonDown(cmd);
					}
									}
			}

			for (i = 0; i < _controller.axesTotal; ++i)
			{
				key = axisMappings[i];
				if (!key) continue;

				var triggerValue:Number;
				if (key == AIRPadButton.LEFT_STICK_X)
				{
					leftStick.x = stickNormalizer(_controller.axis(i).position);
				}
				else if (key == AIRPadButton.LEFT_STICK_Y)
				{
					leftStick.y = stickNormalizer(_controller.axis(i).position);
				}
				else if (key == AIRPadButton.RIGHT_STICK_X)
				{
					rightStick.x = stickNormalizer(_controller.axis(i).position);
				}
				else if (key == AIRPadButton.RIGHT_STICK_Y)
				{
					rightStick.y = stickNormalizer(_controller.axis(i).position);
				}
				else if (key == AIRPadButton.L2)
				{
					triggerValue = _controller.axis(i).position;
					if (!leftTriggerHasBeenPressed && triggerValue != 0.0)
					{
						leftTriggerHasBeenPressed = true;
					}

					if (!leftTriggerHasBeenPressed)
					{
						leftTrigger = 0.0;
					}
					else
					{
						leftTrigger = triggerNormalizer(triggerValue);
					}
				}
				else if (key == AIRPadButton.R2)
				{
					triggerValue = _controller.axis(i).position;
					if (!rightTriggerHasBeenPressed && triggerValue != 0.0)
					{
						rightTriggerHasBeenPressed = true;
					}

					if (!rightTriggerHasBeenPressed)
					{
						rightTrigger = 0.0;
					}
					else
					{
						rightTrigger = triggerNormalizer(triggerValue);
					}
				}
			}
			calculateDeadZones();
			setAnalogButtons();
		}

		/**
		 * Tests if the specified button is down.
		 *
		 * @param string btn Button to test.
		 * @return <code>true</code> is down, <code>false</code> is not.
		 */
        public function isButtonDown(btn:String):Boolean
        {
            if (!btns[btn])
            {
                return false;
            }

            return btns[btn] > 0;
        }

		/**
		 * Tests if the button was just pressed.
		 *
		 * @param string btn Button to test.
		 * @return <code>true</code> if button was just pressed, <code>false</code> if not.
		 */
        public function wasButtonJustPressed(btn:String):Boolean
        {
            if (!btns[btn])
            {
                return false;
            }

            return btns[btn] == AIRPadButton.BUTTON_JUST_PRESSED;
        }

        /**
         * Whether this key was just released.
         * That is, was this key down on the last update tick
         * but now up?
         *
         * @param key The key.
         * @return True or false.
         */
        public function wasButtonJustReleased(btn:String):Boolean
        {
            if (!btns[btn])
            {
                return false;
            }

            return btns[btn] == AIRPadButton.BUTTON_JUST_RELEASED;
        }

        /**
         * Sets the specified key as down.
         *
         * @param btn The button to set down.
         */
        public function setButtonDown(btn:String):void
        {
            if (btns[btn] && btns[btn] > 0)
            {
                btns[btn] = AIRPadButton.BUTTON_HELD;
            }
            else
            {
                btns[btn] = AIRPadButton.BUTTON_JUST_PRESSED;
            }
        }

        /**
         * Sets the specified key as "just released".
         *
         * @param btn The button to clear.
         */
        public function clearButtonDown(btn:String):void
        {
            btns[btn] = AIRPadButton.BUTTON_JUST_RELEASED;
        }

		/**
		 * Gets an analog stick by name.
		 *
		 * @param string stick Either <code>AIRPadButton.LEFT_STICK</code> or <code>AIRPadButton.RIGHT_STICK</code>.
		 * @return The <code>AIRPadStick</code>. Returns <code>null</code> if the stick could not be found.
		 */
		public function getStick(stick:String):AIRPadStick
		{
			if (stick == AIRPadButton.LEFT_STICK)
			{
				return leftStick;
			}
			else if (stick == AIRPadButton.RIGHT_STICK)
			{
				return rightStick;
			}

			return null;
		}

		/**
		 * Gets a trigger value by name.
		 *
		 * @param string trigger Either <code>AIRPadButton.LEFT_TRIGGER</code> or <code>AIRPadButton.RIGHT_TRIGGER</code>.
		 * @param The value for the <code>trigger</code>. <code>0</code> if the trigger is unknown.
		 */
		public function getTrigger(trigger:String):Number
		{
			if (trigger == AIRPadButton.LEFT_TRIGGER)
			{
				return leftTrigger;
			}
			else if (trigger == AIRPadButton.RIGHT_TRIGGER)
			{
				return rightTrigger;
			}

			return 0;
		}

        /**
         * Clears the entire state for all buttons.
         */
        public function clearState():void
        {
            for (var btn:String in btns)
            {
                btns[btn] = AIRPadButton.BUTTON_UP;
            }
        }

		/**
		 * Binds a command to a button.
		 * Binding commands allows you to interact with a <code>AIRPad</code>
		 * in a way that makes sense for your game. For example, rather than using
		 * <code>pad.isButtonDown(AIRPadButton.FACE_ONE)</code> you could use a binding like
		 * <code>pad.isButtonDown("jump")</code>.
		 *
		 * @param string command Name of the command to bind (e.g., "jump").
		 * @param string btn <code>AIRPadButton</code> to bind to (e.g., <code>AIRPadButton.FACE_ONE</code>).
		 */
		public function bindCommand(command:String, btn:String):void
		{
			bindings[btn] = command;
		}

		/**
		 * Clears all bindings.
		 */
		public function clearBindings():void
		{
			bindings = new Dictionary();
		}

		/**
		 * Sets the normalizer function for analog stick values.
		 *
		 * Signature for stickNormalizer: stickNormalizer(valueToNormalize:Number):Number;
		 */
		public function setStickNormalizer(func:Function):void
		{
			stickNormalizer = func;
		}

		/**
		 * Sets the normalizer function for analog trigger values.
		 *
		 * Signature for triggerNormalizer: triggerNormalizer(valueToNormalize:Number):Number;
		 */
		public function setTriggerNormalizer(func:Function):void
		{
			triggerNormalizer = func;
		}

		/**
		 * Change the mapping.
		 *
		 * Clears out the state and all command bindings.
		 *
		 * @param string mapping Name of the mapping to use.
		 */
		public function setMapping(mapping:String):void
		{
			clearState();
			clearBindings();
			mapController(getFullMappingName(mapping));
		}

        //==============================
        // Private, Protected Methods
        //==============================

		/**
		 * Calculate axial dead zones for left and right sticks.
		 */
		private function calculateDeadZonesAxial():void
		{
			leftStick.deadZoneRadial();
			rightStick.deadZoneRadial();
		}

		/**
		 * Calculate radial dead zones for left and right sticks.
		 */
		private function calculateDeadZonesRadial():void
		{
			leftStick.deadZoneRadial();
			rightStick.deadZoneRadial();
		}

//		/**
//		 * Calculate scaled radial dead zones for left and right sticks.
//		 */
//		private function calculateDeadZonesRadialScaled():void
//		{
//			leftStick.deadZoneRadialScaled();
//			rightStick.deadZoneRadialScaled();
//		}

		/**
		 * Helper function that allows us to also read analog sticks/triggers like digital buttons.
		 *
		 * Any analog axis that has a value outside the dead zone will be treated like a
		 * digital button press.
		 */
		private function setAnalogButtons():void
		{
			var cmd:String;
			// Left stick X
			if (leftStick.x < -analogButtonDeadZone)
			{
				setButtonDown(AIRPadButton.LEFT_STICK_LEFT);
				cmd = bindings[AIRPadButton.LEFT_STICK_LEFT];
				if (cmd) setButtonDown(cmd);

				if (isButtonDown(AIRPadButton.LEFT_STICK_RIGHT))
				{
					clearButtonDown(AIRPadButton.LEFT_STICK_RIGHT);
					cmd = bindings[AIRPadButton.LEFT_STICK_RIGHT];
					if (cmd) clearButtonDown(cmd);
				}
			}
			else if (leftStick.x > analogButtonDeadZone)
			{
				setButtonDown(AIRPadButton.LEFT_STICK_RIGHT);
				cmd = bindings[AIRPadButton.LEFT_STICK_RIGHT];
				if (cmd) setButtonDown(cmd);

				if (isButtonDown(AIRPadButton.LEFT_STICK_LEFT))
				{
					clearButtonDown(AIRPadButton.LEFT_STICK_LEFT);
					cmd = bindings[AIRPadButton.LEFT_STICK_LEFT];
					if (cmd) clearButtonDown(cmd);
				}
			}
			else
			{
				if (isButtonDown(AIRPadButton.LEFT_STICK_RIGHT))
				{
					clearButtonDown(AIRPadButton.LEFT_STICK_RIGHT);
					cmd = bindings[AIRPadButton.LEFT_STICK_RIGHT];
					if (cmd) clearButtonDown(cmd);	
				}
				
				if (isButtonDown(AIRPadButton.LEFT_STICK_LEFT))
				{
					clearButtonDown(AIRPadButton.LEFT_STICK_LEFT);
					cmd = bindings[AIRPadButton.LEFT_STICK_LEFT];
					if (cmd) clearButtonDown(cmd);
				}
			}

			// Left stick Y
			if (leftStick.y < -analogButtonDeadZone)
			{
				setButtonDown(AIRPadButton.LEFT_STICK_UP);
				cmd = bindings[AIRPadButton.LEFT_STICK_UP];
				if (cmd) setButtonDown(cmd);

				if (isButtonDown(AIRPadButton.LEFT_STICK_DOWN))
				{
					clearButtonDown(AIRPadButton.LEFT_STICK_DOWN);
					cmd = bindings[AIRPadButton.LEFT_STICK_DOWN];
					if (cmd) clearButtonDown(cmd);
				}
			}
			else if (leftStick.y > analogButtonDeadZone)
			{
				setButtonDown(AIRPadButton.LEFT_STICK_DOWN);
				cmd = bindings[AIRPadButton.LEFT_STICK_DOWN];
				if (cmd) setButtonDown(cmd);

				if (isButtonDown(AIRPadButton.LEFT_STICK_UP))
				{
					clearButtonDown(AIRPadButton.LEFT_STICK_UP);
					cmd = bindings[AIRPadButton.LEFT_STICK_UP];
					if (cmd) clearButtonDown(cmd);
				}
			}
			else
			{
				if (isButtonDown(AIRPadButton.LEFT_STICK_UP))
				{
					clearButtonDown(AIRPadButton.LEFT_STICK_UP);
					cmd = bindings[AIRPadButton.LEFT_STICK_UP];
					if (cmd) clearButtonDown(cmd);
				}
				
				if (isButtonDown(AIRPadButton.LEFT_STICK_DOWN))
				{
					clearButtonDown(AIRPadButton.LEFT_STICK_DOWN);
					cmd = bindings[AIRPadButton.LEFT_STICK_DOWN];
					if (cmd) clearButtonDown(cmd);
				}
			}

			// Right stick X
			if (rightStick.x < -analogButtonDeadZone)
			{
				setButtonDown(AIRPadButton.RIGHT_STICK_LEFT);
				cmd = bindings[AIRPadButton.RIGHT_STICK_LEFT];
				if (cmd) setButtonDown(cmd);

				if (isButtonDown(AIRPadButton.RIGHT_STICK_RIGHT))
				{
					clearButtonDown(AIRPadButton.RIGHT_STICK_RIGHT);
					cmd = bindings[AIRPadButton.RIGHT_STICK_LEFT];
					if (cmd) clearButtonDown(cmd);
				}
			}
			else if (rightStick.x > analogButtonDeadZone)
			{
				setButtonDown(AIRPadButton.RIGHT_STICK_RIGHT);
				cmd = bindings[AIRPadButton.RIGHT_STICK_RIGHT];
				if (cmd) setButtonDown(cmd);

				if (isButtonDown(AIRPadButton.RIGHT_STICK_LEFT))
				{
					clearButtonDown(AIRPadButton.RIGHT_STICK_LEFT);
					cmd = bindings[AIRPadButton.RIGHT_STICK_LEFT];
					if (cmd) clearButtonDown(cmd);
				}
			}
			else
			{
				if (isButtonDown(AIRPadButton.RIGHT_STICK_RIGHT))
				{
					clearButtonDown(AIRPadButton.RIGHT_STICK_RIGHT);
					cmd = bindings[AIRPadButton.RIGHT_STICK_RIGHT];
					if (cmd) clearButtonDown(cmd);
				}
				
				if (isButtonDown(AIRPadButton.RIGHT_STICK_LEFT))
				{
					clearButtonDown(AIRPadButton.RIGHT_STICK_LEFT);
					cmd = bindings[AIRPadButton.RIGHT_STICK_LEFT];
					if (cmd) clearButtonDown(cmd);
				}
			}

			// Right stick Y
			if (rightStick.y < -analogButtonDeadZone)
			{
				setButtonDown(AIRPadButton.RIGHT_STICK_UP);
				cmd = bindings[AIRPadButton.RIGHT_STICK_UP];
				if (cmd) setButtonDown(cmd);

				if (isButtonDown(AIRPadButton.RIGHT_STICK_DOWN))
				{
					clearButtonDown(AIRPadButton.RIGHT_STICK_DOWN);
					cmd = bindings[AIRPadButton.RIGHT_STICK_DOWN];
					if (cmd) clearButtonDown(cmd);
				}
			}
			else if (rightStick.y > analogButtonDeadZone)
			{
				setButtonDown(AIRPadButton.RIGHT_STICK_DOWN);
				cmd = bindings[AIRPadButton.RIGHT_STICK_DOWN];
				if (cmd) setButtonDown(cmd);

				if (isButtonDown(AIRPadButton.RIGHT_STICK_UP))
				{
					clearButtonDown(AIRPadButton.RIGHT_STICK_UP);
					cmd = bindings[AIRPadButton.RIGHT_STICK_UP];
					if (cmd) clearButtonDown(cmd);
				}
			}
			else
			{
				if (isButtonDown(AIRPadButton.RIGHT_STICK_UP))
				{
					clearButtonDown(AIRPadButton.RIGHT_STICK_UP);
					cmd = bindings[AIRPadButton.RIGHT_STICK_UP];
					if (cmd) clearButtonDown(cmd);
				}
				
				if (isButtonDown(AIRPadButton.RIGHT_STICK_DOWN))
				{
					clearButtonDown(AIRPadButton.RIGHT_STICK_DOWN);
					cmd = bindings[AIRPadButton.RIGHT_STICK_DOWN];
					if (cmd) clearButtonDown(cmd);
				}
			}

			// Left trigger
			if (leftTrigger > analogButtonDeadZone)
			{
				setButtonDown(AIRPadButton.L2);

				cmd = bindings[AIRPadButton.L2];
				if (cmd) setButtonDown(cmd);
			}
			else
			{
				if (isButtonDown(AIRPadButton.L2))
				{
					clearButtonDown(AIRPadButton.L2);
					cmd = bindings[AIRPadButton.L2];
					if (cmd) clearButtonDown(cmd);
				}
			}

			// Right trigger
			if (rightTrigger > analogButtonDeadZone)
			{
				setButtonDown(AIRPadButton.R2);

				cmd = bindings[AIRPadButton.R2];
				if (cmd) setButtonDown(cmd);
			}
			else
			{
				if (isButtonDown(AIRPadButton.R2))
				{
					clearButtonDown(AIRPadButton.R2);
					cmd = bindings[AIRPadButton.R2];
					if (cmd) clearButtonDown(cmd);
				}
			}
		}

		/**
		 * Default normalizer function for sticks.
		 */
		private function defaultStickNormalizer(value:Number):Number
		{
			if (!shouldNormalizeStick)
			{
				return value;
			}

			return (((value - stickMin) * STICK_RANGE) / stickRange) + STICK_MIN;
		}

		/**
		 * Default normalizer function for triggers.
		 */
		private function defaultTriggerNormalizer(value:Number):Number
		{
			if (!shouldNormalizeTrigger)
			{
				return (value < 0) ? -value : value;
			}

			var val:Number = (((value - triggerMin) * TRIGGER_RANGE) / triggerRange) + TRIGGER_MIN;
			return (val < 0) ? -val : val;
		}

		/**
		 * From a base mapping name returns a normalized name.
		 */
		private function getFullMappingName(mapping:String):String
		{
			return AIRPadHelper.platform() + "-" + mapping.toLowerCase().replace(' ', '-');
		}

		/**
		 * Maps raw controller buttons, axes and POVs to normalized
		 * <code>Gamepad</code> values.
		 *
		 * @param string mapping Name of the mapping to load.
		 */
		private function mapController(mapping:String):void
		{
			var config:Object = AIRPadHelper.loadMapping(mapping);
			if (!config)
			{
				return;
			}

			var data:Object;
			for (var btn:String in config.buttons)
			{
				if (!btn) continue;
				data = config.buttons[btn];
				if (!data) continue;

				btnMappings[data.index] = btn;
				if (data._note)
				{
					_notes[btn] = data._note;
				}
			}

			for (var axis:String in config.axes)
			{
				if (!axis) continue;
				data = config.axes[axis];
				if (!data) continue;

				axisMappings[data.index] = axis;
				if (data._note)
				{
					_notes[axis] = data._note;
				}
			}

			for (var pov:String in config.pov)
			{
				if (!pov) continue;
				data = config.pov[pov];
				if (!data) continue;

				povMappings[data.element] = pov;
				if (data._note)
				{
					_notes[pov] = data._note;
				}
			}

			if (config.deadZone)
			{
				deadZone = config.deadZone as Number;
			}

			if (config.analogButtonDeadZone)
			{
				analogButtonDeadZone = config.analogButtonDeadZone as Number;
			}

			if (config.stickMin != null && config.stickMax != null)
			{
				stickMin = config.stickMin as Number;
				stickMax = config.stickMax as Number;
				stickRange = stickMax - stickMin;

				if (stickMin != STICK_MIN || stickMax != STICK_MAX)
				{
					shouldNormalizeStick = true;
				}
			}

			if (config.triggerMin != null && config.triggerMax != null)
			{
				triggerMin = config.triggerMin as Number;
				triggerMax = config.triggerMax as Number;
				triggerRange = triggerMax - triggerMin;

				if (triggerMin != TRIGGER_MIN || triggerMax != TRIGGER_MAX)
				{
					shouldNormalizeTrigger = true;
				}
			}

			if (config.triggerDefault != null)
			{
				triggerDefault = config.triggerDefault as Number;
			}

			stickNormalizer = defaultStickNormalizer;
			triggerNormalizer = defaultTriggerNormalizer;

		}
    }
}
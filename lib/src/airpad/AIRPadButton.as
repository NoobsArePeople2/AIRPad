/**
 *
 * @author		Sean Monahan sean@seanmonahan.org
 * @created		2013-12-06
 * @version		1.0.0
 */
package airpad
{
    /**
     * Enumeration of AIRPad buttons.
     */
    public class AIRPadButton
    {
		/**
		 * First face button.
		 * 
		 * Corresponds with A on an Xbox 360 pad, X on a Dual Shock 3.
		 */
		public static const FACE_ONE:String   = "faceOne";
		
		/**
		 * Second face button.
		 * 
		 * Corresponds with B on an Xbox 360 pad, O on a Dual Shock 3.
		 */
		public static const FACE_TWO:String   = "faceTwo";
		
		/**
		 * Third face button.
		 * 
		 * Corresponds with X on an Xbox 360 pad, SQUARE on a Dual Shock 3.
		 */
		public static const FACE_THREE:String = "faceThree";
		
		/**
		 * Fourth face button.
		 * 
		 * Corresponds with Y on an Xbox 360 pad, TRIANGLE on a Dual Shock 3.
		 */
		public static const FACE_FOUR:String  = "faceFour";
		
		/**
		 * First left shoulder button.
		 * 
		 * Corresponds with Left Bumper on Xbox 360 pad, L1 on a Dual Shock 3.
		 */
		public static const L1:String = "l1";
		
		/**
		 * Second left shoulder button.
		 * On pads where the second shoulder button is actually an analog trigger
		 * accessing it this way treats it as a button -- it's either on or off.
		 * 
		 * Corresponds with Left Trigger on Xbox 360 pad, L2 on a Dual Shock 3.
		 */
		public static const L2:String = "l2";
		
		/**
		 * Second left shoudler button as analog.
		 * 
		 * Corresponds with Left Trigger on Xbox 360 pad, L2 on a Dual Shock 3.
		 */
		public static const LEFT_TRIGGER:String = "leftTrigger";
		
		/**
		 * Pressing left stick in.
		 * 
		 * Correspond with Left Stick press on Xbox 360 pad and Dual Shock 3.
		 */
		public static const L3:String = "l3";
		
		/**
		 * First right shoulder button.
		 * 
		 * Corresponds with Right Bumper on Xbox 360 pad, R1 on a Dual Shock 3.
		 */
		public static const R1:String = "r1";
		
		/**
		 * Second right shoulder button.
		 * On pads where the second shoulder button is actually an analog trigger
		 * accessing it this way treats it as a button -- it's either on or off.
		 * 
		 * Corresponds with Right Trigger on Xbox 360 pad, R2 on a Dual Shock 3.
		 */
		public static const R2:String = "r2";
		
		/**
		 * Second right shoudler button as analog.
		 * 
		 * Corresponds with Right Trigger on Xbox 360 pad, R2 on a Dual Shock 3.
		 */
		public static const RIGHT_TRIGGER:String = "rightTrigger";
		
		/**
		 * Pressing right stick in.
		 * 
		 * Correspond with Right Stick press on Xbox 360 pad and Dual Shock 3.
		 */
		public static const R3:String = "r3";
		
		/**
		 * Up on the dpad.
		 */
		public static const DPAD_UP:String    = "dpadUp";
		
		/**
		 * Right on the dpad.
		 */
		public static const DPAD_RIGHT:String = "dpadRight";
		
		/**
		 * Down on the dpad.
		 */
		public static const DPAD_DOWN:String  = "dpadDown";
		
		/**
		 * Left on the dpad.
		 */
		public static const DPAD_LEFT:String  = "dpadLeft";
		
		/**
		 * Start button.
		 */
		public static const START:String  = "start";
		
		/**
		 * Select button.
		 * 
		 * Corresponds with Back on the Xbox 360 pad and Select on Dual Shock 3.
		 */
		public static const SELECT:String = "select";
		
		/**
		 * System button.
		 * 
		 * Corresponds with Guide (Xbox) button on Xbox 360 pad and PS button on Dual Shock 3.
		 */
		public static const SYSTEM:String = "system";
		
		/**
		 * X value for the left stick.
		 */
		public static const LEFT_STICK_X:String = "leftStickX";
		
		/**
		 * Y value for the left stick.
		 */
		public static const LEFT_STICK_Y:String = "leftStickY";
		
		/**
		 * X value for the right stick.
		 */
		public static const RIGHT_STICK_X:String = "rightStickX";
		
		/**
		 * Y value for the right stick.
		 */
		public static const RIGHT_STICK_Y:String = "rightStickY";
		
		/**
		 * Left stick up.
		 * 
		 * Treats the analog stick like a dpad.
		 */
		public static const LEFT_STICK_UP:String    = "leftStickUp";
		
		/**
		 * Left stick right.
		 * 
		 * Treats the analog stick like a dpad.
		 */
		public static const LEFT_STICK_RIGHT:String = "leftStickRight";
		
		/**
		 * Left stick down.
		 * 
		 * Treats the analog stick like a dpad.
		 */
		public static const LEFT_STICK_DOWN:String  = "leftStickDown";
		
		/**
		 * Left stick left.
		 * 
		 * Treats the analog stick like a dpad.
		 */
		public static const LEFT_STICK_LEFT:String  = "leftStickLeft";
		
		/**
		 * Right stick up.
		 * 
		 * Treats the analog stick like a dpad.
		 */
		public static const RIGHT_STICK_UP:String    = "rightStickUp";
		
		/**
		 * Right stick right.
		 * 
		 * Treats the analog stick like a dpad.
		 */
		public static const RIGHT_STICK_RIGHT:String = "rightStickRight";
		
		/**
		 * Right stick down.
		 * 
		 * Treats the analog stick like a dpad.
		 */
		public static const RIGHT_STICK_DOWN:String  = "rightStickDown";
		
		/**
		 * Right stick left.
		 * 
		 * Treats the analog stick like a dpad.
		 */
		public static const RIGHT_STICK_LEFT:String  = "rightStickLeft";
		
		/**
		 * The left stick.
		 */
		public static const LEFT_STICK:String = "leftStick";
		
		/**
		 * The right stick.
		 */
		public static const RIGHT_STICK:String = "rightStick";
		
		/**
		 * Button states.
		 */
		public static const BUTTON_JUST_RELEASED:int = -1;
		public static const BUTTON_UP:int = 0;
		public static const BUTTON_HELD:int = 1;
		public static const BUTTON_JUST_PRESSED:int = 2;
    }
}
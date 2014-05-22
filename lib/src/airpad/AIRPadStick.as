/**
 *
 * @author		Sean Monahan hello@seanmonahan.org
 * @created		2013-12-06
 * @version		1.0.0
 */
package airpad
{
	//==============================
	// Imports
	//==============================

	/**
	 * An analog stick for a gamepad.
	 */
	public class AIRPadStick
	{
		//==============================
		// Vars
		//==============================

		/**
		 * Current value on the horizontal axis of the stick.
		 * Negative is left along the axis, positive is right.
		 */
		private var _x:Number;

		/**
		 * Current value on the vertical axis of the stick.
		 * Negative is up, positive is down.
		 */
		private var _y:Number;

		/**
		 * Dead zone for the stick.
		 */
		public var deadZone:Number;

		private var _dirty:Boolean;

		private var _magnitude:Number;

		//==============================
		// Properties
		//==============================

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
			_dirty = true;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
			_dirty = true;
		}

		//==============================
		// Constructor
		//==============================

		/**
		 * Constructor.
		 */
		public function AIRPadStick()
		{
			_dirty = true;
			x = 0;
			y = 0;
			deadZone = 0.1;
		}

		//==============================
		// Public Methods
		//==============================

		public function magnitude():Number
		{
			if (_dirty || isNaN(_magnitude))
			{
				_magnitude = Math.sqrt((_x * _x) + (_y * _y));
				_dirty = false;
			}

			return _magnitude;
		}

		public function normalized():AIRPadStick
		{
			var copy:AIRPadStick = new AIRPadStick();
			copy.x = x / magnitude();
			copy.y = y / magnitude();

			return copy;
		}

		/**
		 * Calculate dead zone axially.
		 */
		public function deadZoneAxial():void
		{
			var val:Number;
			val = (x < 0) ? -x : x;
			if (val < deadZone) x = 0.0;

			val = (y < 0) ? -y : y;
			if (val < deadZone) y = 0.0;
		}

		/**
		 * Calculate dead zone radially.
		 */
		public function deadZoneRadial():void
		{
			var mag:Number = magnitude();
			if (mag < deadZone)
			{
				x = 0.0;
				y = 0.0;
			}
		}

		/**
		 * Calculate dead zone radially, then scale it.
		 */
//		public function deadZoneRadialScaled():void
//		{
//			var mag:Number = magnitude();
//			if (mag < deadZone)
//			{
//				x = 0.0;
//				y = 0.0;
//			}
//			else
//			{
//				// http://www.third-helix.com/2013/04/doing-thumbstick-dead-zones-right/
//				// https://gist.github.com/stfx/5372176
//				trace("PRE x,y ", x, y);
//				var normalized:AIRPadStick = normalized();
////				x = normalized.x * ((normalized.x - deadZone) / ((1.0 - deadZone) * normalized.x));
////				y = normalized.y * ((normalized.y - deadZone) / ((1.0 - deadZone) * normalized.y));
////				var sx:Number = ((mag - deadZone) / ((1.0 - deadZone) * mag));
////				var sy:Number = ((mag - deadZone) / ((1.0 - deadZone) * mag));
////				x = x * ((mag - deadZone) / ((1.0 - deadZone) * mag));
////				y = y * ((mag - deadZone) / ((1.0 - deadZone) * mag));
////				trace("sx,sy ", sx, sy);
//				if (isNaN(x) || isNaN(y))
//				{
//					trace("wtf");
//				}
//				trace("x,y ", x, y);
//			}
//		}

		/**
		 * Reset the stick to its default state.
		 */
		public function reset():void
		{
			x = 0.0;
			y = 0.0;
		}

		/**
		 * String representation of the stick.
		 */
		public function toString():String
		{
			return "x: " + x + ", y: " + y;
		}
	}
}
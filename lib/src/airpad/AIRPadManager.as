/**
 * Manages AIRPads.
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

	import com.alexomara.ane.AIRControl.AIRControl;
	import com.alexomara.ane.AIRControl.controllers.AIRControlController;
	import com.alexomara.ane.AIRControl.events.AIRControlEvent;

	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;

	/**
	 * Manages AIRPads
	 */
	public class AIRPadManager extends EventDispatcher
	{
		//==============================
		// Constants
		//==============================

		/**
		 * Maximum number of pads allowed to connect.
		 */
		public const MAX_PADS:uint = 4;

		/**
		 * Constant indicating we should not add a pad.
		 */
		private const DO_NOT_ADD:uint = MAX_PADS + 1;

		//==============================
		// Vars
		//==============================

		/**
		 * List of connected <code>AIRPad</code>s.
		 */
		private var pads:Vector.<IAIRPadDevice>;

		/**
		 * Corresponding <code>deviceID</code>s for <code>AIRPad</code>s
		 */
		private var padDeviceIds:Vector.<String>;
		private var _numConnectedPads:uint;
		private var _numPhysicalPads:uint = 0;

		/**
		 * Flash Stage.
		 * Used to keyboard events.
		 */
		private var _stage:Stage;

		private var kbConnected:Vector.<Boolean>;
		private var numConnectedKeyboards:uint = 0;

		//==============================
		// Properties
		//==============================

		/**
		 * Number of pads currently connected to the system.
		 */
		public function get numConnectedPads():uint
		{
			return _numConnectedPads;
		}

		/**
		 * Number of physical pads (e.g., a 360 pad, not an <code>AIRKeyboard</code>.) connected to the system.
		 */
		public function get numPhysicalPads():uint
		{
			return _numPhysicalPads;
		}

		//==============================
		// Constructor
		//==============================

		/**
		 * Constructor.
		 */
		public function AIRPadManager()
		{
			_numConnectedPads = 0;
			pads = new Vector.<IAIRPadDevice>(MAX_PADS);
			padDeviceIds = new Vector.<String>(MAX_PADS);

			kbConnected = new Vector.<Boolean>(2);
			kbConnected[0] = false;
			kbConnected[1] = false;

			AIRControl.addEventListener(AIRControlEvent.CONTROLLER_ATTACH, onControllerAttach);
			AIRControl.addEventListener(AIRControlEvent.CONTROLLER_DETACH, onControllerDettach);
		}

		//==============================
		// Public Methods
		//==============================

		/**
		 * Updates the states of all connected pads.
		 */
		public function update():void
		{
			AIRControl.update();

			var controller:AIRControlController;
			if (AIRControl.controllersTotal < 1 && numConnectedKeyboards < 1) return;

			for each (var pad:IAIRPadDevice in pads)
			{
				if (pad)
				{
					pad.update();
				}
			}
		}

		/**
		 * Returns the pads at the specified index.
		 *
		 * @param uint index Index of the <code>AIRPad</code> you are interested in.
		 * @return <code>IAIRPadDevice</code> at <code>index</code>. Note: return value may be <code>null</code>.
		 */
		public function getPad(index:uint):IAIRPadDevice
		{
			return pads[index];
		}

		/**
		 * Initialize the keyboard system.
		 *
		 * @param Stage stage The Flash stage.
		 */
		public function initKeyboard(stage:Stage):void
		{
			_stage = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		/**
		 * De-initialize the keyboard system.
		 */
		public function deinitKeyboard():void
		{
			if (_stage)
			{
				_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				_stage = null;
			}
		}

		/**
		 * Releases resources.
		 * Call this when you no longer need an instance of this class.
		 */
		public function dispose():void
		{
			AIRControl.removeEventListener(AIRControlEvent.CONTROLLER_ATTACH, onControllerAttach);
			AIRControl.removeEventListener(AIRControlEvent.CONTROLLER_DETACH, onControllerDettach);

			if (_stage)
			{
				_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				_stage = null;
			}
		}

		/**
		 * Check if the keyboard at the specified index is connected.
		 *
		 * @param uint index Index to test.
		 * @return Boolean <code>true</code> if the keyboard is connected.
		 */
		public function isKeyboardConnected(index:uint):Boolean
		{
			if (index >= kbConnected.length || !_stage) return false;
			return kbConnected[index];
		}

		/**
		 * Connect a keyboard.
		 *
		 * @param uint index Index of the keyboard. This has nothing to do with the pad index.
		 * @return Boolean <code>true</code> if the keyboard is successfully connected.
		 */
		public function connectKeyboard(index:uint):Boolean
		{
			if (index >= kbConnected.length || !_stage) return false;

			if (!kbConnected[index])
			{
				if (AIRPadHelper.debug) trace("[AIRPadManager] connect keyboard " + index);
				return addKeyboard(index);
			}

			return false;
		}

		/**
		 * Disconnect a keyboard.
		 *
		 * @param uint index Index of the keyboard. This has nothing to do with the pad index.
		 * @return Boolean <code>true</code> if the keyboard is successfully disconnected.
		 */
		public function disconnectKeyboard(index:uint):Boolean
		{
			if (index >= kbConnected.length || !_stage) return false;

			if (kbConnected[index])
			{
				if (AIRPadHelper.debug) trace("[AIRPadManager] disconnect keyboard " + index);
				return removeKeyboard(index);
			}

			return false;
		}

		//==============================
		// Private, Protected Methods
		//==============================

		/**
		 * Gets the index of the device.
		 * Index is the index of <code>pads</code> used by AIRPad.
		 *
		 * @param string deviceID The unique device ID of the connected device.
		 * @return uint The index.
		 */
		private function getIndex(deviceID:String):uint
		{
			var prevIndex:int = padDeviceIds.indexOf(deviceID);
			var i:uint;

			// Never heard of this pad before.
			// Find the first available slot for it.
			if (prevIndex < 0)
			{
				// First look for a slot that has not previously been used.
				// This prevents race conditions. For example, say one slot
				// is completely free (never had anything connected to it)
				// and another is open after a pad disconnected due to low battery.
				// Before the battery pad can re-connect another pad connects.
				// In this case AIRPadManager will strive to hold that previously
				// used spot for the disconnected pad and give the new pad the
				// completely free spot.
				var firstEmptySlot:int = padDeviceIds.indexOf(null);
				if (firstEmptySlot > -1 && pads[firstEmptySlot] == null)
				{
					return firstEmptySlot;
				}

				for (i = 0; i < MAX_PADS; ++i)
				{
					if (pads[i] == null)
					{
						if (AIRPadHelper.debug) trace("[AIRPadManager] never heard of it, adding at '" + i + "'");
						return i;
					}
				}
			}

			// We've heard of this pad before.
			// Check if there is a free slot that
			// lines up with deviceID.
			// Odds are this pad was disconnected
			// then reconnected (e.g., someone tripped
			// over a cord, batteries ran dry in a
			// wireless pad).
			for (i = 0; i < MAX_PADS; ++i)
			{
				if (padDeviceIds[i] == deviceID && pads[i] == null)
				{
					if (AIRPadHelper.debug) trace("[AIRPadManager] re-adding pad at '" + i + "'");
					return i;
				}
			}

			return DO_NOT_ADD;
		}

		/**
		 * Adds an AIRKeyboard.
		 *
		 * @param uint index Index of the keyboard.
		 */
		private function addKeyboard(index:uint):Boolean
		{
			var kb:AIRKeyboard = new AIRKeyboard(index);
			var kbIndex:uint = getIndex(kb.deviceID);
			if (kbIndex == DO_NOT_ADD)
			{
				if (AIRPadHelper.debug) trace("[AIRPadManager] not adding keyboard '" + index + "'.");
				return false;
			}
			pads[kbIndex] = kb;
			padDeviceIds[kbIndex] = kb.deviceID;
			_numConnectedPads++;
			numConnectedKeyboards++;

			kbConnected[index] = true;
			var ev:AIRPadEvent = new AIRPadEvent(AIRPadEvent.CONNECT, null, kbIndex, pads[kbIndex]);
			dispatchEvent(ev);
			return true;
		}

		/**
		 * Removes an AIRKeyboard.
		 *
		 * @param uint index Index of the keyboard.
		 */
		private function removeKeyboard(index:uint):Boolean
		{
//			var kb:AIRKeyboard = pads[index];
			var kb:AIRKeyboard;
			var padIndex:uint;
			for (padIndex = 0; padIndex < MAX_PADS; ++padIndex)
			{
				if (pads[padIndex] && pads[padIndex].index == index && pads[padIndex] is AIRKeyboard)
				{
					kb = pads[padIndex];
					break;
				}
			}

			if (!kb)
			{
				if (AIRPadHelper.debug) trace("[AIRPadManager] no keyboard at '" + padIndex + "'.");
				return false;
			}

			_numConnectedPads--;
			numConnectedKeyboards--;

			pads[padIndex] = null;
			kbConnected[index] = false;
			var ev:AIRPadEvent = new AIRPadEvent(AIRPadEvent.DISCONNECT, null, padIndex, kb);
			dispatchEvent(ev);
			return true;
		}

		//==============================
		// Event Handlers
		//==============================

		private function onControllerAttach(e:AIRControlEvent):void
		{
			if (AIRPadHelper.debug) trace("[AIRPadManager] attach!");
			var controller:AIRControlController = AIRControl.controller(e.controllerIndex);
			if (controller.buttonsTotal < 1)
			{
				// What is this you ask?
				// Well, I tried -- without success -- to get a Wiimote (pre-Motion Plus)
				// working on Windows 8 with no joy. One of the side-effects of this is
				// that libs with joystick support like AIRControl and SFML now see a
				// Wiimote that is not actually connected yet still visible in the list
				// of joysticks attached to the system.
				//
				// This is highly annoying, yet it offers an opportunity to make AIRPad
				// a more robust library. Specifically, this phantom joystick reports
				// having 0 buttons making it an especially useless input device. So, this
				// check ignores any pads that don't have at least one button which solves
				// my peculiar problem while also improving the overall quality of AIRPad.
				return;
			}
			if (_numConnectedPads < MAX_PADS)
			{
				var deviceID:String = AIRPadHelper.deviceIDFromController(controller);
				var padIndex:uint = getIndex(deviceID);
				if (padIndex == DO_NOT_ADD)
				{
					if (AIRPadHelper.debug) trace("[AIRPadManager] Not adding pad.");
					return;
				}

				pads[padIndex] = new AIRPad(controller, padIndex);
				padDeviceIds[padIndex] = deviceID;
				_numConnectedPads++;
				_numPhysicalPads++;

				var ev:AIRPadEvent = new AIRPadEvent(AIRPadEvent.CONNECT, controller, padIndex, pads[padIndex]);
				dispatchEvent(ev);
			}
		}

		private function onControllerDettach(e:AIRControlEvent):void
		{
			var controller:AIRControlController = e.controller;
			if (controller)
			{
				var pad:AIRPad;
				for (var i:uint = 0; i < MAX_PADS; ++i)
				{
					if (pads[i] && pads[i].id == controller.ID)
					{
						if (AIRPadHelper.debug) trace("[AIRPadManager] detaching controller.");
						var ev:AIRPadEvent = new AIRPadEvent(AIRPadEvent.DISCONNECT, controller, _numConnectedPads, pads[i]);
						dispatchEvent(ev);
						pads[i] = null;
						_numConnectedPads--;
						_numPhysicalPads--;
						return;
					}
				}

				if (AIRPadHelper.debug) trace("[AIRPadManager] Unable to remove controller ID: " + controller.ID);
			}
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
//			trace("KEY DOWN: " + e.keyCode + ", " + AIRKeyboard.lookUpKeyCode(e.keyCode));
			for (var i:uint = 0; i < MAX_PADS; ++i)
			{
				if (pads[i] is AIRKeyboard)
				{
					pads[i].setButtonDown(AIRKeyboard.lookUpKeyCode(e.keyCode));
				}
			}
		}

		private function onKeyUp(e:KeyboardEvent):void
		{
//			trace("KEY UP: " + e.keyCode + ", " + AIRKeyboard.lookUpKeyCode(e.keyCode));
			for (var i:uint = 0; i < MAX_PADS; ++i)
			{
				if (pads[i] is AIRKeyboard)
				{
					pads[i].clearButtonDown(AIRKeyboard.lookUpKeyCode(e.keyCode));
				}
			}

		}
	}
}
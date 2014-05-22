# AIRPad

Have you ever tried using a gamepad (sometimes called "joystick") with AIRControl? It works great until you plug in a different type of gamepad. Then you find out that different gamepads map their buttons differently -- and that's just on the same OS. If you set up a gamepad on Windows there is almost no chance that configuration will hold true on a Mac.

AIRPad alleviates this issue.

AIRPad is a wrapper for [AIRControl](https://github.com/AlexanderOMara/AIRControl) an AIR Native Extension that enables gamepad support in Adobe AIR. AIRPad provides a standard API for popular gamepads so you can configure your game to work with AIRPad and it will just work with any supported pad on Mac and Windows.

## Supported Gamepads

### Windows

- Xbox 360 (wired)
- Xbox 360 (wireless)
- Dual Shock 3 (with [Motionjoy Driver](http://www.motioninjoy.com/))

### Mac OS

- Dual Shock 3
- Xbox 360 (wired, with [Tattiebogle Driver v0.08](http://tattiebogle.net/index.php/ProjectRoot/Xbox360Controller/OsxDriver))
- Wiimote (horizontal like NES pad, no attachments, with [WJoy 0.7.1](https://code.google.com/p/wjoy/))
- Wiimote with Classic Controller (with [WJoy 0.7.1](https://code.google.com/p/wjoy/))
- Wiimote with Nunchuck (with [WJoy 0.7.1](https://code.google.com/p/wjoy/))

#### Not Seeing Your Gamepad Here?

The list of supported pads is limited to ones I have physical access to and any additional pads provided by others using AIRPad. If AIRPad doesn't support your gamepad check out the [AIRControl Show All Input](https://github.com/AlexanderOMara/AIRControl/tree/master/examples/AIRControl_Example_ShowAllInput) example app. This app will help you [create a controller mapping for AIRPad](#adding-mappings).

## Where To Find Things

The source code for the AIRPad library is in the `lib` folder. The testbed application is in `testbed`.

## Features

### Cross Platform API

Standardized around on popular gamepads like the Xbox 360 pad and Dual Shock 3, AIRPad provides consistent button names across platforms and gamepads.

### Command Binding

Bind commands you define to specific AIRPad's predefined buttons enabling self-documenting code and player-configurable input settings.

### Analog Normalization and Dead Zones

AIRPad normalizes all analog values in a range of `-1` to `1` for analog sticks and `0` to `0` for analog triggers.

To handle the varying quality and wear put on analog inputs AIRPad uses dead zones -- small threshold under which values are ignored ([more here](http://www.third-helix.com/2013/04/doing-thumbstick-dead-zones-right/)).

### Analog "Buttons"

Treat analog sticks like digital buttons. AIRPad provides standard analog "buttons" that allow you to treat analog sticks like d-pads. You can even combine analog buttons with command binding.

### Connection/Disconnection Handling

Having your gamepad disconnect in the middle of a game sucks. It sucks even more to re-connect your gamepad only to have it not be recognized as the same gamepad. AIRPad works to ensure your reconnected pad works like nothing ever happened.

## Getting Started

### Test Bed

For a working example checkout the [AIRPadTestBed](testbed/) project. The test bed is a simple Flex application that uses all the features of AIRPad and serves as a way to quickly test that your pads are functioning properly.

### Adding AIRPad to Your Project

Adding AIRPad to your project is simple. Just clone this repo and add the latest swc from the `releases` folder to your project's library path. Then add the AIRControl ANE to your project and you're ready to go.

### Setting up AIRPad

Most of AIRPad's functionality is managed for you by `AIRPadManager`. The first thing you need to do when using AIRPad is create an instance of `AIRPadManager`. Your instance of `AIRPadManager` manager must remain in scope as long as you want to use it. The constructor for `AIRPadManager` takes no arguments so all you need is:

    // Create an AIRPadManager instance
    var myManager:AIRPadManager = new AIRPadManager();

Now that we have an `AIRPadManager` we'll need to make sure it gets updated. To do this simply call the `update()` method on your instance inside your game loop:

    function myGameLoop():void
    {
        // Update the manager
        myManager.update();
    }

Be sure to call this once each frame _before_ you poll any of the connected pads.

### AIRPad Events

Our `AIRPadManager` instance is created and updating now we need to add a few things so we can actually do something with it. First we'll add listeners for connect and disconnect events.

Immediately after creating the instance add the following:

    myManager.addEventListener(AIRPadEvent.CONNECT, onPadConnect);
    myManager.addEventListener(AIRPadEvent.DISCONNECT, onPadDisconnect);

The `AIRPadEvent.CONNECT` event is dispatched whenever a new gamepad is connected to the system. `AIRPadEvent.DISCONNECT` is dispatched when a controller disconnects from the system. `AIRPadEvent` has two properties of interest:

1. __pad__: A reference to the `IAIRPadDevice` that just (dis)connected.
2. __controllerIndex__: The zero-based integer index of the `IAIRPadDevice` that just (dis)connected.

You can keep the `pad` reference in your game (on a player for example) and use the `controllerIndex` to associate it with a specific player (e.g., `controllerIndex` 2 is player 3).

When a controller connects, then disconnects, then reconnects AIRPad will ensure the reconnected pad will have the same index it had prior to disconnecting.

We'll need to implement the handlers for these events as well:

    function onPadConnect(e:AIRPadEvent):void
    {
        trace("IAIRPadDevice connected at index: ", e.controllerIndex);
        // Do something with the pad here
    }

    function onPadDisconnect(e:AIRPadEvent):void
    {
        trace("IAIRPadDevice disconnected at index: ", e.controllerIndex);
        // Do something like pause the game and prompt the player
        // to reconnect the pad.
    }

### Getting an IAIRPadDevice from the Manager

We can also get a reference to a specific `IAIRPadDevice` from the manager at any time with the `getPad()` method:

    // Get the pad at index 1
    var pad1:IAIRPadDevice = myManager.getPad(1);

It's important to note that the return value from `getPad()` may be `null` so you need to check any pad you retrieve with this method.

### IAIRPadDevice?

`IAIRPadDevice` is an interface that all devices managed by AIRPad must implement. There are two implementations of `IAIRPadDevice` that ship with AIRPad:

1. __AIRPad__: A gamepad device.
2. __AIRKeyboard__: A keyboard device.

Obviously if we're using AIRPad we want to support gamepads, probably even prefer them, but we cannot be guaranteed our players will have a gamepad. If they do have a pad it may get unplugged or a wireless pad might lose charge. Having an `AIRKeyboard` allows us to seemlessly handle all of these situations without having to change our input API in our game -- `AIRKeyboard` functions identically to `AIRPad` so far as the API is concerned.

### Polling an IAIRPadDevice

#### Buttons

To get information from an `IAIRPadDevice` we poll it. For buttons there are three methods to get the state of a button. The first is `isButtonDown()` which will return `true` if the button is down (pressed) and `false` if it's up (not pressed):

    // Is the button down?
    if (myPad.isButtonDown(AIRPadButton.FACE_ONE))
    {
        trace("FACE_ONE is down.");
    }
    else
    {
        trace("FACE_ONE is up.");
    }

Some times we want to do something only if a button was just pressed. For that we use `wasButtonJustPressed()` which will return true if the button was just pressed and false in all other cases:

    // Was the button just pressed?
    if (myPad.wasButtonJustPressed(AIRPadButton.FACE_ONE))
    {
        trace("FACE_ONE just pressed.");
    }

In other cases we want do something only when a button was just released (like firing a weapon that was charged by holding a button down). In this instance we use `wasButtonJustReleased()` which returns `true` if the button was just released and `false` if not:

    // Button was just released?
    if (myPad.wasButtonJustReleased(AIRPadButton.FACE_ONE))
    {
        trace("FACE_ONE just released.")
    }

#### Analog Sticks

`IAIRPadDevice`s also feature analog axes in the form of triggers and sticks. Analog are not on/off but instead return a floating point value (`Number`) in the range of `-1` to `1` for sticks and `0` to `1` for triggers.

`IAIRPadDevice`s have up to two analog sticks identified as `AIRPadButton.LEFT_STICK` and `AIRPadButton.RIGHT_STICK`. Each stick is an instance of `AIRPadStick` with `x` and `y` properties for the horizontal and vertical axes respectively. Along the horizontal axis `-1` is fully left and `1` is fully right. On the vertical axis `-1` is fully up and `1` is fully down. To get a stick we use the `getStick()` method:

    // The right stick
    var rightStick:AIRPadStick = myPad.getStick(AIRPadButton.RIGHT_STICK);
    trace("Right stick values: ", rightStick);

Sticks can also be accessed directly via the `leftStick` and `rightStick` properties of an `AIRPad`.

#### Analog Triggers

`AIRPad`s may have up to two analog triggers known as `AIRPadButton.LEFT_TRIGGER` and `AIRPadButton.RIGHT_TRIGGER`. Each trigger is simply a `Number` with `0` meaning "not pressed at all" and `1` meaning "fully pressed". To poll the value of a trigger use `getTrigger()`:

    // The left trigger
    var leftTrigger:Number = myPad.getTrigger(AIRPadButton.LEFT_TRIGGER);
    trace("The left trigger's value is: ", leftTrigger);

Triggers may also be directly access via the `leftTrigger` and `rightTrigger` properties of an `AIRPad`.

#### Missing Buttons

The AIRPad API is standardized around the Xbox 360 and Dual Shock 3 as these are common, popular gamepads. However, not all pads fit this API perfectly. One notable example is the Wiimote without any attachments. A Wiimote has no analog sticks nor triggers. In cases like this AIRPad will return the "up" value for any feature a controller lacks. This means that the analog stick x-y values for a Wiimote will always be 0. Likewise, trigger values will always be 0 as well.

### Dead Zone

"Dead zone" is an input threshold used to disregard vanishingly small values from analog inputs. [This post](http://www.third-helix.com/2013/04/doing-thumbstick-dead-zones-right/) by Josh Sutphin describes dead zone in detail and forms the foundation on which dead zone is implemented in AIRPad.

Each controller mapping in AIRPad provides a default dead zone for the pad's analog sticks and triggers. If this value needs tuning it can be adjusted by setting the `deadZone` property on an `IAIRPadDevice`. `deadZone` is simply a `Number` from `0` to `1` where 0 means "no dead zone" and 1 means "all dead zone". Setting `deadZone` to `0` means the game will pick up every tiny jitter on the game pad. Setting it to `1` means all input will be ignored.

### Binding Commands

Command binding is a feature that allows us to map any value we choose to a specific `AIRPadButton`. One use of command binding is to make our code more readable. Rather than using `AIRPadButton.FACE_ONE` we can create our own `Commands` class and populate it with values like `Commands.KICK`, `Commands.PUNCH`, `Commands.MOVE_RIGHT` and so on.. We then map our commands to specific buttons:

    // Map our "jump" command to AIRPadButton.FACE_ONE.
    myPad.bindCommand(Commands.KICK, AIRPadButton.FACE_ONE);

    // Now we can poll for Commands.KICK instead of AIRPadButton.FACE_ONE
    // (we can use both still)
    if (myPad.isButtonDown(Commands.KICK))
    {
        // This is the same as:
        // myPad.isButtonDown(AIRPadButton.FACE_ONE);
    }

We can also bind the same command to multiple buttons:

    // Map "jump" to multiple face buttons
    myPad.bindCommand(Commands.KICK, AIRPadButton.FACE_ONE);
    myPad.bindCommand(Commands.KICK, AIRPadButton.FACE_TWO);

    // Jumping?
    if (myPad.isButtonDown(Commands.KICK))
    {
        // Same as:
        // if (myPad.isButtonDown(AIRPadButton.FACE_ONE) || myPad.isButtonDown(AIRPadButton.FACE_TWO))
    }

Another use for command binding is to support custom key bindings for players. By using command binding we can change which `AIRPadButton` is mapped to our game-specific `Commands` so `Commands.KICK` can be mapped to `AIRPadButton.L1` rather than `AIRPadButton.FACE_ONE` without touching our input handling code.

### Analog "Buttons"

Analog "buttons" are a feature that allow us to treat analog sticks and triggers like digital buttons. Internally they are implemented such that if the analog value is greater than the `IAIRPadDevice`'s `deadZone` the "button" is set to "down", otherwise the "button" is "up". From a usage standpoint these "buttons" function exactly like [physical digital buttons](#buttons).

`AIRPadButton` provides the following analog "buttons":

- __L2__:                Left trigger pressed
- __R2__:                Right trigger pressed
- __LEFT_STICK_UP__:     Left stick pressed up
- __LEFT_STICK_RIGHT__:  Left stick pressed right
- __LEFT_STICK_DOWN__:   Left stick pressed down
- __LEFT_STICK_LEFT__:   Left stick pressed left
- __RIGHT_STICK_UP__:    Right stick pressed up
- __RIGHT_STICK_RIGHT__: Right stick pressed right
- __RIGHT_STICK_DOWN__:  Right stick pressed down
- __RIGHT_STICK_LEFT__:  Right stick pressed left

## Adding Mappings

Mapping is currently a bit of a cumbersome process involving an AIRControl example app and the authoring of a JSON controller mapping file. The JSON file is straight forward with objects for `buttons`, `pov` and `axes` that map buttons, POV switches and axes respectively. Additionally there are properties to control dead zone and analog normalization.

For complete examples check out the [Windows Xbox 360 mapping](lib/src/airpad/controller_mappings/win-controller-xbox-360-for-windows.json) and the [Mac Xbox 360 mapping](lib/src/airpad/controller_mappings/mac-controller.json).

### Mapping Elements

#### AIRControl Example App

To get the raw values for mapping use the [AIRControl Show All Input Example App](https://github.com/AlexanderOMara/AIRControl/tree/master/examples/AIRControl_Example_ShowAllInput). This app will give you the name of the controller and allow you to see which buttons and axes correspond with which indexes.

#### Mapping Name

The naming scheme for the mapping file is as follows:

    {platform_name}-{controller_name_provided_by_driver_no_spaces_or_parenthesis}.json

`{platform_name}` is `win` on Windows and `mac` on Mac. The controller name is provided by the driver. For the mapping file we replace all spaces with dashes (`-`) and remove all parentheses. Finally, the extension for the file is `json`.

#### Mapping Description

The first element for a mapping is "_desc", a short description of the mapping containing the name of the controller and (optionally) the driver used to create the mapping. The driver is especially important for controllers that lack an official (provided by the controller manufacturer) driver.

#### Buttons Object

"buttons" is a object whose keys correspond with `AIRPadButton` names (e.g., "faceOne", "start"). Each key in "buttons" is an object with the following values:

- "_desc": A description of the button, usually the name of the button on the pad (e.g., "Y" or "Triangle").
- "index": The index of the button reported by the example app.

#### POV Object

"pov" is an object whose keys keys correspond with `AIRPadButton` names (usually these are the dpad buttons). Each key in "pov" is an object with the following values:

- "_desc": A description of the button, typically the name of the button (e.g., "DPad Right").
- "element": The element that corresponds with the POV. This is a tad awkward as POV assumes x-y axes though it's almost certainly mapped to a dpad. This means that pressing the dpad-left button is "-1 on the x-axis" and pressing dpad-up is "-1 on the y-axis". So we cannot just map a simple index. Instead we combine the axis and the value such that dpad-left becomes "X-1", dpad-right becomes "X1" and so on. Check out the [Windows Xbox 360 mapping](lib/src/airpad/controller_mappings/win-controller-xbox-360-for-windows.json) for a concrete example.

#### Axes Object

"axes" is an object whose keys corresponds with `AIRPadButton` names. Each key in "axes" is an object with the following values:

- "_desc": A description of the axis, e.g., "Left stick, x-axis".
- "index": The index of the axis reported by the example app.

#### Meta Properties

Each controller has optional meta properties that affect how controller values are interpreted by AIRPad.

- __deadZone__:       A floating-point number indicating the dead zone threshold for analog sticks and triggers.
- __triggerMin__:     The minimum value for a trigger reported by the driver. Use this if the trigger reports values outside the `0` to `1` range. Must also use `triggerMax`.
- __triggerMax__:     The maximum value for a trigger reported by the driver. Use this if the trigger reports values outside the `0` to `1` range. Must also use `triggerMin`.
- __triggerDefault__: The default value for a trigger reported by the driver. This is used when the trigger reports a default value that is not the same as `triggerMin`. For example, the 360 pad on Mac reports a range from `-1` to `1` but when you start up a game and have yet to press the trigger it will report a value of `0`, not `-1`. Once the trigger has been pressed and released it will report `-1` when not pressed. Setting a `triggerDefault` value allows us to handle this odd siutation.
- __stickMin__:       The minimum value for a stick reported by the driver. Use this is the stick reports value outside the `-1` to `1` range. Must also use `stickMax`.
- __stickMax__:       The minimum value for a stick reported by the driver. Use this is the stick reports value outside the `-1` to `1` range. Must also use `stickMin`.

#### Notes

Each button, POV and axis key can have an optional key called "_note". Use this is describe any unusual behavior. For example, on Windows the 360 pad's left and right triggers share an axis making it impossible to use both. Similarly the Guide (Xbox) button is handled by the system and cannot be used.

## Known Issues

The Xbox 360 controller on Windows is not 100% functional. This is due to the fact that AIRControl uses DirectInput while the 360 controller requires XInput for full functionality. [Wikipedia](http://en.wikipedia.org/wiki/DirectInput#DirectInput_vs_XInput) describes the issue in greater detail. In the case of AIRPad this means that the left and right triggers of the 360 pad cannot both be used (pick one or the other) and the Guide button is also out of bounds.

## Support

If you have a problem [open a ticket](https://github.com/NoobsArePeople2/AIRPad/issues/new). When creating a ticket please be sure to give it a descriptive and succinct title along with a clear description of the problem. For every ticket please be sure to include the following information:

- __Platform and Version__: e.g., Mac OS 10.7, Windows 8, Windows 7
- __AIR SDK Version__
- __Gamepad Name__: e.g., Xbox 360 (wired or wireless), Dual Shock 4
- __Link to Gamepad Product Page__: e.g., [Dual Shock 4](http://us.playstation.com/ps4/features/dualshock4-controller/)
- __Gamepad Driver and Version__: e.g., Tattiebogle 0.08. This is especially important if your pad doesn't have official (provided by the pad manufacturer) drivers for your platform.

## Contact

If you have a question or comment drop be a line at <a href="mailto:sean@seanmonahan.org?subject=AIRPad">sean@seanmonahan.org</a>.

If you're using AIRPad in your game I'd love to hear about it!

## License

AIRPad is licensed under the MIT license.








![Powerblock Auth Banner](https://raw.githubusercontent.com/Powerblock2000/PowerblockAuth/refs/heads/main/addons/powerblock_auth/PowerblockAuth/PowerblockAuthBanner.png)
---
**Welcome to Powerblock Auth, the simple way to authenticate clients with Nakama!**

Test the example project ([here](https://powerblock2000.github.io/PowerblockAuth/WEBSITE/r2/index.html))

This guide will help you get setup!

## Step 1: Install

 1. To install download from the GitHub releases ([here](https://github.com/Powerblock2000/PowerblockAuth/releases/tag/Latest)) and add the addons folder to your project in Godot!

2. To run the project you will also need the Nakama Godot plugin found on the Asset Store ([here](https://godotengine.org/asset-library/asset/1642)) or on their GitHub page ([here](https://github.com/heroiclabs/nakama-godot))
3. Set the `Nakama.gd` file (found in addons/com.heroiclabs.nakama/Nakama.gd) as an autoload in settings
4. Set both the `NakamaManager.gd` file and the `PowerblockAuth.gd` file as autoloads as well

Now your autloads should look like this:
![Autoloads](https://github.com/Powerblock2000/PowerblockAuth/blob/main/addons/powerblock_auth/PowerblockAuth/autoloads.png?raw=true)

## Step 2: Configure server information and setup authentication

 1. Open your `NakamaManager.gd` file and change the constants at the top to match your servers information
 2. in your start scene call `await NakamaManager.connect_to_nakama(PowerblockAuth.AuthMethods.authmethod)` change `authmethod` to which ever method you would like to use to authenticate your client. As of now only **email** and **deviceID** work. Both are supported on web.
 3. That's it, your client is now connected to your Nakama server!
Ex:
```gdscript
extends Node
func _ready() -> void:
	await NakamaManager.connect_to_nakama(PowerblockAuth.AuthMethods.EMAIL)
```

## Step 3 (optional): Add your logos and colors

If you want to customize the look of the email authentication screen you may but please keep our logo visible.
You can accomplish this using the plugins functions like so:

`
PowerblockAuth.set_branding(load("res://icon.svg"), Color(0.0, 1.0, 0.0, 1.0))`
make sure to do this BEFORE you call `connect_to_nakama()` or it won't take effect!

We made this handy template to make sure you keep everything in the right spot:

![Template](https://github.com/Powerblock2000/PowerblockAuth/blob/main/addons/powerblock_auth/PowerblockAuth/AUTH%20template.png?raw=true)

Put ANYTHING you want in the green space, but make sure to keep NOTHING in the red space

# ⚓ OnDock
Perform any action when connecting and disconnecting external docks!

## About
As laptops, tablets, and UMPC's grow ever more powerful, more and more users are choosing mobile computers as their primary PC. However, there's still countless advantages of a desktop mouse, keyboard, and monitor while not on the go. Combined with the convenience of a single USB-C cable to connect all these and more at once, **docking** is taking the world by storm.

However, how you use your computer when docked and when mobile may be quite different. **Wouldn't it be nice if your PC automatically reconfigured itself when docking and undocking?** 

Well, now it can!

OnDock is a combination of PowerShell and Windows Task Scheduler that runs silently in the background and consumes nearly no resources. It listens for changes to **either** the current power source **or** number of connected displays, and executes custom actions accordingly. Copy any scripts, programs, and files to the `Connect` and `Disconnect` folders in your Start menu, and OnDock will automatically execute them when you connect or disconnect from your docking solution!

## How to Use
1. Download the latest OnDock Installer script from [releases](https://github.com/Lulech23/OnDock/releases/latest). You must choose between using display or power connectivity as a trigger for custom actions.
2. Run the script of your choice and proceed through the fully automated installation.
3. Locate the OnDock folder in your Start menu, and open the shortcut provided to reveal two folders named `Connect` and `Disconnect`, respectively.
4. Copy any scripts, programs, and files to these folders for OnDock to execute accordingly. For some starter examples, see the [tools](https://github.com/Lulech23/OnDock/tree/main/tools) folder in this repository.

If you decide OnDock isn't for you, simply run the script again and it'll undo all changes to your system. You will be prompted whether to keep or remove custom actions, so you won't lose your setup if you decide to come back or switch triggers later.

## Known Issues
* **None for now. Hooray!**

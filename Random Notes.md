Mod version needs to be incremented when FML is first installed (and possibly updated?) because of global modifications.
This is only really a problem when developing as the mod is going to be distributed to user as a *new version*.

---

## Installation and Loading ##

- Install the FML mod (from the mod portal)
- Add FML as a dependency of your mod (`info.json` -> `dependencies: ["FML"]`)
- Download the FML.lua file and place it anywhere in your mod (`__your-mod__/FML.lua`)
- Open the file with a text editor and edit the value of MOD.NAME near the top to reflect your mod
- In your control.lua file add `local FML = require "FML"` (replace the path with the one you have chosen)

*If you're installing FML into an existing mod, make sure to increment it's version so FML can initialize itself. If you
don't do this, you will likely encounter CRC check errors on existing saves with your mod installed.*

To access FML use `local FML = therustyknife.FML`. In the control stage, this can (*obviously*) only be done after FML is
loaded using the client script.

`require` can only be used to load FML before the game is initialized in the runtime stage.  
*It is not recommended, but if you need to load FML after the game is initialized (within an event handler), you can use
the console API. Be aware however, that this is not intended usage and therefore not officially supported.*

---

Certain modules are intended to be localized before usage, that means doing something like `local table = FML.table`.
This is not required for the functionality of the module, but makes it's usage much more convenient.  
Modules that are recommended to be localized:  

- table (icludes all the built-in Lua table functions so it is compatible with existing code)
- log (provides the `__call` metamethod to remain compatible with code using Factorio's log function)
- *Any other module that you use often, obviously*

---

It's advised to put a well visible notice on the mod page that your mod requires FML to work. Eventough Factorio does
show what dependencies a mod has, it's not very well visible, so users will likely miss it and report issues to you as
the mod author.  
Also not a bad idea is to put the notice directly into the mod's description (`info.json`) so the user can see the dependencies
when downloading from the built-in mod browser.

All of the above can (and should) be applied to any important (non-optional) dependency, not just FML specifically.

---

FML updates are distributed via the FML mod on the mod portal, so there's no need to change anything in your code to update
to a new FML release.
The goal is for the releases to be backwards compatible, however somtimes that might not be possible, so I declare these
guidelines for FML releases:

- Any patch release is fully compatible with the last release and it's sole purpose is to fix issues in the current features.
This means that a patch may never declare a feature deprecated nor may it add or remove features.
- Minor releases are backwards compatible, but they may add new features or declare old features deprecated. A minor release
will never remove any features.
- A major release is (unless previously stated otherwise) backwards compatible with code from the previous release that
did not use any deprecated features.

Of course, the above are only guidelines and it may happen that some things slip through, so be careful and report any issues.

---

## Logging ##

FML distinguishes between three log levels - `debug`, `warning`, `error`. Their meaning is as follows:

- `debug` - This should be used for general debugging messages like values of variables, or messages that occur too often
for normal usage.
- `warning` - This should be used in situations where the modder's attention may be appropriate, but the user shouldn't
notice any difference.
- `error` - This should be used in situations where the mod's behavior is unexpected in some way, preventing it from
performing some of it's functions.

**Make sure that you disable `debug` level logging before you release your mod!** Also make sure that the `LOG.IN_CONSOLE`
option is disabled. It is recommended to leave `error` level logging on in releases of your mod so you can use it to
diagnose your users' issues.

Eventough FML replaces inactive logging functions with empty ones, it is not advised to write log statements that run
every tick or similar. The performance of such setup is not ideal, not to mention it clogging up the log file and making
it useless anyway.

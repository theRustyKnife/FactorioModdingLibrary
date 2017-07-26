Mod version needs to be incremented when FML is first installed (and possibly updated?) because of global modifications.
This is only really a problem when developing as the mod is going to be distributed to user as a *new version*.

---

## Installation and Loading ##

- Install the FML mod (from the mod portal)
- Add FML as a dependency of your mod (`info.json` -> `dependencies: ["FML"]`)
- Download the FML.lua file and place it anywhere in your mod (`__your-mod__/FML.lua`)
- Open the file with a text editor and edit the value of MOD.NAME near the top to reflect your mod
- In your control.lua file add `local FML = require "FML"` (replace the pathwith the one you have chosen)

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

# Work in progress #

## Temporary install notes ##
The library mod is found in the `FML` directory. This is installed as any other mod.

To add the library to your mod, grab the file from the `FML_local` directory and add it to your mod. Then open the file and set the mod name near the top to the name of your mod (obviously). Also add FML to your dependency list in `info.json`.  
To use it do these things as needed:
- In the data and settings stage (`data.lua` and `settings.lua`) simply access the library via the global variable `therustyknife.FML`: `local FML = therustyknife.FML`
- In the runtime stage (`control.lua`) require the local FML file on top of your `control.lua` using `require "<path-to-the-file>"`. Then access the library using the global variable `therustyknife.FML`, similarly to the data stage.

## Other info ##
There should be a somewhat usable documentation on the [wiki](https://github.com/theRustyKnife/FactorioModdingLibrary/wiki).

For a bunch of random notes, see [Random Notes.md](https://github.com/theRustyKnife/FactorioModdingLibrary/blob/0.1-dev/Random%20Notes.md).

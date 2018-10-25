# PyMOL-to-NGL-transpiler
A script to transpile a PyMOL PSE file to a NGL.js view.

## Parts to convert
Three parts are needed to convert a `.pse` file into a NGL view.
* the model
* orientation
* representation
    * lines, sticks, cartoon etc.
    * colors
    * surface (handled differently in NGL)

Additionally, there are
* text/labels which are normally added in photoshop by people...
* arrows, which are great, but in PyMol are from the add-on script `cgo_arrows` and not part of the native code

## Script functionality
The script `PyMOL_to_NGL.py`

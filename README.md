# SimpleDataStore

## This is SimpleDataStore by CrabGuy
Automatically saves and loads player data so you don't have to deal with datastores at all.

## Usage
To use this script, put the code inside a module script, require it using a normal script in ServerScriptService and call it.

Add a folder in ReplicatedStorage called "Data" and you can put Values or other Folders inside of it.
The Data folder will get cloned and parented to the player and every change made to its values will save between joins.

## Optionals
Values in the Data folder can have the boolean attribute "Volatile" set to true to avoid saving them (if you want to have a value inside Data which is not saved)

The module script can have attributes to modify the behaviour:
  - DataFolderName [string] : use a custom name for the Data folder (default: "Data")
  - DataStoreKey [string] : use a custom datastore key, to change the datastore (default: "a")
  - DontSaveInStudio [boolean] : avoids saving and loading data while testing in studio, does not affect the actual servers of the game (default: False)

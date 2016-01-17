UserDefineObject Subclassing
============================

The following are required updates for new `UserDefineObject` subclasses or modifications of current `UserDefineObject` subclasses.
	
### In the `UserDefineObject` subclass:
* Add new properties as private instance variables (including getters/setters).
* For complex subclasses, override and/or update the getContentValues() method to include the new properties.
* Add new properties to the cloning constructor.
  > Note that if a property is a subclass of UserDefineObject, the `ClassName(ClassName obj, keepId)` must be called with `keepId = true` in the obejct's cloning constructor.
* If the new `UserDefineObject` subclass has another `UserDefineObject` instance variable that is linked to a separate database table, create manipulation methods for that variable (see `PhotoUserDefineObject`).
* The cloning constructor and `getContentValues()` should access the same number of properties, which should be equal to the object's declared instance variables.
	
### Database stuff:
* Create or update a `Cursor` subclass for the new `UserDefineObject` subclasses.
* `LogbookSchema` requires a new table scheme.
* `LogbookHelper` requires new or updated table creation.
* If a new `UserDefineObject` subclass is created, add manipulation methods to `Logbook` (follow pattern from existing `UserDefineObject` subclasses).

### A note about to-many relationships:
SQLite doesn't directly support storing an array in a single column.  For `UserDefineObject` subclasses that require a collection of some sort (i.e. `Catch` requires a collection of images and a collection of `FishingMethod` objects), a new table should be created and accessed by the `UserDefineObject`.

*EXAMPLE:*

The `Catch` class does not have an instance variable for its fishing methods.  Instead, its `getFishingMethods()` and `setFishingMethods()` methods interact directly with the SQLite database.  It reads from a table with `catchId-fishingMethodId` pairs to get all the fishing methods associated with a given catch.

This is the preferred method over concatinating FishingMethod id's in a String.

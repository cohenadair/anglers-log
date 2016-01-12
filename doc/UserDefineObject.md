UserDefineObject Subclassing
============================

The following are required updates for new `UserDefineObject` subclasses or modifications of current `UserDefineObject` subclasses.
	
### In the `UserDefineObject` subclass:
* Add new properties as private instance variables (including getters/setters).
* For complex subclasses, override and/or update the getContentValues() method to include the new properties.
* Add new properties to the cloning constructor. 
* If the new `UserDefineObject` subclass has another `UserDefineObject` instance variable that is liked to a separate database table, create manipulation methods for that variable (see `PhotoUserDefineObject`).
> Note that if a property is a subclass of UserDefineObject, the `ClassName(ClassName obj, keepId)` must be called with `keepId = true` in the obejct's cloning constructor.
	
### Database stuff:
* Create a `Cursor` subclass for the new `UserDefineObject` subclasses.
* `LogbookSchema` requires a new table scheme.
* `LogbookHelper` requires new table creation.
* Add manipulation methods to `Logbook` (follow pattern from existing `UserDefineObject` subclasses).	

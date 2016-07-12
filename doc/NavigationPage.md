Adding a Navigation Page
========================

The following steps are required to implement a new page in the navigation drawer.

#### Icon files
* Download icons from [Google Icons](https://design.google.com/icons/) and copy to the corresponding `res/` directory.
* If there are no suitable icon on Google, use [Icons8](http://icons8.com/web-app/for/ios7/book) and the `action_bar_maker.sh` in `tools/` to create the correct icon sizes.

#### In `menu_navigation_drawer.xml`
* Add the new item to the correct group.

#### In `LayoutSpecManager.java`
* Add `LAYOUT_` constant.
* Add `case` for the new constant to `layoutSpec(Context, int)`.
* Add the `get` method for the new layout. Follow patterns from similar layouts.

#### New files
* Create a master fragment for the new layout (at minimum).
* Create a detail fragment for the new layout (optional).
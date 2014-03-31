#### SOMapPreview ```` version 0.1 ````

##### By Alex Evers

---

##### A static map image view that generates a map snapshot and drawn line based on a provided ```MKPolyline``` object.

Intended for inline use with UITableView or UICollectionView where maps would be shown per cell or similar. 

##### version 0.1 (Current)
+ Generates a UIImage from an Apple Map based on an MKPolyline object.
+ Draws a line tracing the MKPolyline on top of the taken UIImage.
+ Caches the UIImage and loads it dynamically regardless of App state.
+ Configurable:
	- Images can be converted to greyscale.
	- All map options are configurable (POI, Buildings, mapType).
	- Set the color of the drawn line.
	- Set a placeholder image while the Map image is generated.
	- Border and corner rounding is toggleable.
+ Scaleable (untested)

---

<p align="center" >
  <img src="https://raw.github.com/1ps0/SOMapPreview/master/assets/mapcache1.png">
</p>

---

##### version 0.2 
+ Test/fixup scaling and add a Demo view for it.
+ Add ability to drop-in 'working' animation view.
+ Remove external dependencies (SOAnimationSequence, +MapRendering).
+ Add alternative to MKPolyline requirement.

---

This code base is copyright ©2013-2014 under [GNU General Public License](http://www.gnu.org/licenses/gpl.html).
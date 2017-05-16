/// @description Update room data

// Reset surface
if(surface_exists(surf))
	surface_free(surf);
surf = -1;

// Reset the active variables
activeView = undefined;
if(ready)
	ds_grid_destroy(activeBgs);
activeBgs = ds_grid_create(12, 12);
activeTiles = undefined;
activeObjects = undefined;

// Get the views
var views = l.rooms[currentRoom, 18];

// Find the first view, and if there isn't one
var i;
noView = false;
for(i = 0; i < array_height_2d(views); i++){ // Find the first active view, no need to get the rest
	if(views[i, 0] == true)
		break;
	if(i == array_height_2d(views) - 1)
		noView = true;
}

// Initialize view variables
if(noView){
	viewX = 0;
	viewY = 0;
	viewW = window_get_width();
	viewH = window_get_height();
	viewPW = viewW;
	viewPH = viewH;
} else {
	viewX = views[i, 1];
	viewY = views[i, 2];
	viewW = views[i, 3];
	viewH = views[i, 4];
	viewPW = views[i, 7];
	viewPH = views[i, 8];
}

activeView[0] = views[i];

// Load backgrounds
var bgs = l.rooms[currentRoom, 17];

var i;
hasActive = false;
for(i = 0; i < array_height_2d(bgs); i++){
	if(bgs[i, 0] == true && bgs[i, 2] >= 0 && bgs[i, 2] < 100000){
		for(var j = 0; j < 10; j++)
			activeBgs[# i, j] = bgs[i, j];
		hasActive = true;
	}
}

// Load tiles
activeTiles = l.rooms[currentRoom, 20];

// Load objects
activeObjects = l.rooms[currentRoom, 19];

// Tell the draw event that the variables are initialized
if(!ready)
	log("Room viewer ready");
ready = true;
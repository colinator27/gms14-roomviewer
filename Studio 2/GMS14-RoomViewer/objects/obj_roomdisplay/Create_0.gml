surf = -1;

currentRoom = 0;

l = obj_loader; // Simplify the loader name, make a permanent reference to it

if(!l.loaded){
	log("Loader hasn't loaded data file. Room display cannot work.");
	exit;
}

viewX = 0;
viewY = 0;

ready = false;
uiVisible = true;

drawObjects = true;
drawTiles = true;
drawBackgrounds = true;

event_user(0);
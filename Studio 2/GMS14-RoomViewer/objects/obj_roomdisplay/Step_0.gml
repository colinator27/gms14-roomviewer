/// @description Controls

// Movement
repeat(keyboard_check(ord("X")) + 1){
	if(keyboard_check(vk_right))
		viewX += 5;
	if(keyboard_check(vk_left))
		viewX -= 5;
	if(keyboard_check(vk_up))
		viewY -= 5;
	if(keyboard_check(vk_down))
		viewY += 5;
}

// Tiles, objects, and backgrounds
if(keyboard_check_pressed(ord("T")))
	drawTiles = !drawTiles;
if(keyboard_check_pressed(ord("O")))
	drawObjects = !drawObjects;
if(keyboard_check_pressed(ord("B")))
	drawBackgrounds = !drawBackgrounds;
	
// Move forward one room
if(keyboard_check_pressed(vk_space) && currentRoom < array_height_2d(l.rooms) - 1){
	currentRoom++;
	event_user(0);
}

// Move back one room
if(keyboard_check_pressed(vk_shift) && currentRoom > 0){
	currentRoom--;
	event_user(0);
}

// Hide menu
if(keyboard_check_pressed(ord("C"))){
	uiVisible = !uiVisible;
}
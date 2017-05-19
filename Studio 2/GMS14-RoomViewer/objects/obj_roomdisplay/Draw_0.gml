/// @description Draw room

// Make sure that the variables are initialized
if(!ready)
	exit;

// Calculate scaling of viewport
var viewscaleW = viewPW / viewW;
var viewscaleH = viewPH / viewH;
if(l.defaultWindowWidth / viewW > viewscaleW)
	viewscaleW = l.defaultWindowWidth / viewW;
if(l.defaultWindowHeight / viewH > viewscaleH)
	viewscaleH = l.defaultWindowHeight / viewH;

// Draw background color if there is one
if(l.rooms[currentRoom, 7] == true){
	draw_set_color(l.rooms[currentRoom, 6]);
	draw_set_alpha(1);
	draw_rectangle(0, 0, window_get_width(), window_get_height(), false);
}

// Create surface and clear
if(!surface_exists(surf)){
	surf = surface_create(l.rooms[currentRoom, 2], l.rooms[currentRoom, 3]);
}
surface_set_target(surf);
draw_clear_alpha(c_black, 0);

// If there are backgrounds, draw them
if(hasActive){
	// Loop through the backgrounds
	if(drawBackgrounds)
	//for(var i = ds_grid_height(activeBgs) - 1; i >= 0; i--){
	for(var i = 0; i < ds_grid_height(activeBgs); i++){
		var bgIndex = activeBgs[# i, 2];
		// Check for these just in case
		if(bgIndex >= 0 && bgIndex < 100000 && activeBgs[# i, 0] == true){
			// Get variables from loader
			var texOffset = l.backgrounds[bgIndex, 4];
			var page = l.texpages[l.texpageIds[? texOffset], 10];
			var texX = l.texpages[l.texpageIds[? texOffset], 0];
			var texY = l.texpages[l.texpageIds[? texOffset], 1];
			var texW = l.texpages[l.texpageIds[? texOffset], 2];
			var texH = l.texpages[l.texpageIds[? texOffset], 3];
			var roX = l.texpages[l.texpageIds[? texOffset], 4];
			var roY = l.texpages[l.texpageIds[? texOffset], 5];
			
			// Draw the background!
			draw_sprite_part(l.spritesheets[page],0,texX,texY,texW,texH,activeBgs[# i, 3]+roX,activeBgs[# i, 4]+roY);
		}
	}
}

// Draw tiles
if(drawTiles)
for(var i = 0; i < array_height_2d(activeTiles); i++){
	if(activeTiles[i, 2] >= 0 && activeTiles[i, 2] < 100000){
		var texOffset = l.backgrounds[activeTiles[i, 2], 4];
		var page = l.texpages[l.texpageIds[? texOffset], 10];
		var texX = l.texpages[l.texpageIds[? texOffset], 0];
		var texY = l.texpages[l.texpageIds[? texOffset], 1];
		var roX = l.texpages[l.texpageIds[? texOffset], 4];
		var roY = l.texpages[l.texpageIds[? texOffset], 5];	
		draw_sprite_part_ext(l.spritesheets[page],0,texX+activeTiles[i, 3],texY+activeTiles[i, 4],activeTiles[i, 5],activeTiles[i, 6],activeTiles[i, 0]+roX,activeTiles[i, 1]+roY,activeTiles[i, 9],activeTiles[i, 10],c_white,1);
	}
}

// Draw objects
if(drawObjects)
for(var i = 0; i < array_height_2d(activeObjects); i++){
	if(activeObjects[i, 2] < 0 || activeObjects[i, 2] > 100000)
		continue;
	if(l.objects[activeObjects[i, 2], 1] == -1 || l.objects[activeObjects[i, 2], 1] > 100000)
		continue;
	var texOffsets = l.sprites[l.objects[activeObjects[i, 2], 1], 12];
	var page = l.texpages[l.texpageIds[? texOffsets[0]], 10];
	var texX = l.texpages[l.texpageIds[? texOffsets[0]], 0];
	var texY = l.texpages[l.texpageIds[? texOffsets[0]], 1];
	var texW = l.texpages[l.texpageIds[? texOffsets[0]], 2];
	var texH = l.texpages[l.texpageIds[? texOffsets[0]], 3];
	var roX = l.texpages[l.texpageIds[? texOffsets[0]], 4];
	var roY = l.texpages[l.texpageIds[? texOffsets[0]], 5];
	
	draw_sprite_part_ext(l.spritesheets[page],0,texX,texY,texW,texH,activeObjects[i, 0]+roX-l.sprites[l.objects[activeObjects[i, 2], 1], 9],activeObjects[i, 1]+roY-l.sprites[l.objects[activeObjects[i, 2], 1], 10],activeObjects[i, 5],activeObjects[i, 6],c_white,1);
}

// Stop drawing to surface
surface_reset_target();

// Draw the surface to the screen, scaled and positioned by the view
draw_surface_ext(surf, -viewX, -viewY, viewscaleW, viewscaleH, 0, c_white, 1);

// If gui is not visible, don't draw it.
if(!uiVisible)
	exit;

// Draw info text
draw_set_font(fnt_text);
var str = "Room: " + l.strings[? l.rooms[currentRoom, 0]] + " " + string(currentRoom + 1) + "/" + string(array_height_2d(l.rooms));
var mult = 1;
mult = (window_get_width() - 20) / string_width(str);
if(mult > 1) mult = 1;
draw_set_color(c_black);
draw_text_transformed(8,8,str,mult,1,0);
draw_set_color(c_white);
draw_text_transformed(5,5,str,mult,1,0);

// Controls
draw_set_font(fnt_text_small);
draw_set_valign(fa_bottom);
draw_set_color(c_black);
draw_text(8,window_get_height() - 5,"Press [C] to toggle UI");
draw_set_color(c_white);
draw_text(7,window_get_height() - 6,"Press [C] to toggle UI");
draw_set_color(c_black);
draw_text(8,window_get_height() - 23,"Arrow keys to translate view");
draw_set_color(c_white);
draw_text(7,window_get_height() - 24,"Arrow keys to translate view");
draw_set_color(c_black);
draw_text(8,window_get_height() - 39,"Hold [X] to speed up movement");
draw_set_color(c_white);
draw_text(7,window_get_height() - 40,"Hold [X] to speed up movement");
draw_set_color(c_black);
draw_text(8,window_get_height() - 55,"Press spacebar to go to next room");
draw_set_color(c_white);
draw_text(7,window_get_height() - 56,"Press spacebar to go to next room");
draw_set_color(c_black);
draw_text(8,window_get_height() - 71,"Press shift to go to previous room");
draw_set_color(c_white);
draw_text(7,window_get_height() - 72,"Press shift to go to previous room");
draw_set_color(c_black);
draw_text(8,window_get_height() - 87,"[O], [T], and [B] disable objects,\ntiles, and background visibility");
draw_set_color(c_white);
draw_text(7,window_get_height() - 88,"[O], [T], and [B] disable objects,\ntiles, and background visibility");
draw_set_color(c_black);
draw_set_halign(fa_right);
draw_text(window_get_width() - 8,window_get_height() - 5,"colinator27 is not responsible for\nany improper use of this program.");
draw_set_color(c_white);
draw_text(window_get_width() - 7,window_get_height() - 6,"colinator27 is not responsible for\nany improper use of this program.");
draw_set_valign(fa_top);
draw_set_halign(fa_left);

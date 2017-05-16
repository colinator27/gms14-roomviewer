/// @description Unpacks data file

strings = ds_map_create(); // After load(), contains every string in the game

nameOffset = 0; // Will store the offset of the game name

constants = undefined; // 2d array of all constants. One item = [0: nameOffset, 1: valueOffset]

// 2d resource arrays
sounds = undefined;
sprites = undefined;
backgrounds = undefined;
paths = undefined; 
scripts = undefined;
fonts = undefined;
objects = undefined;
rooms = undefined;

// Texture page data DS map
texpageIds = ds_map_create();
texpages = undefined;

spritesheets = undefined; // Array of spritesheets (actual registered gamemaker sprites in memory)

loaded = false;

// Loads data from file directly into the above variables
if(load("game.win") == -1){
	log("Failed to read data file.");
	exit;
} else loaded = true;
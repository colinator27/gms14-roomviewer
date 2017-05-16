var f = argument0; // Filename

if(!file_exists(f)){
	log("Error: File " + f + " does not exist.");
	return -1;
}

var buff = buffer_load(f);

var size = buffer_get_size(buff); // Total number of bytes

buffer_seek(buff, buffer_seek_start, 0);

var header = buffer_read_stringlen(buff, 4); // All chunk names are 4 bytes long

// Check if the FORM header exists, if not then exit the loading process.
if(header != "FORM"){
	log("Error: FORM header not found!");
	log("Found the incorrect header of \"" + header + "\"");
	return -1;
} else log("FORM header found.");

// Get the length of the FORM chunk
var FORM_length = buffer_read(buff, buffer_s32);

// Our position relative to the beginning of the FORM chunk
var FORM_pos = 0;

log("FORM header is " + string(FORM_length) + " bytes long.");

log("FORM sub-chunks:");

var spritesheetCount = 0;

// List all available chunks to console
while(FORM_pos < FORM_length){
	var chunkName = buffer_read_stringlen(buff, 4);
	var chunkLength = buffer_read(buff, buffer_s32);
	FORM_pos += 8;
	
	var txt = " - " + chunkName;
	
	if(chunkLength == 4)
		txt += " (empty)";
	
	log(txt);
	
	buffer_seek(buff, buffer_seek_relative, chunkLength);
	FORM_pos += chunkLength;
}

buffer_seek(buff, buffer_seek_start, 8);
FORM_pos = 0;

// Process all chunks within FORM
while(FORM_pos < FORM_length){
	// Get chunk name + length
	var chunkName = buffer_read_stringlen(buff, 4);
	var chunkLength = buffer_read(buff, buffer_s32);
	
	var chunkBegin = buffer_tell(buff); // Relative to start
	var chunkEnd = chunkBegin + chunkLength; // Relative to start
	
	FORM_pos += 8; // chunkName and chunkLength = 8 bytes
	
	// Current position in chunk, doesn't have to be used
	var currentChunkLen = 0;
	
	// If chunk is empty, skip it
	if(chunkLength == 4){
		log("Skipping empty " + chunkName + " chunk");
		buffer_seek(buff, buffer_seek_relative, 4);
		FORM_pos += 4;
		continue;
	}
	
	// Process the chunk
	switch(chunkName){
		case "GEN8":
			var debug = buffer_read(buff, buffer_u8); // boolean
			FORM_pos++;
			currentChunkLen++;
			
			// Skip the odd 24-bit integer
			buffer_seek(buff, buffer_seek_relative, 3);
			FORM_pos += 3;
			currentChunkLen += 3;
			
			var filenameOffset = buffer_read(buff, buffer_u32);
			var configOffset = buffer_read(buff, buffer_u32);
			var lastObj = buffer_read(buff, buffer_u32);
			var lastTile = buffer_read(buff, buffer_u32);
			var gameID = buffer_read(buff, buffer_u32);
			
			FORM_pos += 4*5;
			currentChunkLen += 4*5;
			
			repeat(4){
				buffer_read(buff, buffer_u32);
				FORM_pos += 4;
				currentChunkLen += 4;
			}
			
			var nameOffset = buffer_read(buff, buffer_u32);
			obj_loader.nameOffset = nameOffset;
			var major = buffer_read(buff, buffer_u32);
			var minor = buffer_read(buff, buffer_u32);
			var release = buffer_read(buff, buffer_u32);
			var build = buffer_read(buff, buffer_u32);
			obj_loader.defaultWindowWidth = buffer_read(buff, buffer_u32);
			obj_loader.defaultWindowHeight = buffer_read(buff, buffer_u32);
			var info = buffer_read(buff, buffer_u32);
			
			FORM_pos += 4*8;
			currentChunkLen += 4*8;
			
			// License stuff?
			repeat(16){
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
			}
			buffer_read(buff, buffer_u32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			var timestamp = buffer_read(buff, buffer_u64);
			FORM_pos += 8;
			currentChunkLen += 8;
			
			var displayNameOffset = buffer_read(buff, buffer_u32);
			var activeTargets = buffer_read(buff, buffer_u32);
			repeat(4)
				buffer_read(buff, buffer_u32);
			var steamAppID = buffer_read(buff, buffer_u32);
			var numCount = buffer_read(buff, buffer_u32);
			FORM_pos += 4*8;
			currentChunkLen += 4*8;
			
			var numbers;
			for(var i = 0; i < numCount; i++){
				numbers[i] = buffer_read(buff, buffer_u32);
				FORM_pos += 4;
				currentChunkLen += 4;
			}
			
			break;
		case "OPTN":
			// Mostly unknown data
			repeat(15){
				numbers[i] = buffer_read(buff, buffer_u32);
				FORM_pos += 4;
				currentChunkLen += 4;
			}
			
			// List<Constant>
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor
			var addresses = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
			}
			
			var constants = undefined; // Each has [0: nameOffset, 1: valueOffset]
			
			for(var i = 0; i < addressCount; i++){
				constants[i, 0] = buffer_read(buff, buffer_u32); // nameOffset
				constants[i, 1] = buffer_read(buff, buffer_u32); // valueOffset
				FORM_pos += 8;
				currentChunkLen += 8;
			}
			
			obj_loader.constants = constants;
			
			break;
		case "SOND":
			// Get the List<T> constructor over with
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor
			var addresses = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
			}
			
			// Read in sound data
			for(var i = 0; i < addressCount; i++){
				// Read data
				var nameOffset = buffer_read(buff, buffer_u32);
				var flags = buffer_read(buff, buffer_u32);
				var typeOffset = buffer_read(buff, buffer_u32);
				var fileOffset = buffer_read(buff, buffer_u32);
				buffer_read(buff, buffer_u32);
				var volume = buffer_read(buff, buffer_f32);
				var pitch = buffer_read(buff, buffer_f32);
				var groupID = buffer_read(buff, buffer_s32);
				var audioID = buffer_read(buff, buffer_s32);
				
				// Advance our position
				FORM_pos += 4*9;
				currentChunkLen += 4*9;
				
				// Add sound to array
				obj_loader.sounds[i, 0] = nameOffset;
				obj_loader.sounds[i, 1] = flags;
				obj_loader.sounds[i, 2] = typeOffset;
				obj_loader.sounds[i, 3] = fileOffset;
				obj_loader.sounds[i, 4] = volume;
				obj_loader.sounds[i, 5] = pitch;
				obj_loader.sounds[i, 6] = groupID;
				obj_loader.sounds[i, 7] = audioID;
			}
			
			break;
		case "SPRT":
			// Get the List<T> constructor over with
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor
			
			// Also read in data here because of the
			// strange mask data
			var addresses = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
				
				// Track where to return to
				var resetPos = FORM_pos + 8;
				
				// Go to the address of the sprite
				buffer_seek(buff, buffer_seek_start, addresses[i]);
				
				// Read in data!
				var nameOffset = buffer_read(buff, buffer_u32);
				var width = buffer_read(buff, buffer_u32);
				var height = buffer_read(buff, buffer_u32);
				var left = buffer_read(buff, buffer_u32);
				var right = buffer_read(buff, buffer_u32);
				var bottom = buffer_read(buff, buffer_u32);
				var top = buffer_read(buff, buffer_u32);
				
				// Unknown data
				repeat(3)
					buffer_read(buff, buffer_u32);
					
				var bboxMode = buffer_read(buff, buffer_u32);
				var sepMasks = buffer_read(buff, buffer_u32);
				var originX = buffer_read(buff, buffer_u32);
				var originY = buffer_read(buff, buffer_u32);
				var textureCount = buffer_read(buff, buffer_u32);
				var textureOffsets = undefined;
				for(var j = 0; j < textureCount; j++){
					textureOffsets[j] = buffer_read(buff, buffer_s32);
				}
				
				// Send data to loader
				obj_loader.sprites[i, 0] = nameOffset;
				obj_loader.sprites[i, 1] = width;
				obj_loader.sprites[i, 2] = height;
				obj_loader.sprites[i, 3] = left;
				obj_loader.sprites[i, 4] = right;
				obj_loader.sprites[i, 5] = bottom;
				obj_loader.sprites[i, 6] = top;
				obj_loader.sprites[i, 7] = bboxMode;
				obj_loader.sprites[i, 8] = sepMasks;
				obj_loader.sprites[i, 9] = originX;
				obj_loader.sprites[i, 10] = originY;
				obj_loader.sprites[i, 11] = textureCount;
				obj_loader.sprites[i, 12] = textureOffsets;
				
				// Go back to where we left off before
				buffer_seek(buff, buffer_seek_start, resetPos);
			}
			
			while(currentChunkLen < chunkLength){
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
			}
			
			break;
		case "BGND":
			// Get the List<T> constructor over with
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor + data
			var addresses = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
				
				// Track where to return to
				var resetPos = FORM_pos + 8;
				
				// Go to the address of the background
				buffer_seek(buff, buffer_seek_start, addresses[i]);
				
				// Read in data!
				var nameOffset = buffer_read(buff, buffer_u32);
				var unknown1 = buffer_read(buff, buffer_u32);
				var unknown2 = buffer_read(buff, buffer_u32);
				var unknown3 = buffer_read(buff, buffer_u32);
				var textureOffset = buffer_read(buff, buffer_s32);
				
				// Send data to loader
				obj_loader.backgrounds[i, 0] = nameOffset;
				obj_loader.backgrounds[i, 1] = unknown1;
				obj_loader.backgrounds[i, 2] = unknown2;
				obj_loader.backgrounds[i, 3] = unknown3;
				obj_loader.backgrounds[i, 4] = textureOffset;
				
				// Go back to where we left off before
				buffer_seek(buff, buffer_seek_start, resetPos);
			}
			
			// The rest of the chunk is useless
			while(currentChunkLen < chunkLength){
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
			}
			break;
		case "PATH":
			// Get the List<T> constructor over with
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor + data
			var addresses = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
				
				// Track where to return to
				var resetPos = FORM_pos + 8;
				
				// Go to the address of the path
				buffer_seek(buff, buffer_seek_start, addresses[i]);
				
				// Read in data!
				var nameOffset = buffer_read(buff, buffer_u32);
				var isSmooth = (buffer_read(buff, buffer_s32) != 0);
				var isClosed = (buffer_read(buff, buffer_s32) != 0);
				var precision = buffer_read(buff, buffer_u32);
				//buffer_read(buff, buffer_u8);
				var pointCount = buffer_read(buff, buffer_u32);
				var points = undefined;
				
				// Each point has its own data
				for(var j = 0; j < pointCount; j++){
					points[j, 0] = buffer_read(buff, buffer_f32); // X
					points[j, 1] = buffer_read(buff, buffer_f32); // Y
					points[j, 2] = buffer_read(buff, buffer_f32); // Speed
				}
				
				// Send data to loader
				obj_loader.paths[i, 0] = nameOffset;
				obj_loader.paths[i, 1] = isSmooth;
				obj_loader.paths[i, 2] = isClosed;
				obj_loader.paths[i, 3] = precision;
				obj_loader.paths[i, 4] = pointCount;
				obj_loader.paths[i, 5] = points; // Point[pointCount]: x, y, speed
				
				// Go back to where we left off before
				buffer_seek(buff, buffer_seek_start, resetPos);
			}
			
			// The rest of the chunk is useless
			while(currentChunkLen < chunkLength){
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
			}
			break;
		case "SCPT":
			// Get the List<T> constructor over with
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor + data
			var addresses = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
				
				// Track where to return to
				var resetPos = FORM_pos + 8;
				
				// Go to the address of the script
				buffer_seek(buff, buffer_seek_start, addresses[i]);
				
				// Read in data!
				var nameOffset = buffer_read(buff, buffer_u32);
				var codeId = buffer_read(buff, buffer_u32);
				
				// Send data to loader
				obj_loader.scripts[i, 0] = nameOffset;
				obj_loader.scripts[i, 1] = codeId;
				
				// Go back to where we left off before
				buffer_seek(buff, buffer_seek_start, resetPos);
			}
			
			// The rest of the chunk is useless
			while(currentChunkLen < chunkLength){
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
			}
			break;
		case "FONT":
			// Get the List<T> constructor over with
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor + data
			var addresses = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
				
				// Track where to return to
				var resetPos = FORM_pos + 8;
				
				// Go to the address of the font
				buffer_seek(buff, buffer_seek_start, addresses[i]);
				
				// Read in data!
				var resourceNameOffset = buffer_read(buff, buffer_u32); // Resource tree name
				var systemNameOffset = buffer_read(buff, buffer_u32); // Actual font file name
				var emSize = buffer_read(buff, buffer_u32);
				var bold = (buffer_read(buff, buffer_s32) != 0);
				var italic = (buffer_read(buff, buffer_s32) != 0);
				var rangeStart = buffer_read(buff, buffer_u16);
				var charset = buffer_read(buff, buffer_u8);
				var antialiasing = (buffer_read(buff, buffer_u8) != 0);
				var rangeEnd = buffer_read(buff, buffer_u32); // uint32?
				var textureOffset = buffer_read(buff, buffer_u32);
				var scaleX = buffer_read(buff, buffer_f32);
				var scaleY = buffer_read(buff, buffer_f32);
				
				var characters = undefined;
				
				var fAddressCount = buffer_read(buff, buffer_s32);
				var fAddresses;
				for(var j = 0; j < fAddressCount; j++){
					fAddresses[i] = buffer_read(buff, buffer_s32);
					
					var fResetPos = buffer_tell(buff);
					
					characters[i, 0] = buffer_read(buff, buffer_u16); // Character
					
					// Texture page data
					characters[i, 1] = buffer_read(buff, buffer_u16); // Relative X
					characters[i, 2] = buffer_read(buff, buffer_u16); // Relative Y
					
					// Unknown data is not read here
					
					buffer_seek(buff, buffer_seek_start, fResetPos);
				}
				
				// Send data to loader
				obj_loader.fonts[i, 0] = resourceNameOffset;
				obj_loader.fonts[i, 1] = systemNameOffset;
				obj_loader.fonts[i, 2] = emSize;
				obj_loader.fonts[i, 3] = bold;
				obj_loader.fonts[i, 4] = italic;
				obj_loader.fonts[i, 5] = rangeStart;
				obj_loader.fonts[i, 6] = charset;
				obj_loader.fonts[i, 7] = antialiasing;
				obj_loader.fonts[i, 8] = rangeEnd;
				obj_loader.fonts[i, 9] = textureOffset;
				obj_loader.fonts[i, 10] = scaleX;
				obj_loader.fonts[i, 11] = scaleY;
				obj_loader.fonts[i, 12] = characters;
				
				// Go back to where we left off before
				buffer_seek(buff, buffer_seek_start, resetPos);
			}
			
			// The rest of the chunk is useless
			while(currentChunkLen < chunkLength){
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
			}
			break;
		case "OBJT":
			// Get the List<T> constructor over with
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor + data
			var addresses = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
				
				// Track where to return to
				var resetPos = FORM_pos + 8;
				
				// Go to the address of the object
				buffer_seek(buff, buffer_seek_start, addresses[i]);
				
				// Read in data!
				var nameOffset = buffer_read(buff, buffer_u32);
				var spriteIndex = buffer_read(buff, buffer_u32);
				var _visible = (buffer_read(buff, buffer_s32) != 0);
				var _solid = (buffer_read(buff, buffer_s32) != 0);
				var _depth = buffer_read(buff, buffer_s32);
				var _persistent = (buffer_read(buff, buffer_s32) != 0);
				var parentId = buffer_read(buff, buffer_s32); // -1 = no parent
				var textureMaskId = buffer_read(buff, buffer_s32); // -1 = no mask
				var usesPhysics = (buffer_read(buff, buffer_s32) != 0);
				var isSensor = (buffer_read(buff, buffer_s32) != 0);
				
				// 0 = circle, 1 = box, 2 = custom
				var collisionShape = buffer_read(buff, buffer_u32);
				
				var phyDensity = buffer_read(buff, buffer_f32);
				var phyRestitution = buffer_read(buff, buffer_f32);
				var phyGroup = buffer_read(buff, buffer_f32);
				var phyLinearDamping = buffer_read(buff, buffer_f32);
				var phyAngularDamping = buffer_read(buff, buffer_f32);
				var phyUnknown = buffer_read(buff, buffer_f32);
				var phyFriction = buffer_read(buff, buffer_f32);
				var phyUnknown2 = buffer_read(buff, buffer_f32);
				var phyKinematic = buffer_read(buff, buffer_f32);
				
				// Send data to loader
				obj_loader.objects[i, 0] = nameOffset;
				obj_loader.objects[i, 1] = spriteIndex;
				obj_loader.objects[i, 2] = _visible;
				obj_loader.objects[i, 3] = _solid;
				obj_loader.objects[i, 4] = _depth;
				obj_loader.objects[i, 5] = _persistent;
				obj_loader.objects[i, 6] = parentId;
				obj_loader.objects[i, 7] = textureMaskId;
				obj_loader.objects[i, 8] = usesPhysics;
				obj_loader.objects[i, 9] = isSensor;
				obj_loader.objects[i, 10] = collisionShape;
				obj_loader.objects[i, 11] = phyDensity;
				obj_loader.objects[i, 12] = phyRestitution;
				obj_loader.objects[i, 13] = phyGroup;
				obj_loader.objects[i, 14] = phyLinearDamping;
				obj_loader.objects[i, 15] = phyAngularDamping;
				obj_loader.objects[i, 16] = phyFriction;
				obj_loader.objects[i, 17] = phyKinematic;
				
				// Go back to where we left off before
				buffer_seek(buff, buffer_seek_start, resetPos);
			}
			
			// The rest of the chunk is useless
			while(currentChunkLen < chunkLength){
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
			}
			break;
		case "ROOM":
			// Get the List<T> constructor over with
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor + data
			var addresses = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
				
				// Track where to return to
				var resetPos = FORM_pos + 8;
				
				// Go to the address of the room
				buffer_seek(buff, buffer_seek_start, addresses[i]);
				
				// Read in data!
				var nameOffset = buffer_read(buff, buffer_u32);
				var captionOffset = buffer_read(buff, buffer_u32);
				var width = buffer_read(buff, buffer_u32);
				var height = buffer_read(buff, buffer_u32);
				var roomSpeed = buffer_read(buff, buffer_u32);
				var isPersistent = (buffer_read(buff, buffer_u32) != 0);
				var argb = buffer_read(buff, buffer_u32);
				var drawBackgroundColor = (buffer_read(buff, buffer_u32) != 0);
				var unknown = buffer_read(buff, buffer_u32);
				var flags = buffer_read(buff, buffer_u32); // EnableViews = 1, ShowColour = 2, ClearDisplayBuffer = 4
				
				var bgOffset = buffer_read(buff, buffer_u32);
				var viewOffset = buffer_read(buff, buffer_u32);
				var objOffset = buffer_read(buff, buffer_u32);
				var tileOffset = buffer_read(buff, buffer_u32);
				
				var world = buffer_read(buff, buffer_u32);
				var top = buffer_read(buff, buffer_u32);
				var left = buffer_read(buff, buffer_u32);
				var right = buffer_read(buff, buffer_u32);
				var bottom = buffer_read(buff, buffer_u32);
				var gravityX = buffer_read(buff, buffer_f32);
				var gravityY = buffer_read(buff, buffer_f32);
				var metresPerPixel = buffer_read(buff, buffer_f32);
				
				// Room background data
				buffer_seek(buff, buffer_seek_start, bgOffset);
				var bgAddressCount = buffer_read(buff, buffer_s32);
				var bgAddresses = undefined;
				
				var bgs = undefined;
				
				for(var j = 0; j < bgAddressCount; j++){
					bgAddresses[j] = buffer_read(buff, buffer_s32);
					
					var bgResetPos = buffer_tell(buff);
					
					buffer_seek(buff, buffer_seek_start, bgAddresses[j]);
					
					bgs[j, 0] = (buffer_read(buff, buffer_u32) != 0); // isEnabled
					bgs[j, 1] = (buffer_read(buff, buffer_u32) != 0); // isForeground
					bgs[j, 2] = buffer_read(buff, buffer_u32); // bgDefIndex
					bgs[j, 3] = buffer_read(buff, buffer_s32); // X
					bgs[j, 4] = buffer_read(buff, buffer_s32); // Y
					bgs[j, 5] = (buffer_read(buff, buffer_s32) != 0); // tileX
					bgs[j, 6] = (buffer_read(buff, buffer_s32) != 0); // tileY
					bgs[j, 7] = buffer_read(buff, buffer_s32); // speedX
					bgs[j, 8] = buffer_read(buff, buffer_s32); // speedY
					bgs[j, 9] = (buffer_read(buff, buffer_u32) != 0); // stretch
					
					buffer_seek(buff, buffer_seek_start, bgResetPos);
				}
				
				// Room view data
				buffer_seek(buff, buffer_seek_start, viewOffset);
				var viewAddressCount = buffer_read(buff, buffer_s32);
				var viewAddresses = undefined;
				
				var views = undefined;
				
				for(var j = 0; j < viewAddressCount; j++){
					viewAddresses[j] = buffer_read(buff, buffer_s32);
					
					var viewResetPos = buffer_tell(buff);
					
					buffer_seek(buff, buffer_seek_start, viewAddresses[j]);
					
					views[j, 0] = (buffer_read(buff, buffer_u32) != 0); // isEnabled
					views[j, 1] = buffer_read(buff, buffer_s32); // viewX
					views[j, 2] = buffer_read(buff, buffer_s32); // viewY
					views[j, 3] = buffer_read(buff, buffer_u32); // viewWidth
					views[j, 4] = buffer_read(buff, buffer_u32); // viewHeight
					views[j, 5] = buffer_read(buff, buffer_s32); // portX
					views[j, 6] = buffer_read(buff, buffer_s32); // portY
					views[j, 7] = buffer_read(buff, buffer_u32); // portWidth
					views[j, 8] = buffer_read(buff, buffer_u32); // portHeight
					views[j, 9] = buffer_read(buff, buffer_s32); // borderX
					views[j, 10] = buffer_read(buff, buffer_s32); // borderY
					views[j, 11] = buffer_read(buff, buffer_u32); // speedX
					views[j, 12] = buffer_read(buff, buffer_u32); // speedY
					views[j, 13] = buffer_read(buff, buffer_s32); // objectId (-1 = none)
					
					buffer_seek(buff, buffer_seek_start, viewResetPos);
				}
				
				// Room object data
				buffer_seek(buff, buffer_seek_start, objOffset);
				var objAddressCount = buffer_read(buff, buffer_s32);
				var objAddresses = undefined;
				
				var objs = undefined;
				
				for(var j = 0; j < objAddressCount; j++){
					objAddresses[j] = buffer_read(buff, buffer_s32);
					
					var objResetPos = buffer_tell(buff);
					
					buffer_seek(buff, buffer_seek_start, objAddresses[j]);
					
					objs[j, 0] = buffer_read(buff, buffer_s32); // X
					objs[j, 1] = buffer_read(buff, buffer_s32); // Y
					objs[j, 2] = buffer_read(buff, buffer_u32); // objDefIndex
					objs[j, 3] = buffer_read(buff, buffer_u32); // instanceId
					objs[j, 4] = buffer_read(buff, buffer_u32); // createCodeId (-1 = none)
					objs[j, 5] = buffer_read(buff, buffer_f32); // scaleX
					objs[j, 6] = buffer_read(buff, buffer_f32); // scaleY
					objs[j, 7] = buffer_read(buff, buffer_u32); // argbTint
					objs[j, 8] = buffer_read(buff, buffer_f32); // rotation
					
					buffer_seek(buff, buffer_seek_start, objResetPos);
				}
				
				// Room tile data
				buffer_seek(buff, buffer_seek_start, tileOffset);
				var tileAddressCount = buffer_read(buff, buffer_s32);
				var tileAddresses = undefined;
				
				var tiles = undefined;
				
				for(var j = 0; j < tileAddressCount; j++){
					tileAddresses[j] = buffer_read(buff, buffer_s32);
					
					var tileResetPos = buffer_tell(buff);
					
					buffer_seek(buff, buffer_seek_start, tileAddresses[j]);
					
					tiles[j, 0] = buffer_read(buff, buffer_s32); // X
					tiles[j, 1] = buffer_read(buff, buffer_s32); // Y
					tiles[j, 2] = buffer_read(buff, buffer_u32); // bgDefIndex
					tiles[j, 3] = buffer_read(buff, buffer_s32); // sourceX
					tiles[j, 4] = buffer_read(buff, buffer_s32); // sourceY
					tiles[j, 5] = buffer_read(buff, buffer_u32); // width
					tiles[j, 6] = buffer_read(buff, buffer_u32); // height
					tiles[j, 7] = buffer_read(buff, buffer_s32); // tileDepth
					tiles[j, 8] = buffer_read(buff, buffer_u32); // instanceId
					tiles[j, 9] = buffer_read(buff, buffer_f32); // scaleX
					tiles[j, 10] = buffer_read(buff, buffer_f32); // scaleY
					tiles[j, 11] = buffer_read(buff, buffer_u32); // argbTint
					
					buffer_seek(buff, buffer_seek_start, tileResetPos);
				}
				
				// Send data to loader
				obj_loader.rooms[i, 0] = nameOffset;
				obj_loader.rooms[i, 1] = captionOffset;
				obj_loader.rooms[i, 2] = width;
				obj_loader.rooms[i, 3] = height;
				obj_loader.rooms[i, 4] = roomSpeed;
				obj_loader.rooms[i, 5] = isPersistent;
				obj_loader.rooms[i, 6] = argb;
				obj_loader.rooms[i, 7] = drawBackgroundColor;
				obj_loader.rooms[i, 8] = flags; // For more info, look above, where "flags" is set
				obj_loader.rooms[i, 9] = world;
				obj_loader.rooms[i, 10] = top;
				obj_loader.rooms[i, 11] = left;
				obj_loader.rooms[i, 12] = right;
				obj_loader.rooms[i, 13] = bottom;
				obj_loader.rooms[i, 14] = gravityX;
				obj_loader.rooms[i, 15] = gravityY;
				obj_loader.rooms[i, 16] = metresPerPixel;
				// 2d arrays of content
				obj_loader.rooms[i, 17] = bgs;
				obj_loader.rooms[i, 18] = views;
				obj_loader.rooms[i, 19] = objs;
				obj_loader.rooms[i, 20] = tiles;
				
				// Go back to where we left off before
				buffer_seek(buff, buffer_seek_start, resetPos);
			}
			
			// The rest of the chunk is useless
			while(currentChunkLen < chunkLength){
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
			}
			break;
		case "STRG":
			// Get the List<T> constructor over with
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor
			var addresses = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
			}
			
			// Time to read in the strings
			for(var i = 0; i < addressCount; i++){
				// Get string length
				var len = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
				
				var strpos = buffer_tell(buff);
				
				// Read in string with length
				var val = buffer_read_stringlen(buff, len);
				FORM_pos += len;
				currentChunkLen += len;
				
				// Read an extra byte
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
				
				// Add string to string map
				obj_loader.strings[? strpos] = val;
			}
			// The rest of the chunk is useless zeros. Pass through it.
			while(currentChunkLen < chunkLength){
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
			}
			break;
		case "TPAG":
			// Get the List<T> constructor over with
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor + data
			var addresses = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
				
				// Track where to return to
				var resetPos = FORM_pos + 8;
				
				// Go to the address of the script
				buffer_seek(buff, buffer_seek_start, addresses[i]);
				
				// Because other places reference this by offset,
				// make sure to track this for much easier use
				texpageIds[? buffer_tell(buff)] = i;
				
				// Read in data!
				var X = buffer_read(buff, buffer_u16);
				var Y = buffer_read(buff, buffer_u16);
				var width = buffer_read(buff, buffer_u16);
				var height = buffer_read(buff, buffer_u16);
				var renderOffsetX = buffer_read(buff, buffer_s16);
				var renderOffsetY = buffer_read(buff, buffer_s16);
				var boundingX = buffer_read(buff, buffer_u16);
				var boundingY = buffer_read(buff, buffer_u16);
				var boundingWidth = buffer_read(buff, buffer_u16);
				var boundingHeight = buffer_read(buff, buffer_u16);
				var spritesheetId = buffer_read(buff, buffer_u16);
				
				// Send data to loader
				obj_loader.texpages[i, 0] = X;
				obj_loader.texpages[i, 1] = Y;
				obj_loader.texpages[i, 2] = width;
				obj_loader.texpages[i, 3] = height;
				obj_loader.texpages[i, 4] = renderOffsetX;
				obj_loader.texpages[i, 5] = renderOffsetY;
				obj_loader.texpages[i, 6] = boundingX;
				obj_loader.texpages[i, 7] = boundingY;
				obj_loader.texpages[i, 8] = boundingWidth;
				obj_loader.texpages[i, 9] = boundingHeight;
				obj_loader.texpages[i, 10] = spritesheetId;
				
				// Go back to where we left off before
				buffer_seek(buff, buffer_seek_start, resetPos);
			}
			
			// The rest of the chunk is useless
			while(currentChunkLen < chunkLength){
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
			}
			break;
		case "TXTR":
			// Get the List<T> constructor over with
			
			// This is the list "Count" integer
			var addressCount = buffer_read(buff, buffer_s32);
			FORM_pos += 4;
			currentChunkLen += 4;
			
			// The rest of the List<T> constructor + data
			var addresses = undefined;
			var offsets = undefined;
			for(var i = 0; i < addressCount; i++){
				addresses[i] = buffer_read(buff, buffer_s32);
				FORM_pos += 4;
				currentChunkLen += 4;
				
				// Track where to return to
				var resetPos = FORM_pos + 8;
				
				// Go to the address of the script
				buffer_seek(buff, buffer_seek_start, addresses[i]);
				
				// Read in data!
				buffer_read(buff, buffer_u32); // unknown
				offsets[i] = buffer_read(buff, buffer_u32);
				
				// Go back to where we left off before
				buffer_seek(buff, buffer_seek_start, resetPos);
			}
			
			var returnTo = buffer_tell(buff);
			
			if(is_array(offsets)){
				spritesheetCount = array_length_1d(offsets);
				for(var i = 0; i < array_length_1d(offsets); i++){
					buffer_seek(buff, buffer_seek_start, offsets[i]);
				
					// Get the PNG file length
					var readLen = 0;
					if(i != array_length_1d(offsets) - 1)
						readLen = offsets[i + 1] - offsets[i];
					else
						readLen = chunkEnd - offsets[i];
				
					// Initialize export file buffer
					var exportBuffer = buffer_create(readLen, buffer_grow, 1);
				
					// Write PNG data to export file
					for(var j = 0; j < readLen; j++)
						buffer_write(exportBuffer, buffer_u8, buffer_read(buff, buffer_u8));
					
					// Save file
					buffer_save(exportBuffer, working_directory + "texture_" + string(i) + ".png");
				
					// Clear up memory
					buffer_delete(exportBuffer);
				}
			}
			
			buffer_seek(buff, buffer_seek_start, returnTo);
			
			// The rest of the chunk is useless
			while(currentChunkLen < chunkLength){
				buffer_read(buff, buffer_u8);
				FORM_pos++;
				currentChunkLen++;
			}
			break;
		default: // Handling chunks which we don't read
			log("Passing through " + chunkName + " chunk");
			buffer_seek(buff, buffer_seek_relative, chunkLength);
			FORM_pos += chunkLength;
			continue;
	}
	log("Read " + chunkName + " chunk");
}

// Clear out memory used by buffer
buffer_delete(buff);

// Load spritesheets
for(var i = 0; i < spritesheetCount; i++){
	obj_loader.spritesheets[i] = sprite_add(working_directory + "texture_" + string(i) + ".png", 1, false, false, 0, 0);
}

// Exit code 0 - no errors
return 0;
///buffer_read_stringlen(buffer, length)

var buffer = argument0;
var length = argument1;

var str = "";

for(var i = 0; i < length; i++){
	str += ansi_char(buffer_read(buffer, buffer_u8));
}

return str;
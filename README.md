# gms14-roomviewer
A room viewer and unpacker/decompiler for Gamemaker: Studio 1.4 games. Written in GMS 2, and ported to GM:S 1.4 for those who don't want to pay to run it.

## Usage
To begin using this program, download the source and open up one of the project files in its respective program.

*Note: The Studio 1.4 port only went through light testing, and therefore may have more bugs than the Studio 2 version.*

After opening either project, follow these steps:
- Find the game you want to view the rooms of. An EXE file should work. If it isn't stored as an EXE file, but as multiple (or many) in a folder, then don't follow the next step.
- Extract the EXE file to a folder with a program such as 7-Zip.
- Search for a "data.win" file, or any "data" file in the folder.
- If no data files are found, it's likely that the game uses the YoYoCompiler and the decompiler won't work. Don't continue if you don't have a data file.
- Temporarily rename the data file to "game.win"
- Add the "game.win" file we just renamed as an included file in the project.
- After the file is added as an included file, you should change its name back to what it was previously.
- Run the project!

## What does this project actually do?
This project, ironically written in GML, decompiles/unpacks Gamemaker: Studio 1.4 games and then opens up a room viewer. The room viewer allows you to move the view in the room, change rooms, and toggle visibility of layers (objects, tiles, and backgrounds). This program makes it much easier to view the rooms (maybe secret ones...?) of a Gamemaker game. Most other decompilers and unpackers only spit out a whole lot of human-uninterpretable numbers and strings for rooms. However, this, being made in Gamemaker, renders the unpacked rooms' contents to the game window.

## Any issues?
If you run into any issues with running the project, please create an issue (here on GitHub). It would be very helpful if you included the log/console output, as well as any possible "fatal error" messages.

If it seems to take a while for the game to appear, check the console for anything going on. Most of the time, it's just that the game is large and the program is taking a while to unpack it.

## References
Here are the main pages I looked at to write this, and if you're interested in writing your own unpacker or decompiler, check them out!
http://undertale.rawr.ws/unpacking
http://undertale.rawr.ws/decompilation
https://gitlab.com/snippets/14944
https://gitlab.com/snippets/14943
https://github.com/kvanberendonck/acolyte/wiki/Bytecode

*If any of these happen to go down, I've made sure that they are backed up on the Wayback Machine (archive.org).*

You should keep in mind that some of these pages reference information on another, so sometimes you may need to switch between pages to fully understand a concept.

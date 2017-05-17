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

## Any issues?
If you run into any issues with running the project, please create an issue (here on GitHub). It would be very helpful if you included the log/console output, as well as any possible "fatal error" messages.

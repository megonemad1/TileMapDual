# TileMapDual

Introducing *TileMapDual*: a simple, automatic and straightforward custom `TileMapLayer` node for [Godot](https://github.com/godotengine/godot) that provides a real-time, in-editor and in-game dual-grid tileset system, for both **square** and **isometric** grids.  

This dual-grid system, [as explained by Oskar Stålberg](https://x.com/OskSta/status/1448248658865049605), reduces the number of tiles required from 47 to just 15 (yes, fifteen!!), rocketing your dev journey!  

![](docs/demo_jess.gif)  

Not only that, but if your tiles are symmetrical, you can get away with drawing only 6 (six!) tiles and then generating the 15-tile-tilesets used by *TileMapDual*, thanks to tools like [Wang Tile Set Creator](https://github.com/kleingeist37/godot-wang-converter).  

![](docs/reference_dual.jpeg)  

All grids are supported by TileMapDual. Square, isometric, hex... The only limit is your imagination!  

![](docs/demo_iso.gif)  


## Advantages

Using a dual-grid system has the following advantages:  
- Only [15](https://user-images.githubusercontent.com/47016402/87044518-ee28fa80-c1f6-11ea-86f5-de53e86fcbb6.png) tiles are required for autotiling, instead of [47](https://user-images.githubusercontent.com/47016402/87044533-f5e89f00-c1f6-11ea-9178-67b2e357ee8a.png)
- The tiles can have perfectly rounded corners
- The tiles align to the world grid
- All grids are supported: square, hex, isometric...


## Installation

TileMapDual is installed as a regular Godot plugin.
Just copy the `addons/TileMapDual` folder to your Godot project, and enable it on *Project*, *Project settings...*, *Plugins*.  


## Usage

TileMapDual is loaded in the same way as a regular `TileMapLayer` node.
You have to create a `TileMapDual` node with your own tileset, and set it up with the appropriate tile shape and orientation, etc.

![](docs/setup.gif)


You can now start sketching your level with the fully-filled tile, indicated below for a square grid.
You can also sketch with the empty tile in the bottom-left corner, or erase tiles as usual. The dual grid will update in real time as you draw! 

![](docs/reference_tileset_standard.png)

You can find several example scenes for all kinds of grids in the `examples/` folder.


### Isometric tilesets

To use isometric tilemaps, all you need to do is follow an isometric-ed version of the [standard godot tileset](https://user-images.githubusercontent.com/47016402/87044518-ee28fa80-c1f6-11ea-86f5-de53e86fcbb6.png) template that we previously used for square tilemaps, as shown in the image below:  

![](docs/reference_tileset_isometric.svg)  

This isometric tileset can be drawn by hand.
But it can also be drawn more easily using a tool like [TileCropper](https://github.com/pablogila/TileCropper), a Godot plugin that allows you to draw the tiles in one continuous image, to later separate the tiles as follows:  

![](docs/reference_tilecropper.png)  


### Hex, half-displaced grids, etc

Check the first video on [FAQ and Troubleshoot](#faq-and-troubleshoot) to see how to configure all kinds of grids.


### Multiple terrains

To use more than two terrain types, it is highly encouraged to use multiple TileMapDual layers:

![](docs/multiple_layers.gif)


### Hitboxes

To include extra data like hitboxes, pathing and such to your TileSet, it is recommended to use 2 separate spritesheets:
- one for displaying the tiles ("display tiles")
- one for program logic ("world tiles")

Here's how to set it up:

![](docs/custom_drawing_sprites.gif)


### TileMapDual Legacy (stable version)

The TileMapDual v5 release was a full rewritte. If you encounter issues, please report them on GitHub. For the time being, and to make the transition from v4 to v5 smoother, a custom `TileMapDualLegacy` node is available within the v5 version, containing the stable version from [v4.0.3](https://github.com/pablogila/TileMapDual/tree/v4.0.3).

Not ethat the legacy version only supports square and isometric grids. On the contrary, support for material shaders is fully implemented, and the performance is currently better fthan for the v5 version. Once these issues are solved, the legacy version will be removed.


## Why?

This release simplifies the implementation of a dual-grid system by introducing a simple **custom node** that runs **automatically** and **in-editor**, making it easy to integrate into your own projects.  

Previous implementations of a dual-grid tileset system in Godot, mainly by
[jess::codes](https://github.com/jess-hammer/dual-grid-tilemap-system-godot) and
[GlitchedInOrbit](https://github.com/GlitchedinOrbit/dual-grid-tilemap-system-godot-gdscript),
were not automatic and required extensive manual configuration (at the time of writing).
These implementations also used an inverted version of the [standard 16-tile template](https://user-images.githubusercontent.com/47016402/87044518-ee28fa80-c1f6-11ea-86f5-de53e86fcbb6.png) (although Jess's tileset is provided as an example in this repo).
This is a potential source of headaches, and this release corrects said inversion.  

This release also implements modern **TileMapLayers** instead of the deprecated TileMap node.  

Plus, you can use **multiple atlases** in the same tileset.  

Oh, and also... You can use **all kinds of grids!** Square, isometric, hex grids... All of them are supported!  


## License

This project is Open Source Software, released under the [MIT license](LICENSE). This basically means that you can do whatever you want with it. Enjoy!  


## Contributing

[This repo](https://https://github.com/pablogila/TileMapDual_godot_node/) is open to pull requests, just make sure to check the [contributing guidelines](CONTRIBUTING.md).
We personally encourage you to send back any significant improvements to this code so that the Godot community continues to thrive. Thanks!  

More about how TileMapDual v5 works under the hood on the [v5 discussion issue](https://github.com/pablogila/TileMapDual/issues/16).


## FAQ and Troubleshoot

This plugin supports all the different tile shapes, layouts, and offset axes.
Here's a rundown of all of them, with common mistakes and their corresponding fix:

![](docs/all_shapes_and_common_mistakes.gif)


You can then put hitboxes on the display tiles and logic such as pathing on the logical tiles.
If your spritesheet doesn't follow the standard preset layout, you can manually set its terrains.
Here is how to set up a Hexagonal Vertical tileset:

![](docs/manual_hexagonal_terrain_setup.gif)


You can safely switch to a different tileset if you need to:

![](docs/change_tilesets.gif)


You can use multiple atlases in the same TileSet, with a few quirks if you don't set up the terrains properly:

![](docs/multiple_atlases_conflict.gif)


In case you make mistakes, you can edit the terrain configuration and see the results in real-time:

![](docs/terrain_setup_live_feedback.gif)


Some additional notes:
- Terrain autogeneration does not work if you are editing a TileSet by itself from the assets folder. You must put it in a TileMapDual first.
- It currently does not support alternative tiles.


## References

- [Dual grid Twitter post by Oskar Stålberg](https://x.com/OskSta/status/1448248658865049605)
- ['Programming Terrain Generation' video by ThinMatrix](https://www.youtube.com/watch?v=buKQjkad2I0)
- ['Drawing Fewer Tiles' video by jess::codes](https://www.youtube.com/watch?v=jEWFSv3ivTg)
- [jess::codes implementation in C#](https://github.com/jess-hammer/dual-grid-tilemap-system-godot)
- [GlitchedInOrbit implementation in GDScript](https://github.com/GlitchedinOrbit/dual-grid-tilemap-system-godot-gdscript)
- [Wang Tile Set Creator](https://github.com/kleingeist37/godot-wang-converter)
- [Webtyler tool, to convert from 15-tile sets to 47-tile sets](https://wareya.github.io/webtyler/)
- Credits for [snowflake svg](https://pixsector.com/icon/free-snowflake-svg-vectorart/967) and [water svg](https://www.svgrepo.com/svg/103674/water-drop)


## Feedback

Please feel free to contact us to provide feedback, suggestions, or improvements to this project. You may also check the the [contributing guidelines](CONTRIBUTING.md) to submit an issue or a pull request  :D  

- [Twitter (@GilaPixel)](https://x.com/gilapixel)
- [YouTube (@GilaPixel)](https://www.youtube.com/@gilapixel)
- [Instagram (@GilaPixel)](https://www.instagram.com/gilapixel/)
- [Mastodon (@GilaPixel)](https://mastodon.gamedev.place/@GilaPixel)
- [Reddit (/u/pgilah)](https://www.reddit.com/u/pgilah/)


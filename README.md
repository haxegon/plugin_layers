# Layers (version 0.1.0 (2018-02-21))
### A plugin for Haxegon: http://www.haxegon.com

**Layers** is a simplified display list for Haxegon! It allows you to create and destroy graphical layers on the fly.

With the **Layers** plugin, you can:
 - Attach images to the canvas which are drawn every frame.
 - Remove them when you no longer want them.
 - Move, rotate, and scale layers independently.
 - Easily apply movement, rotation and scaling to the screen layer - useful for e.g. screenshake effects.

**Layers** is very lightweight, and has no dependancies on other libraries or plugins.

## Setup

To install the **Layers** plugin, <a href="https://raw.githubusercontent.com/haxegon/plugin_layers/master/plugins/Layer.hx">download this Layers.hx file</a>, and copy it into your own project's plugins folder.

# Usage

Here is a simple example:

``` haxe
import haxegon.*;

class Main {
  function init(){
    Layer.create("foreground");
  }
  
  function update(){
    if (Mouse.leftheld()){
      Layer.drawto("foreground");
      Gfx.fillcircle(Mouse.x, Mouse.y, Random.float(10, 15), Col.WHITE, 0.75);
      Gfx.drawtoscreen();
    }
    
    if (Input.pressed(Key.SPACE)){
      //Rotate the layer 1 degree
      Layer.rotate("foreground", Layer.getrotation("foreground") + 1, Gfx.CENTER, Gfx.CENTER);
    }
  }
}
```

See <a href="https://github.com/haxegon/plugin_layers/tree/master/examples">the examples folder</a> for more examples. 

## Documentation

See <a href="https://github.com/haxegon/plugin_layers/tree/master/documentation">the documentation folder</a> for complete documentation.

## About Layers

*version*: 0.1.0

*dependancies*: Haxegon 0.12.0 or newer.

*Targets*: **Layers** works on all current Haxegon targets - Native, HTML5 and Flash.

*Author*: @terrycavanagh

## About Haxegon

**Layers** is a plugin for Haxegon. For more plugins, see http://www.haxegon.com/plugins/

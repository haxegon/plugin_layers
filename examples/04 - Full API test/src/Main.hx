import haxegon.*;

class Main {
	function init(){
		//We use the entire screen, and set the font size to 3 times bigger
		Gfx.resizescreen(0, 0);
		Text.size = 3;
		
		//Create a layer called "paintinglayer" and attach it
		Layer.create("paintinglayer");
		Layer.attach("paintinglayer");
		
		//Create a layer called "foreground" and attach it
		Layer.create("foreground");
		Layer.attach("foreground");
		
		//Create a layer called "textlayer" and attach it
		Layer.create("textlayer");
		Layer.attach("textlayer");
		
		//Let's display some instructions on the textlayer
		Layer.drawto("textlayer");
		var ypos:Int = 0;
		Gfx.fillbox(0, 0, Gfx.screenwidth, Text.height() + 4, Col.BLACK);
		Text.display(0, ypos, "Attached layers: " + Std.string(Layer.getlayers()));
		Text.display(0, ypos+=30, "1 (attach) / 2 (detach): textlayer");
		Text.display(0, ypos+=30, "Q (attach) / W (detach): paintinglayer");
		Text.display(0, ypos+=30, "A (attach) / S (detach): foreground");
		Text.display(0, ypos+=30, "Z (attach) / X (detach): screen");
		
		ypos += 30;
		Text.display(0, ypos += 30, "Left mouse: Paint on \"paintinglayer\" layer");
		Text.display(0, ypos += 30, "Right mouse: Paint on \"foreground\" layer");
		Text.display(0, ypos += 30, "Middle mouse: Clear layers (open issues with 0.12.0, sorry)");
		
		ypos += 30;
		Text.display(0, ypos+=30, "Arrow keys: Move paintinglayer layer");
		Text.display(0, ypos+=30, "Shift + Arrows: Rotate and scale paintinglayer");
		Text.display(0, ypos+=30, "Ctrl + Arrows: Adjust paintinglayer x/y scale");
		Text.display(0, ypos += 30, "M + Left/Right: Adjust paintinglayer alpha");
		Text.display(0, ypos += 30, "N + Left/Right: Adjust foreground alpha");
		Gfx.drawtoscreen();
	}
	
	function update() {
		//have the background colour gently cycle to show that it's seperate
		Gfx.clearscreen(Col.hsl(Core.time * 5, 0.25, 0.25));
		
		//The top line of "textlayer" changes when we attach and detach layers, so redraw it
		Layer.drawto("textlayer");
		Gfx.fillbox(0, 0, Gfx.screenwidth, Text.height() + 4, Col.BLACK);
		Text.display(0, 0, "Attached layers: " + Std.string(Layer.getlayers()));
		Gfx.drawtoscreen();
		
		if (Mouse.leftheld()){
			//If you left click, draw circles on the "paintinglayer".
			Layer.drawto("paintinglayer");
			Gfx.fillcircle(Mouse.x, Mouse.y, Random.float(50, 80), Col.hsl((Core.time * 30), 0.5, 0.5), 0.5);
			Gfx.drawtoscreen();
		} else if (Mouse.rightheld()){
			//If you right click, draw a stripe, randomly horizontally or vertically
			Layer.drawto("foreground");
			if (Random.bool()){
				//Vertical
				Gfx.fillbox(Mouse.x - 10, 0, 20, Gfx.screenheight, Col.hsl(180 + (Core.time * 30), 0.5, 0.5), 0.25);
			}else{
				//Horizontal
				Gfx.fillbox(0, Mouse.y - 10, Gfx.screenwidth, 20, Col.hsl(180 + (Core.time * 30), 0.5, 0.5), 0.25);
			}
			Gfx.drawtoscreen();
		} else if (Mouse.middleclick()){
			//If you middle click, clear the layers. (This is currenty broken on HTML5, sorry)
			Layer.drawto("paintinglayer");
			Gfx.clearscreen(Col.TRANSPARENT);
			Layer.drawto("foreground");
			Gfx.clearscreen(Col.TRANSPARENT);
			Gfx.drawtoscreen();
		}
		
		//1/2 attach and detach the "textlayer"
		if (Input.justpressed(Key.ONE)){
			Layer.attach("textlayer");
		}else if (Input.justpressed(Key.TWO)){
			Layer.detach("textlayer");
		}
		
		//W/Q attach and detach the "paintinglayer"
		if (Input.justpressed(Key.W)){
			Layer.detach("paintinglayer");
		}else if (Input.justpressed(Key.Q)){
			Layer.attach("paintinglayer");
		}
		
		//S/A attach and detach the "foreground"
		if (Input.justpressed(Key.S)){
			Layer.detach("foreground");
		}else if (Input.justpressed(Key.A)){
			Layer.attach("foreground");
		}
		
		//Z/X attach and detach the actual screen
		if (Input.justpressed(Key.X)){
			Layer.detach("screen");
		}else if (Input.justpressed(Key.Z)){
			//When we reattach the screen, make sure we attach the screen first and everything else afterwards.
			var layerlist:Array<String> = Layer.getlayers();
			Layer.detach();
			Layer.attach("screen");
			for (i in 0 ... layerlist.length){
				if (layerlist[i] != "screen"){
					Layer.attach(layerlist[i]);
				}
			}
		}
		
		if (Input.pressed(Key.N)){
			//Holding N and pressing LEFT and RIGHT adjust the "foreground" alpha.
			if (Input.pressed(Key.LEFT)){
				Layer.alpha("foreground", Geom.clamp(Layer.getalpha("foreground") * 0.95, 0, 1));
			}
			if (Input.pressed(Key.RIGHT)){
				Layer.alpha("foreground", Geom.clamp(0.05 + (Layer.getalpha("foreground") * 1.05), 0, 1));
			} 
		}else if (Input.pressed(Key.M)){
			//Holding M and pressing LEFT and RIGHT adjust the "paintinglayer" alpha.
			if (Input.pressed(Key.LEFT)){
				Layer.alpha("paintinglayer", Geom.clamp(Layer.getalpha("paintinglayer") * 0.95, 0, 1));
			}
			if (Input.pressed(Key.RIGHT)){
				Layer.alpha("paintinglayer", Geom.clamp(0.05 + (Layer.getalpha("paintinglayer") * 1.05), 0, 1));
			} 
		}else	if (Input.pressed(Key.CONTROL)){
			//Holding CONTROL and pressing ARROW KEYS adjust the x/y scale of the "paintinglayer".
			if (Input.pressed(Key.UP)){
				Layer.scaley("paintinglayer", Layer.getscaley("paintinglayer") * 1.1, Gfx.CENTER, Gfx.CENTER);
			}
			if (Input.pressed(Key.DOWN)){
				Layer.scaley("paintinglayer", Layer.getscaley("paintinglayer") * 0.9, Gfx.CENTER, Gfx.CENTER);
			} 
			if (Input.pressed(Key.LEFT)){
				Layer.scalex("paintinglayer", Layer.getscalex("paintinglayer") * 0.9, Gfx.CENTER, Gfx.CENTER);
			}
			if (Input.pressed(Key.RIGHT)){
				Layer.scalex("paintinglayer", Layer.getscalex("paintinglayer") * 1.1, Gfx.CENTER, Gfx.CENTER);
			}
		}else if (Input.pressed(Key.SHIFT)){
			//Holding SHIFT and pressing ARROW KEYS adjust the scale and rotation of the "paintinglayer".
			if (Input.pressed(Key.UP)){
				Layer.scale("paintinglayer", Layer.getscale("paintinglayer") * 1.1, Gfx.CENTER, Gfx.CENTER);
			}
			if (Input.pressed(Key.DOWN)){
				Layer.scale("paintinglayer", Layer.getscale("paintinglayer") * 0.9, Gfx.CENTER, Gfx.CENTER);
			} 
			if (Input.pressed(Key.LEFT)){
				Layer.rotate("paintinglayer", Layer.getrotation("paintinglayer") - 2, Gfx.CENTER, Gfx.CENTER);
			}
			if (Input.pressed(Key.RIGHT)){
				Layer.rotate("paintinglayer", Layer.getrotation("paintinglayer") + 2, Gfx.CENTER, Gfx.CENTER);
			}
		}else{
			//Pressing ARROW KEYS moves the "paintinglayer".
			if (Input.pressed(Key.UP)){
				Layer.move("paintinglayer", Layer.getx("paintinglayer"), Layer.gety("paintinglayer") - 5);
			}
			if (Input.pressed(Key.DOWN)){
				Layer.move("paintinglayer", Layer.getx("paintinglayer"), Layer.gety("paintinglayer") + 5);
			}
			if (Input.pressed(Key.LEFT)){
				Layer.move("paintinglayer", Layer.getx("paintinglayer") - 5, Layer.gety("paintinglayer"));
			}
			if (Input.pressed(Key.RIGHT)){
				Layer.move("paintinglayer", Layer.getx("paintinglayer") + 5, Layer.gety("paintinglayer"));
			}
		}
	}
}
import haxegon.*;

class Main {
  function init(){
    Layer.create("leftside");  Layer.attach("leftside");
		Layer.create("rightside"); Layer.attach("rightside");
		
		Layer.create("textlayer"); Layer.attach("textlayer");
		
		Text.size = 3;
		Layer.drawto("textlayer");
		Text.display(Text.CENTER, Text.TOP + 5, "SPLIT LAYER EXAMPLE");
		Text.display(Text.CENTER, Text.BOTTOM - 15 - Text.height() * 2, "LEFT MOUSE TO DRAW ON LEFT LAYER");
		Text.display(Text.CENTER, Text.BOTTOM - 10 - Text.height(), "RIGHT MOUSE TO DRAW ON RIGHT LAYER");
		Text.display(Text.CENTER, Text.BOTTOM - 5, "PRESS ANY KEY TO SPLIT/JOIN LAYERS");
		Gfx.drawtoscreen();
  }
  
  function update(){
		if (split){
			Gfx.drawline(Gfx.screenwidthmid, 0, Gfx.screenwidthmid, Gfx.screenheight, Col.BLACK);
		}
		
    if (Mouse.leftheld()){
      Layer.drawto("leftside");
			if (split){
				Gfx.fillcircle(Mouse.x * 2, (Mouse.y * 2) - (Gfx.screenwidthmid / 2), Random.float(80, 120), Col.hsl(Core.time * 10, 0.5, 0.5), 0.5);
			}else{
				Gfx.fillcircle(Mouse.x, Mouse.y, Random.float(80, 120), Col.hsl(Core.time * 10, 0.5, 0.5), 0.5);
			}
			Gfx.drawtoscreen();
    }
		
		if (Mouse.rightheld()){
      Layer.drawto("rightside");
			if (split){
				Gfx.fillcircle((Mouse.x * 2) - (Gfx.screenwidth), (Mouse.y * 2) - (Gfx.screenwidthmid / 2), Random.float(60, 90), Col.hsl((Core.time * 10) + 120, 0.5, 0.5), 0.5);
			}else{
				Gfx.fillcircle(Mouse.x, Mouse.y, Random.float(60, 90), Col.hsl((Core.time * 10) + 120, 0.5, 0.5), 0.5);
			}
      
      Gfx.drawtoscreen();
    }
		
		if (Mouse.middleclick() || Input.justpressed(Key.ANY)){
			split = !split;
			if(split){
				Layer.scale("leftside", 0.5, Gfx.LEFT, Gfx.CENTER);
				Layer.scale("rightside", 0.5, Gfx.RIGHT, Gfx.CENTER);
			}else{
				Layer.scale("leftside", 1);
				Layer.scale("rightside", 1);
			}
		}
  }
	
	var split:Bool = false;
	
	
}
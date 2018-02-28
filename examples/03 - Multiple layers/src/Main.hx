import haxegon.*;

class Main {
	//Set this higher to use more layers!
	var numlayers:Int = 5;
	
  function init(){
		//We use the entire screen
		Gfx.resizescreen(0, 0);
		
		//Let's create a bunch of layers and draw some random colourful spots on them
		//(this might take a second or two, depending on the number of layers)
		for (i in 0 ... numlayers){
			//We create the layer
			Layer.create("fog" + i);
			
			//We start drawing to it
			Layer.drawto("fog" + i);
			for (k in 0 ... 250){
				//We draw 250 random circles
				Gfx.fillcircle(
				  Random.int(0, Gfx.screenwidth),  // Random X position
					Random.int(0, Gfx.screenheight), // Random Y position
					Random.float(Gfx.screenheight / 40, Gfx.screenheight / 20),  //Random circle radius
					Col.hsl((360 / numlayers) * i, 0.5, 0.5), //Colour depends on the layer
					Random.float(0.25, 0.75) //Random alpha
				);
			}
			
			//We set the alpha for the layer to 0.4
			Layer.alpha("fog" + i, 0.4);
		}
		
		//Now we resume drawing to the screen
		Gfx.drawtoscreen();
		
		//Then, let's attach all the layers to the canvas
		for (i in 0 ... numlayers){
			Layer.attach("fog" + i);
			//We scale them all in a little bit so that they're oversized
		  Layer.scale("fog" + i, 4);
		}
  }
  
	function update() {
	  //Every frame, we move all the layers around a bit
		for (i in 0 ... numlayers){
			Layer.rotate("fog" + i, (Core.time * i * 0.5), Gfx.CENTER, Gfx.CENTER);
			Layer.move("fog" + i, Gfx.screenwidthmid + Geom.cos(Core.time * i * 10) * 20, Gfx.screenheightmid + Geom.sin(Core.time * i * 15) * 20);
		}
	}
}
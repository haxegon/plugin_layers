import haxegon.*;

class Main {
  function init(){
    //Let's create a layer!
		Layer.create("newlayer");
		//And attach it to the canvas
		Layer.attach("newlayer");
		
		//Let's draw a big hexagon on it!
		Layer.drawto("newlayer");
		Gfx.linethickness = 25;
		Gfx.drawhexagon(Gfx.screenwidthmid, Gfx.screenheightmid, 150, 0, Col.WHITE);
		
		//Now we draw to the screen again
		Gfx.drawtoscreen();
  }
  
	function update() {
	  //Hold down the left mouse button to drag the layer around
		if(Mouse.leftheld()){
			Layer.move("newlayer", Layer.getx("newlayer") + Mouse.deltax, Layer.gety("newlayer") + Mouse.deltay);
		}
	}
}
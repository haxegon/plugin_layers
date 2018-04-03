import haxegon.*;
import haxe.ds.ArraySort;
import starling.core.Starling;
import starling.textures.RenderTexture;
import starling.display.Image;

@:allow(Layer)
private class HaxegonLayer{
	private function new(w:Int, h:Int){
		if (w > -1){
			rendertex = new RenderTexture(w, h, true);
			img = new Image(rendertex);
			img.touchable = false;
			img.scale = 1;
			img.textureSmoothing = "none";
			width = w;
			height = h;
		}
		
		x = 0; y = 0; 
		alpha = 0;
	}
	
	private var rendertex:RenderTexture;
	private var img:Image;
	private var x:Float;
	private var y:Float;
	private var width:Float;
	private var height:Float;
	private var alpha:Float;
}

@:access(haxegon.Core)
@:access(haxegon.Gfx)
class Layer{
	/** Enable the plugin. */
	public static function enable(){
    if(!enabled){
      Core.registerplugin("layers", "0.1.0");
      Core.checkrequirement("layers", "haxegon", "0.12.0");
      
      layerindex = new Map<String, HaxegonLayer>();
      
			screenready = false;
      var screenlayer:HaxegonLayer = new HaxegonLayer(-1, -1);
      screenlayer.rendertex = Gfx.backbuffer;
      screenlayer.img = Gfx.screen;
      screenlayer.width = Gfx.screenwidth;
      screenlayer.height = Gfx.screenheight;
      screenlayer.alpha = 1.0;
			
			if (screenlayer.img != null){
				screenready = true;
			}
      
      layerindex.set("screen", screenlayer);
    }
		enabled = true;
	}
	
	private static function preparescreenlayer(){
		if (!screenready){
			var screenlayer:HaxegonLayer = layerindex.get("screen");
			screenlayer.rendertex = Gfx.backbuffer;
      screenlayer.img = Gfx.screen;
      screenlayer.width = Gfx.screenwidth;
      screenlayer.height = Gfx.screenheight;
      screenlayer.alpha = 1.0;
			
			if (screenlayer.img != null){
				screenready = true;
			}
			
			layerlistdirty = true;
		}
	}
	private static var screenready:Bool = false;
	
	/** Create a new layer.
	 * layername: The name of the layer, as a string.
	 * width/height: Optional width and height - leave blank to make a screen-sized layer. */
	public static function create(layername:String, ?width:Int = 0, ?height:Int = 0){
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			trace("Error in Layer.create(\"" + layername + "\"): Layer \"" + layername + "\" already exists.");
		}else{
			if (width == 0)	width = Gfx.screenwidth;
			if (height == 0) height = Gfx.screenheight;
			
			var newlayer:HaxegonLayer = new HaxegonLayer(width, height);
			layerindex.set(layername, newlayer);
		}
	}
	
	/** Check if a layer is currently attached to the canvas.
	 * layername: The name of the layer to check. */
	public static function attached(layername:String){
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layername == "screen") preparescreenlayer();
		
		if (layerindex.exists(layername)){
			return (Starling.current.stage.getChildIndex(layerindex.get(layername).img) > -1);
		}else{
			trace("Error in Layer.attach(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return false;
	}
	
	/** Attach a layer to the canvas, at the front.
	 * layername: The name of the layer to attach.
	 * x/y: Optional x, y position for the layer - default is 0, 0. */
	public static function attach(layername:String, ?x:Float = 0, ?y:Float = 0){
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layername == "screen") preparescreenlayer();
		
		if (layerindex.exists(layername)){
			if (!attached(layername)){
				Starling.current.stage.addChild(layerindex.get(layername).img);
				if(x != 0 || y != 0){
					layerindex.get(layername).img.x = x;
					layerindex.get(layername).img.y = y;
				}
				layerlistdirty = true;
			}else{
				trace("Error in Layer.attach(\"" + layername + "\"): Layer \"" + layername + "\" is already attached to the canvas.");
			}
		}else{
			trace("Error in Layer.attach(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
	}
	
	/** Detach a layer from the canvas. The layer still exists, and can be reattached again later.
	 * layername: Optional, the name of the layer to detach. Leave blank to detach all layers. */
	public static function detach(?layername:String){
		if (!enabled) enable();
		
		if (layername == null){
			var layerlist:Array<String> = getlayers();
			
			for (i in 0 ... layerlist.length){
				detach(layerlist[i]);
			}
		}else{
			layername = layername.toLowerCase();
			
			if (layername == "screen") preparescreenlayer();
			
			if (layerindex.exists(layername)){
				if(attached(layername)){
					Starling.current.stage.removeChild(layerindex.get(layername).img);
					layerlistdirty = true;
				}else{
					trace("Error in Layer.detach(\"" + layername + "\"): Layer \"" + layername + "\" is already detached.");
				}
			}else{
				trace("Error in Layer.detach(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
			}
		}
	}
	
	/** Get a list of all layers on the canvas, in order from back to front. */
	public static function getlayers():Array<String> {
		preparescreenlayer();
		
		if (layerlistdirty){
			var newlayerlist:Array<Dynamic> = [];
			
			for (l in layerindex.keys()){
				var pos:Int = Starling.current.stage.getChildIndex(layerindex.get(l).img);
				if(pos > -1){
					newlayerlist.push({ layername: l, layerpos: pos });
				}
			}
			
			ArraySort.sort(newlayerlist, function(a, b) {
				if(a.layerpos < b.layerpos) return -1;
				else if(a.layerpos > b.layerpos) return 1;
				else return 0;
			});
			
			layerlist = [];
			
			for (i in 0 ... newlayerlist.length){
				layerlist.push(newlayerlist[i].layername);
			}
			
			layerlistdirty = false;
		}
		
		return layerlist;
	}
	
	/** Specify a layer to draw to. Use Gfx.drawtoscreen(); when finished to draw to the screen again.
	 * layername: The name of the layer to draw to. */
	public static function drawto(layername:String){
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			Gfx.screenshotdirty = true;
			Gfx.endmeshbatch();
			if (Gfx.drawto != null){
				if(Gfx.drawtolocked) Gfx.drawto.bundleunlock();
				Gfx.drawtolocked = false;
			}
			
			Gfx.drawto = layerindex.get(layername).rendertex;
			
			if (Gfx.drawto != null){
				if(!Gfx.drawtolocked) Gfx.drawto.bundlelock();
				Gfx.drawtolocked = true;
			}
		}else{
			trace("Error in Layer.drawto(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
	}
	
	/** Copy a layer to an image. The image must have already been created already.
	 * layername: The name of the layer to copy.
	 * imagename: The name of the image to paste to. 
	 * xoffset/yoffset: Optional image x/y offset. */
	public static function grabimagefromlayer(layername:String, imagename:String, ?xoffset:Float = 0, ?yoffset:Float = 0) {
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			if (!Gfx.imageindex.exists(imagename)) {
				Debug.log("ERROR: In Layer.grabimage, \"" + imagename + "\" does not exist. You need to create an image label first before using this function.");
				return;
			}
			
			//Make sure everything's on the screen before we grab it
			Gfx.endmeshbatch();
			
			Gfx.haxegonimage = Gfx.images[Gfx.imageindex.get(imagename)];
			// Acquire SubTexture and build an Image from it.
			Gfx.promotetorendertarget(Gfx.haxegonimage.contents);
			
			// Copy the old texture to the new RenderTexture
			Gfx.shapematrix.identity();
			Gfx.shapematrix.translate(-xoffset, -yoffset);
			
			cast(Gfx.haxegonimage.contents.texture, RenderTexture).draw(layerindex.get(layername).img, Gfx.shapematrix);
		}else{
			trace("Error in Layer.grabimagefromlayer(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
	}
	
	/** Rotate a layer.
	 * layername: The name of the layer to rotate.
	 * rotation: Number of degrees to rotate the layer.
	 * pivotx/pivoty: Optional. Specify the pivot point to rotate around. Default is top left. Can use Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT and Gfx.RIGHT as shortcuts.*/
	public static function rotate(layername:String, rotation:Float, pivotx:Float = 0, pivoty:Float = 0){
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var layerobj:HaxegonLayer = layerindex.get(layername);
			
			layerobj.img.x -= layerobj.img.pivotX;
			layerobj.img.y -= layerobj.img.pivotY;
			
			if (pivotx == Gfx.LEFT){
				pivotx = 0;
			}else if (pivotx == Gfx.CENTER){
				pivotx = layerobj.width / 2;
			}else if (pivotx == Gfx.RIGHT){
				pivotx = layerobj.width;
			}
			
			if (pivoty == Gfx.TOP){
				pivoty = 0;
			}else if (pivoty == Gfx.CENTER){
				pivoty = layerobj.height / 2;
			}else if (pivoty == Gfx.BOTTOM){
				pivoty = layerobj.height;
			}
			
			layerobj.img.pivotX = pivotx;
			layerobj.img.pivotY = pivoty;
			layerobj.img.x += pivotx;
			layerobj.img.y += pivoty;
			
			layerobj.img.rotation = Geom.toradians(rotation);
		}else{
			trace("Error in Layer.rotate(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
	}
	
	/** Get the current rotation of a layer.
	 * layername: The name of the rotated layer to check. */
	public static function getrotation(layername:String):Float{
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			return Geom.todegrees(layerindex.get(layername).img.rotation);
		}else{
			trace("Error in Layer.getrotation(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return 0;
	}
	
	/** Scale a layer uniformly. To scale X and Y independently, use "scalex" and "scaley" instead.
	 * layername: The name of the layer to scale.
	 * scale: Amount to scale the layer. 1.0 is normal size.
	 * pivotx/pivoty: Optional. Specify the pivot point to scale around. Default is top left. Can use Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT and Gfx.RIGHT as shortcuts.*/
	public static function scale(layername:String, scale:Float, pivotx:Float = 0, pivoty:Float = 0){
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var layerobj:HaxegonLayer = layerindex.get(layername);
			
			layerobj.img.x -= layerobj.img.pivotX;
			layerobj.img.y -= layerobj.img.pivotY;
			
			if (pivotx == Gfx.LEFT){
				pivotx = 0;
			}else if (pivotx == Gfx.CENTER){
				pivotx = layerobj.width / 2;
			}else if (pivotx == Gfx.RIGHT){
				pivotx = layerobj.width;
			}
			
			if (pivoty == Gfx.TOP){
				pivoty = 0;
			}else if (pivoty == Gfx.CENTER){
				pivoty = layerobj.height / 2;
			}else if (pivoty == Gfx.BOTTOM){
				pivoty = layerobj.height;
			}
			
			layerobj.img.pivotX = pivotx;
			layerobj.img.pivotY = pivoty;
			layerobj.img.x += pivotx;
			layerobj.img.y += pivoty;
			
			layerobj.img.scale = scale;
		}else{
			trace("Error in Layer.scale(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
	}
	
	/** Get the current scale of a layer. If X and Y scales are different, this returns the X scale only.
	 * layername: The name of the scaled layer to check. */
	public static function getscale(layername:String):Float{
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			return layerindex.get(layername).img.scale;
		}else{
			trace("Error in Layer.getscale(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return 1;
	}
	
	/** Scale a layer horizontally. To scale uniformly, use "scale" instead.
	 * layername: The name of the layer to scale.
	 * scalex: Amount to scale the layer horizontally. 1.0 is normal size.
	 * pivotx/pivoty: Optional. Specify the pivot point to scale around. Default is top left. Can use Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT and Gfx.RIGHT as shortcuts.*/
	public static function scalex(layername:String, scalex:Float, pivotx:Float = 0, pivoty:Float = 0){
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var layerobj:HaxegonLayer = layerindex.get(layername);
			
			layerobj.img.x -= layerobj.img.pivotX;
			layerobj.img.y -= layerobj.img.pivotY;
			
			if (pivotx == Gfx.LEFT){
				pivotx = 0;
			}else if (pivotx == Gfx.CENTER){
				pivotx = layerobj.width / 2;
			}else if (pivotx == Gfx.RIGHT){
				pivotx = layerobj.width;
			}
			
			if (pivoty == Gfx.TOP){
				pivoty = 0;
			}else if (pivoty == Gfx.CENTER){
				pivoty = layerobj.height / 2;
			}else if (pivoty == Gfx.BOTTOM){
				pivoty = layerobj.height;
			}
			
			layerobj.img.pivotX = pivotx;
			layerobj.img.pivotY = pivoty;
			layerobj.img.x += pivotx;
			layerobj.img.y += pivoty;
			
			layerobj.img.scaleX = scalex;
		}else{
			trace("Error in Layer.scalex(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
	}
	
	/** Get the current horizontal scale of a layer.
	 * layername: The name of the scaled layer to check. */
	public static function getscalex(layername:String):Float{
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			return layerindex.get(layername).img.scaleX;
		}else{
			trace("Error in Layer.getscalex(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return 1;
	}
	
	/** Scale a layer vertically. To scale uniformly, use "scale" instead.
	 * layername: The name of the layer to scale.
	 * scaley: Amount to scale the layer vertically. 1.0 is normal size.
	 * pivotx/pivoty: Optional. Specify the pivot point to scale around. Default is top left. Can use Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT and Gfx.RIGHT as shortcuts.*/
	public static function scaley(layername:String, scaley:Float, pivotx:Float = 0, pivoty:Float = 0){
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var layerobj:HaxegonLayer = layerindex.get(layername);
			
			layerobj.img.x -= layerobj.img.pivotX;
			layerobj.img.y -= layerobj.img.pivotY;
			
			if (pivotx == Gfx.LEFT){
				pivotx = 0;
			}else if (pivotx == Gfx.CENTER){
				pivotx = layerobj.width / 2;
			}else if (pivotx == Gfx.RIGHT){
				pivotx = layerobj.width;
			}
			
			if (pivoty == Gfx.TOP){
				pivoty = 0;
			}else if (pivoty == Gfx.CENTER){
				pivoty = layerobj.height / 2;
			}else if (pivoty == Gfx.BOTTOM){
				pivoty = layerobj.height;
			}
			
			layerobj.img.pivotX = pivotx;
			layerobj.img.pivotY = pivoty;
			layerobj.img.x += pivotx;
			layerobj.img.y += pivoty;
			
			layerobj.img.scaleY = scaley;
		}else{
			trace("Error in Layer.scaley(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
	}
	
	/** Get the current vertical scale of a layer.
	 * layername: The name of the scaled layer to check. */
	public static function getscaley(layername:String):Float{
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			return layerindex.get(layername).img.scaleY;
		}else{
			trace("Error in Layer.getscaley(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return 1;
	}
	
	/** Scale a layer both horizontally and vertically. To scale uniformly, use "scale" instead.
	 * layername: The name of the layer to scale.
	 * scalex: Amount to scale the layer horizontally. 1.0 is normal size.
	 * scaley: Amount to scale the layer vertically. 1.0 is normal size.
	 * pivotx/pivoty: Optional. Specify the pivot point to scale around. Default is top left. Can use Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT and Gfx.RIGHT as shortcuts.*/
	public static function scalexy(layername:String, scalex:Float, scaley:Float, pivotx:Float = 0, pivoty:Float = 0){
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var layerobj:HaxegonLayer = layerindex.get(layername);
			
			layerobj.img.x -= layerobj.img.pivotX;
			layerobj.img.y -= layerobj.img.pivotY;
			
			if (pivotx == Gfx.LEFT){
				pivotx = 0;
			}else if (pivotx == Gfx.CENTER){
				pivotx = layerobj.width / 2;
			}else if (pivotx == Gfx.RIGHT){
				pivotx = layerobj.width;
			}
			
			if (pivoty == Gfx.TOP){
				pivoty = 0;
			}else if (pivoty == Gfx.CENTER){
				pivoty = layerobj.height / 2;
			}else if (pivoty == Gfx.BOTTOM){
				pivoty = layerobj.height;
			}
			
			layerobj.img.pivotX = pivotx;
			layerobj.img.pivotY = pivoty;
			layerobj.img.x += pivotx;
			layerobj.img.y += pivoty;
			
			layerobj.img.scaleX = scalex;
			layerobj.img.scaleY = scaley;
		}else{
			trace("Error in Layer.scalex(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
	}
	
	/** Move a layer to a screen x, y position.
	 * layername: The name of the layer to move.
	 * x/y: New position for the layer.*/
	public static function move(layername:String, x:Float, y:Float){
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var img:Image = layerindex.get(layername).img;
			img.x = x - img.pivotX;
			img.y = y - img.pivotY;
		}else{
			trace("Error in Layer.move(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
	}
	
	/** Get the current x position of a layer.
	 * layername: The name of the layer to check.*/
	public static function getx(layername:String):Float{
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var img:Image = layerindex.get(layername).img;
			return img.x + img.pivotX;
		}else{
			trace("Error in Layer.getx(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return 0;
	}
	
	/** Get the current y position of a layer.
	 * layername: The name of the layer to check. */
	public static function gety(layername:String):Float{
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var img:Image = layerindex.get(layername).img;
			return img.y + img.pivotY;
		}else{
			trace("Error in Layer.gety(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return 0;
	}
	
	/** Get the width of a layer.
	 * layername: The name of the layer to check. */
	public static function width(layername:String):Float{
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var layerobj:HaxegonLayer = layerindex.get(layername);
			return layerobj.width;
		}else{
			trace("Error in Layer.width(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return 0;
	}
	
	/** Get half the width of a layer. Same as width(layername) / 2.
	 * layername: The name of the layer to check. */
	public static function widthmid(layername:String):Float{
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var layerobj:HaxegonLayer = layerindex.get(layername);
			return layerobj.width / 2;
		}else{
			trace("Error in Layer.widthmid(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return 0;
	}
	
	/** Get the height of a layer.
	 * layername: The name of the layer to check. */
	public static function height(layername:String):Float{
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var layerobj:HaxegonLayer = layerindex.get(layername);
			return layerobj.height;
		}else{
			trace("Error in Layer.height(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return 0;
	}
	
	/** Get half the height of a layer. Same as height(layername) / 2.
	 * layername: The name of the layer to check. */
	public static function heightmid(layername:String):Float{
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var layerobj:HaxegonLayer = layerindex.get(layername);
			return layerobj.height / 2;
		}else{
			trace("Error in Layer.heightmid(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return 0;
	}
	
	/** Set the alpha of a layer.
	 * layername: The name of the layer to check. 
	 * alpha: Alpha value of the layer. Leave blank to restore to 1.0. */
	public static function alpha(layername:String, alpha:Float = 1.0){
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var layerobj:HaxegonLayer = layerindex.get(layername);
			layerobj.img.alpha = alpha;
		}else{
			trace("Error in Layer.alpha(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
	}
	
	/** Get the alpha value of a layer.
	 * layername: The name of the layer to check.  */
	public static function getalpha(layername:String):Float{
		if (!enabled) enable();
		layername = layername.toLowerCase();
		
		if (layerindex.exists(layername)){
			var layerobj:HaxegonLayer = layerindex.get(layername);
			return layerobj.img.alpha;
		}else{
			trace("Error in Layer.getalpha(\"" + layername + "\"): Layer \"" + layername + "\" does not exist.");
		}
		
		return 1;
	}
	
	private static var layerindex:Map<String, HaxegonLayer>;
	private static var layerlistdirty:Bool = true;
	private static var layerlist:Array<String>;
	private static var enabled:Bool = false;
}
package ui;

class Transition extends dn.Process {

	var wp : HSprite;
	
	public function new(onTransition:Void->Void, durationIn:Float = 0.5, durationOut:Float = 0.5, color:UInt = 0x000000) {
		super(Main.ME);
		
		createRootInLayers(parent.root, 999);

		wp = Assets.tiles.h_get("whitePixel", root);
		wp.colorize(color);

		onResize();
		
		tw.createS(wp.alpha, 0 > 1, durationIn).onEnd = function () {
			onTransition();
			tw.createS(wp.alpha, 0, durationOut).onEnd = destroy;
		};
	}

	override function onResize() {
		super.onResize();

		wp.scaleX = Const.AUTO_SCALE_TARGET_WID;
		wp.scaleY = Const.AUTO_SCALE_TARGET_HEI;
	}

}
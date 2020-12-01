package screens;

class SplashScreen extends dn.Process {
	
	public var wid(get,never) : Int; inline function get_wid() return Std.int(Const.AUTO_SCALE_TARGET_WID);
	public var hei(get,never) : Int; inline function get_hei() return Std.int(Const.AUTO_SCALE_TARGET_HEI);

	public static var ME : SplashScreen;

	var bg : HSprite;
	var logo : HSprite;
	
	public function new() {
		super(Main.ME);

		ME = this;

		createRoot();

		bg = Assets.tiles.h_get("whitePixel", root);
		bg.colorize(0x393939);

		logo = Assets.tiles.h_get("logoSS", root);
		logo.setScale(0.5);

		onResize();

		delayer.addS(Main.ME.startTitleScreen, 3);
	}

	override function onResize() {
		super.onResize();

		bg.scaleX = wid;
		bg.scaleY = hei;

		logo.setPos(Std.int(wid - (logo.tile.width * logo.scaleX)) >> 1, Std.int(hei - (logo.tile.height * logo.scaleY)) >> 1);
	}
}
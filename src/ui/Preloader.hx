package ui;

class Preloader extends hxd.fmt.pak.Loader {

	var loadingText : h2d.Bitmap;
	var loadingBG : h2d.Bitmap;
	var loadingGauge : h2d.Bitmap;

	var maxProgress = 0.;
	
	public function new(s2d:h2d.Scene, onDone) {
		super(s2d, onDone);

		var bg = new h2d.Interactive(Const.AUTO_SCALE_TARGET_WID, Const.AUTO_SCALE_TARGET_HEI, this);
		bg.backgroundColor = 0xFF191826;
		
		var flow = new h2d.Flow(this);
		flow.layout = Vertical;
		flow.verticalSpacing = 30;
		flow.minWidth = Std.int(bg.width);
		flow.minHeight = Std.int(bg.height);
		flow.horizontalAlign = flow.verticalAlign = Middle;

		loadingText = new h2d.Bitmap(hxd.res.Any.fromBytes("loading/loading.png", haxe.Resource.getBytes("loadingText")).toTile(), flow);

		loadingBG = new h2d.Bitmap(hxd.res.Any.fromBytes("loading/loadingBG.png", haxe.Resource.getBytes("loadingBG")).toTile(), flow);
		loadingGauge = new h2d.Bitmap(hxd.res.Any.fromBytes("loading/loadingGauge.png", haxe.Resource.getBytes("loadingGauge")).toTile(), loadingBG);
		loadingGauge.setPosition(6, 6);

		render();
	}

	override function updateBG(progress:Float) {
		// super.updateBG(progress);

		if (progress > maxProgress)
			maxProgress = progress;

		loadingGauge.scaleX = maxProgress;
	}

	override function render() {
		super.render();

		this.setScale(Math.min(Std.int(Main.ME.engine.width / Const.AUTO_SCALE_TARGET_WID), Std.int(Main.ME.engine.height / Const.AUTO_SCALE_TARGET_HEI)));
	}

}
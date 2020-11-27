package screens;

class TitleScreen extends dn.Process {
	public static var ME : TitleScreen;

	var flow : h2d.Flow;

	var bg : h2d.Bitmap;
	var sb : HSpriteBatch;

	public function new() {
		super(Main.ME);

		ME = this;

		createRoot();

		bg = new h2d.Bitmap(h2d.Tile.fromColor(0x222034));
		root.add(bg, 0);

		sb = new HSpriteBatch(Assets.tiles.tile);
		sb.hasRotationScale = true;
		root.add(sb, 1);

		flow = new h2d.Flow();
		root.add(flow, 2);
		flow.layout = Vertical;
		flow.horizontalAlign = Middle;
		flow.verticalSpacing = 20;

		var title = new h2d.Text(Assets.fontLarge, flow);
		title.text = "MOONSHOT";

		flow.addSpacing(30);

		var startGameBtn = new ui.Button('Game (Bunker)', Main.ME.startGame);
		flow.addChild(startGameBtn);

		// var startManualBtn = new ui.Button('Manual', Main.ME.startManual);
		// flow.addChild(startManualBtn);

		// var startCommBtn = new ui.Button('Comm', Main.ME.startComm);
		// flow.addChild(startCommBtn);

		// var startModulesBtn = new ui.Button('Modules', Main.ME.startModules);
		// flow.addChild(startModulesBtn);

		onResize();
	}

	function spawnStar() {
		var star = Assets.tiles.hbe_getAndPlay(sb, "star", 1, true);
		star.setCenterRatio();
		star.anim.setSpeed(rnd(0.1, 0.5));
		star.setPos(rnd(0, (w() / Const.SCALE)), rnd(0, (h() / Const.SCALE)));
		star.setScale(rnd(1, 5));
	}

	override function onResize() {
		super.onResize();

		root.setScale(Const.SCALE);

		bg.scaleX = (w() / Const.SCALE);
		bg.scaleY = (h() / Const.SCALE);

		flow.reflow();
		flow.setPosition(Std.int((w() / Const.SCALE) - flow.outerWidth) >> 1,
						Std.int((h() / Const.SCALE) - flow.outerHeight) >> 1);
	}

	override function update() {
		super.update();

		// if (hxd.Key.isPressed(hxd.Key.SPACE))
		if (!cd.hasSetS("spawnStar", rnd(0.1, 0.2)))
			spawnStar();
	}
}
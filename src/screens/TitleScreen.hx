package screens;

class TitleScreen extends dn.Process {
	public static var ME : TitleScreen;

	var flow : h2d.Flow;

	var bg : h2d.Bitmap;

	var sb : HSpriteBatch;

	var continueGameBtn : ui.Button;
	var newGameBtn : ui.Button;

	public function new() {
		super(Main.ME);

		ME = this;

		createRoot();

		bg = new h2d.Bitmap(h2d.Tile.fromColor(0x191826));
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

		#if debug
		var debugGameBtn = new ui.DebugButton('Debug', Main.ME.debugGame);
		flow.addChild(debugGameBtn);
		#end

		continueGameBtn = new ui.Button(Lang.t._("Continuer"), function () {
			Main.ME.continueGame();
			continueGameBtn.clickEnable = false;
		});
		flow.addChild(continueGameBtn);

		newGameBtn = new ui.Button(Lang.t._("Nouvelle partie"), function() {
			Main.ME.newGame();
			newGameBtn.clickEnable = false;
		});
		flow.addChild(newGameBtn);

		var frenchLocaBtn = new ui.SpriteButton("btnLocaFR", function () {
			Const.CHANGE_LOCA("fr");
			Boot.ME.reboot();
		});
		flow.addChild(frenchLocaBtn);

		var englishLocaBtn = new ui.SpriteButton("btnLocaEN", function () {
			Const.CHANGE_LOCA("en");
			Boot.ME.reboot();
		});
		flow.addChild(englishLocaBtn);

		onResize();
	}

	function spawnStar() {
		var star = Assets.tiles.hbe_getAndPlay(sb, "star", 1, true);
		star.setCenterRatio();
		star.anim.setSpeed(rnd(0.1, 0.5));
		star.setPos(rnd(0, (Const.AUTO_SCALE_TARGET_WID)), rnd(0, (Const.AUTO_SCALE_TARGET_HEI)));
		star.setScale(rnd(1, 5));
	}

	override function onResize() {
		super.onResize();

		bg.scaleX = Const.AUTO_SCALE_TARGET_WID;
		bg.scaleY = Const.AUTO_SCALE_TARGET_HEI;

		flow.reflow();
		flow.setPosition(Std.int(Const.AUTO_SCALE_TARGET_WID - flow.outerWidth) >> 1,
						Std.int(Const.AUTO_SCALE_TARGET_HEI - flow.outerHeight) >> 1);
	}

	override function update() {
		super.update();

		// if (hxd.Key.isPressed(hxd.Key.SPACE))
		if (!cd.hasSetS("spawnStar", rnd(0.1, 0.2)))
			spawnStar();
	}
}
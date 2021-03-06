package screens;

class TitleScreen extends dn.Process {
	public static var ME : TitleScreen;
	
	public var wid(get, never):Int;		inline function get_wid() return Const.AUTO_SCALE_TARGET_WID;
	public var hei(get, never):Int;		inline function get_hei() return Const.AUTO_SCALE_TARGET_HEI;

	var flow : h2d.Flow;

	var bg : h2d.Bitmap;

	var sb : HSpriteBatch;

	var continueGameBtn : ui.Button;
	var newGameBtn : ui.Button;
	var optionsBtn : ui.Button;

	var frenchLocaBtn : ui.SpriteButton;
	var englishLocaBtn : ui.SpriteButton;

	public static var MUSIC : dn.heaps.Sfx;

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
		flow.layout = Horizontal;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = 100;

		Assets.tiles.h_get("logoGame", flow);

		flow.addSpacing(30);

		var flowBtns = new h2d.Flow(flow);
		flowBtns.horizontalAlign = Middle;
		flowBtns.layout = Vertical;
		flowBtns.verticalSpacing = 10;

		if (Const.PLAYER_DATA.dayId != Data.DayKind.Day_1) {
			continueGameBtn = new ui.Button(Lang.t._("Continuer"), function () {
				Assets.FADE_MUSIC_VOLUME(MUSIC, 0, 0.5);
				Main.ME.continueGame();
				continueGameBtn.clickEnable = false;
			});
			flowBtns.addChild(continueGameBtn);
		}

		newGameBtn = new ui.Button(Lang.t._("Nouvelle partie"), function() {
			Assets.FADE_MUSIC_VOLUME(MUSIC, 0, 0.5);
			Main.ME.newGame();
			newGameBtn.clickEnable = false;
		});
		flowBtns.addChild(newGameBtn);

		optionsBtn = new ui.Button(Lang.t._("Options"), function() {
			new ui.Options();
			optionsBtn.clickEnable = false;
		});
		flowBtns.addChild(optionsBtn);

		#if debug
		var debugGameBtn = new ui.DebugButton('Debug', function() {
			Assets.FADE_MUSIC_VOLUME(MUSIC, 0, 0.5);
			Main.ME.debugGame();
		});
		flowBtns.addChild(debugGameBtn);
		#end

		#if hl
		var quitGame = new ui.Button(Lang.t._("Quitter"), function(){
			new ui.Transition(hxd.System.exit);
		});
		flowBtns.addChild(quitGame);
		#end

		{	// LOCA
			var flowLoca = new h2d.Flow();
			root.add(flowLoca, 3);
			flowLoca.horizontalSpacing = 20;
	
			frenchLocaBtn = new ui.SpriteButton("btnLocaFR", function () {
				new ui.Transition(function () {
					Const.CHANGE_LOCA("fr");
					Boot.ME.reboot();
				});
				frenchLocaBtn.alpha = 1;
				englishLocaBtn.alpha = 0.5;
			});
			flowLoca.addChild(frenchLocaBtn);
	
			englishLocaBtn = new ui.SpriteButton("btnLocaEN", function () {
				new ui.Transition(function () {
					Const.CHANGE_LOCA("en");
					Boot.ME.reboot();
				});
				frenchLocaBtn.alpha = 0.5;
				englishLocaBtn.alpha = 1;
			});
			flowLoca.addChild(englishLocaBtn);
	
			frenchLocaBtn.alpha = Lang.CUR == "fr" ? 1 : 0.5;
			englishLocaBtn.alpha = Lang.CUR == "en" ? 1 : 0.5;
	
			flowLoca.reflow();
			flowLoca.setPosition(Std.int(wid - flowLoca.outerWidth) - 5, Std.int(hei - flowLoca.outerHeight) - 5);
		}

		var logoSS = new ui.SpriteButton("logoSS", ()->hxd.System.openURL("https://snappysloth.itch.io/"));
		root.add(logoSS, 3);
		logoSS.setScale(0.05);
		logoSS.setPosition(5, hei - logoSS.hei * logoSS.scaleY - 5);

		var logoTwitter = new ui.SpriteButton("twitter", ()->hxd.System.openURL("https://twitter.com/Snappy_Sloth"));
		logoTwitter.setScale(0.5);
		root.add(logoTwitter, 3);
		logoTwitter.setPosition(logoSS.x + logoSS.wid * logoSS.scaleX + 5, hei - logoTwitter.hei * logoTwitter.scaleY - 5);

		MUSIC = Assets.CREATE_SOUND(hxd.Res.music.intro, Music_Intro, true, true, true);

		onResize();
	}

	public function enableClick() {
		optionsBtn.clickEnable = true;
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
						Std.int((Const.AUTO_SCALE_TARGET_HEI - flow.outerHeight - 30) >> 1));
						// Std.int((Const.AUTO_SCALE_TARGET_HEI - flow.outerHeight) * 0.4));
	}

	override function onDispose() {
		super.onDispose();

		MUSIC.stop();
		MUSIC = null;
	}

	override function update() {
		super.update();

		// if (hxd.Key.isPressed(hxd.Key.SPACE))
		if (!cd.hasSetS("spawnStar", rnd(0.02, 0.04)))
			spawnStar();
	}
}
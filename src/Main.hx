import Data;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : dn.heaps.Controller;
	public var ca : dn.heaps.Controller.ControllerAccess;

	var mask			: h2d.Mask;

	var blackBands : Array<HSprite> = [];

	public function new(s:h2d.Scene) {
		super();
		ME = this;

		mask = new h2d.Mask(Const.AUTO_SCALE_TARGET_WID, Const.AUTO_SCALE_TARGET_HEI);
		s.addChild(mask);

		createRoot(mask);

		// Engine settings
		hxd.Timer.wantedFPS = Const.FPS;
		engine.backgroundColor = 0xff<<24|0x111133;
		#if( hl && !debug )
		engine.fullScreen = true;
		#end

		// Resources
		#if(hl && debug)
		hxd.Res.initLocal();
		#else
		hxd.Res.initEmbed();
		#end

		Const.INIT();

		// Hot reloading
		#if debug
		hxd.res.Resource.LIVE_UPDATE = true;
		hxd.Res.data.watch(function() {
			delayer.cancelById("cdb");

			delayer.addS("cdb", function() {
				Data.load( hxd.Res.data.entry.getBytes().toString() );
				if( Game.ME!=null )
					Game.ME.onCdbReload();
			}, 0.2);
		});
		#end

		// Assets & data init
		Assets.init();
		new ui.Console(Assets.fontTiny, s);
		@:privateAccess Lang._initDone = false;
		Lang.init(Const.OPTIONS_DATA.LOCA);
		Data.load( hxd.Res.data.entry.getText() );

		// Game controller
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(X, Key.SPACE, Key.F, Key.E);
		controller.bind(A, Key.UP, Key.Z, Key.W);
		controller.bind(B, Key.ENTER, Key.NUMPAD_ENTER);
		controller.bind(SELECT, Key.R);
		controller.bind(START, Key.N);

		for (i in 0...4) {
			var bb = Assets.tiles.h_get("whitePixel", s);
			bb.colorize(0);
			blackBands.push(bb);
		}

		// Start
		// new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.fontMedium);
		// delayer.addF( startGame, 1 );
		#if debug
		// delayer.addF( debugGame, 1 );
		delayer.addF( startTitleScreen, 1 );
		#else
		delayer.addF( showSplashScreen, 1 );
		#end
	}

	public function clean() {
		if (screens.SplashScreen.ME != null) screens.SplashScreen.ME.destroy();
		if (screens.TitleScreen.ME != null) screens.TitleScreen.ME.destroy();
		if (screens.EndDay.ME != null) screens.EndDay.ME.destroy();
		if (screens.EndDemo.ME != null) screens.EndDemo.ME.destroy();
		if (Game.ME != null) Game.ME.destroy();
	}

	public function showSplashScreen() {
		new ui.Transition(function () {
			clean();
			new screens.SplashScreen();
		}, 0);
	}

	public function startTitleScreen() {
		new ui.Transition(function () {
			clean();
			new screens.TitleScreen();
		});
	}

	public function newGame() {
		new ui.Transition(function () {
			clean();
			var game = new Game();

			game.initDay(Data.DayKind.Day_1);
		});
	}

	public function continueGame() {
		new ui.Transition(function () {
			clean();
			var game = new Game();

			game.initDay(Const.PLAYER_DATA.dayId);
		});
	}

	public function showEndDay() {
		new ui.Transition(function () {
			Const.PLAYER_DATA.currentTime += Game.ME.timer;
			var numTaskCompleted = Game.ME.numTaskCompleted;

			clean();

			new screens.EndDay(numTaskCompleted);
		});
	}

	public function showEndDemo() {
		new ui.Transition(function () {
			// Const.PLAYER_DATA.currentTime += Game.ME.timer;

			clean();

			new screens.EndDemo();
		});
	}

	#if debug
	public function debugGame() {
		new ui.Transition(function () {
			clean();
	
			new Game();
		});
	}
	#end

	override public function onResize() {
		super.onResize();

		Const.SCALE = Math.min(Std.int(Main.ME.engine.width / Const.AUTO_SCALE_TARGET_WID), Std.int(Main.ME.engine.height / Const.AUTO_SCALE_TARGET_HEI));
		// Const.SCALE = Math.min(Main.ME.engine.width / Const.AUTO_SCALE_TARGET_WID, Main.ME.engine.height / Const.AUTO_SCALE_TARGET_HEI);

		mask.setScale(Const.SCALE);
		mask.x = Std.int(Main.ME.engine.width - Const.AUTO_SCALE_TARGET_WID * Const.SCALE) >> 1;
		mask.y = Std.int(Main.ME.engine.height - Const.AUTO_SCALE_TARGET_HEI * Const.SCALE) >> 1;

		blackBands[0].scaleX = mask.x;
		blackBands[0].scaleY = Main.ME.engine.height;

		blackBands[1].x = mask.x + Const.AUTO_SCALE_TARGET_WID * Const.SCALE;
		blackBands[1].scaleX = Main.ME.engine.width - blackBands[1].x;
		blackBands[1].scaleY = Main.ME.engine.height;

		blackBands[2].scaleX = Main.ME.engine.width;
		blackBands[2].scaleY = mask.y;

		blackBands[3].scaleX = Main.ME.engine.width;
		blackBands[3].y = mask.y + Const.AUTO_SCALE_TARGET_HEI * Const.SCALE;
		blackBands[3].scaleY = Main.ME.engine.height - blackBands[3].y;

		// Auto scaling
		// if( Const.AUTO_SCALE_TARGET_WID>0 )
		// 	Const.SCALE = M.floor( w()/Const.AUTO_SCALE_TARGET_WID );
		// else if( Const.AUTO_SCALE_TARGET_HEI>0 )
		// 	Const.SCALE = M.floor( h()/Const.AUTO_SCALE_TARGET_HEI );
		// if( Const.AUTO_SCALE_TARGET_WID>0 )
		// 	Const.SCALE = M.ceil( w()/Const.AUTO_SCALE_TARGET_WID );
		// else if( Const.AUTO_SCALE_TARGET_HEI>0 )
		// 	Const.SCALE = M.ceil( h()/Const.AUTO_SCALE_TARGET_HEI );
	}

	override function update() {
		Assets.tiles.tmod = tmod;
		super.update();

		if (Key.isPressed(Key.F11))
			engine.fullScreen = !engine.fullScreen;
	}
}
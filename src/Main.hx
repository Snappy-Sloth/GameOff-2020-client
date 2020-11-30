import Data;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : dn.heaps.Controller;
	public var ca : dn.heaps.Controller.ControllerAccess;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

		createRoot(s);

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

		// Start
		// new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.fontMedium);
		// delayer.addF( startGame, 1 );
		#if debug
		delayer.addF( startTitleScreen, 1 );
		#else
		delayer.addF( showSplashScreen, 1 );
		#end
	}

	public function clean() {
		if (screens.SplashScreen.ME != null) screens.SplashScreen.ME.destroy();
		if (screens.TitleScreen.ME != null) screens.TitleScreen.ME.destroy();
		if (screens.EndDay.ME != null) screens.EndDay.ME.destroy();
		if (Game.ME != null) Game.ME.destroy();
		if (screens.Manual.ME != null) screens.Manual.ME.destroy();
		if (screens.Communication.ME != null) screens.Communication.ME.destroy();
		if (screens.ModuleScreen.ME != null) screens.ModuleScreen.ME.destroy();
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
			clean();
			// var game = new Game();
			new screens.EndDay();

			// game.initDay(Const.PLAYER_DATA.dayId);
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

		// Auto scaling
		if( Const.AUTO_SCALE_TARGET_WID>0 )
			Const.SCALE = M.ceil( w()/Const.AUTO_SCALE_TARGET_WID );
		else if( Const.AUTO_SCALE_TARGET_HEI>0 )
			Const.SCALE = M.ceil( h()/Const.AUTO_SCALE_TARGET_HEI );
	}

	override function update() {
		Assets.tiles.tmod = tmod;
		super.update();

		if (Key.isPressed(Key.F11))
			engine.fullScreen = !engine.fullScreen;
	}
}
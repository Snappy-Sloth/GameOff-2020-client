import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;

	public var ca : dn.heaps.Controller.ControllerAccess;
	public var fx : Fx;
	public var hud : ui.Hud;

	public var manual : screens.Manual;
	public var communication : screens.Communication;
	public var moduleScreen : screens.ModuleScreen;

	public var timer(default, null) : Float;

	public var currentAlert : Null<Data.AlertsKind> = null;

	public var alertIsActive(get, never) : Bool; inline function get_alertIsActive() return currentAlert != null;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		fx = new Fx();
		hud = new ui.Hud();

		manual = new screens.Manual();
		manual.root.visible = false;
		communication = new screens.Communication();
		communication.root.visible = false;
		moduleScreen = new screens.ModuleScreen();
		moduleScreen.root.visible = false;

		Process.resizeAll();
		trace(Lang.t._("Game is ready."));

		showComm();
	}

	public function showManual() {
		if (communication.root.visible) communication.root.visible = false;
		manual.root.visible = true;
	}

	public function showComm() {
		if (manual.root.visible) manual.root.visible = false;
		if (moduleScreen.root.visible) moduleScreen.root.visible = false;
		communication.root.visible = true;
	}

	public function showModules() {
		if (communication.root.visible) communication.root.visible = false;
		moduleScreen.root.visible = true;
	}

	public function onCdbReload() {
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}

	function launchAlert(ak:Data.AlertsKind) {
		moduleScreen.reset();
		currentAlert = ak;
		hud.showTimer();
	}

	public function onError() {
		timer += 10 * Const.FPS;
		hud.redWarning();
	}

	public function stopCurrentAlert() {
		currentAlert = null;
		hud.hideTimer();
	}

	function gc() {}

	override function onDispose() {
		super.onDispose();

		fx.destroy();
		gc();
	}

	override function preUpdate() {
		super.preUpdate();
	}

	override function postUpdate() {
		super.postUpdate();

		gc();
	}

	override function fixedUpdate() {
		super.fixedUpdate();
	}

	override function update() {
		super.update();

		if (alertIsActive)
			timer += tmod;

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( ca.isKeyboardPressed(Key.ESCAPE) )
				if( !cd.hasSetS("exitWarn",3) )
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					hxd.System.exit();
			#end

			// Restart
			if( ca.selectPressed() )
				Main.ME.startGame();

			#if debug
				if (ca.isKeyboardPressed(hxd.Key.F1)) {
					launchAlert(A3);
				}
			#end
		}
	}
}


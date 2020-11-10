import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;
	
	public var wid(get,never) : Int; inline function get_wid() return Std.int(w() / Const.SCALE);
	public var hei(get,never) : Int; inline function get_hei() return Std.int(h() / Const.SCALE);

	public var ca : dn.heaps.Controller.ControllerAccess;
	public var fx : Fx;
	public var hud : ui.Hud;

	public var manual : screens.Manual;
	public var communication : screens.Communication;
	public var moduleScreen : screens.ModuleScreen;

	public var currentScreen : Process;

	public var timer(default, null) : Float;

	// public var currentAlert : Null<Data.AlertsKind> = null;

	public var wrapperScreens(default, null) : h2d.Object;

	public var currentAlerts : Array<Array<TaskData>> = [];
	public var currentTasks : Array<TaskData> = null;

	public var alertIsActive(get, never) : Bool; inline function get_alertIsActive() return currentTasks != null;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		fx = new Fx();
		hud = new ui.Hud();

		wrapperScreens = new h2d.Object(root);

		manual = new screens.Manual();
		manual.root.x = w() / Const.SCALE;
		communication = new screens.Communication();
		moduleScreen = new screens.ModuleScreen();
		moduleScreen.root.x = -w() / Const.SCALE;

		Process.resizeAll();
		trace(Lang.t._("Game is ready."));

		showComm();
	}

	public function showManual() {
		currentScreen = manual;
		tw.createS(wrapperScreens.x, -w() / Const.SCALE, 0.3);
	}

	public function showComm() {
		currentScreen = communication;
		tw.createS(wrapperScreens.x, 0, 0.3);
		hud.hideNewMessage();
	}

	public function showModules() {
		currentScreen = moduleScreen;
		tw.createS(wrapperScreens.x, w() / Const.SCALE, 0.3);
	}

	public function onCdbReload() {
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}

	function nextAlert() {
		currentAlerts = [];
		currentTasks = null;

		for (de in Data.day.get(Day_1).events) {
			if (de.alerts.length > 0) {
				for (dea in de.alerts) {
					var t = [];
					for (tasks in dea.Tasks) {
						t.push({taskKind:tasks.taskId, text:tasks.text, author:tasks.author});
					}
					currentAlerts.push(t);
				}
			}
		}

		nextTasks();
	}

	function nextTasks() {
		moduleScreen.reset();
		hud.showTimer();

		currentTasks = currentAlerts.shift();
		var message = "";
		for (i in 0...currentTasks.length) {
			message += (i > 0 ? "\n" : "") + currentTasks[i].text;
		}
		communication.forceMessage(message, currentTasks[0].author);

		if (currentScreen != communication)
			hud.showNewMessage();
	}

	public function onCompleteTask(td:TaskData) {
		currentTasks.remove(td);
		hud.goodWarning();
		checkEndTasks();
	}

	function checkEndTasks() {
		if (currentTasks.length == 0) {
			currentTasks = null;
			if (currentAlerts.length > 0)
				nextTasks();
			else
				endAlert();
		}
	}

	function endAlert() {
		hud.hideTimer();

		communication.showSystemMessage("ALERTE TERMINÉE");
	}

	public function onError() {
		timer += 10 * Const.FPS;
		hud.redWarning();
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
					nextAlert();
				}
			#end
		}
	}
}


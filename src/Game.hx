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

	public var valueDatas : Array<Types.ValueData> = [];

	// Progress
	public var currentDay : Data.Day;
	public var currentEventId : Int;
	public var currentEvent(get, never) : Data.Day_events;		inline function get_currentEvent() return currentDay.events[currentEventId];

	public var currentAlerts : Array<Array<TaskData>> = [];
	public var currentTasks : Array<TaskData> = null;

	public var alertIsActive(get, never) : Bool;				inline function get_alertIsActive() return currentTasks != null;
	public var thereAreStillTalks(get, never) : Bool;			inline function get_thereAreStillTalks() {
		var out = false;
		for (i in currentEventId...currentDay.events.length) {
			if (currentDay.events[i].talks.length > 0)
				out = true;
		}

		return out;
	}

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		fx = new Fx();
		hud = new ui.Hud();

		var bg = Assets.tiles.h_get("wallBG", root);

		wrapperScreens = new h2d.Object(root);

		initData();

		manual = new screens.Manual();
		manual.root.x = w() / Const.SCALE;
		communication = new screens.Communication();
		moduleScreen = new screens.ModuleScreen();
		moduleScreen.root.x = -w() / Const.SCALE;

		Process.resizeAll();
		trace(Lang.t._("Game is ready."));

		showComm();
	}

	function initData() {
		for (type in VType.createAll()) {
			valueDatas.push({vt:type, v: 0});		
		}
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

	function launchDay(day:Data.DayKind) {
		communication.clearAll();

		currentDay = Data.day.get(day);
		currentEventId = -1;

		nextEvent();
	}

	public function nextEvent() {
		currentEventId++;

		if (currentEvent == null) { // End of the day
			communication.showOffline();
			delayer.addS(showEndDay, 2);
			// showEndDay();
		}
		else {
			delayer.addS(function() {
				if (currentEvent.talks.length > 0) {	// TALKS
					communication.initTalk();
				}
				else {									// ALERTS
					nextAlert();
				}
			}, currentEvent.timeBeforeS);
		}
	}

	function nextAlert() {
		currentAlerts = [];
		currentTasks = null;

		for (dea in currentEvent.alerts) {
			var t = [];
			for (tasks in dea.Tasks) {
				t.push({taskKind:tasks.taskId, text:tasks.text, author:tasks.author});
			}
			currentAlerts.push(t);
		}

		nextTasks();
	}

	function nextTasks() {
		moduleScreen.reset();
		hud.showTimer();

		currentTasks = currentAlerts.shift();
		var message = "";
		for (i in 0...currentTasks.length) {
			message += (i > 0 ? "\n" : "") + Lang.t.get(currentTasks[i].text);
		}
		communication.forceOutsideMessage({text: message, author: currentEvent.author, bgColor: 0x973030});

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
		moduleScreen.reset();
		hud.endAlert();

		communication.forceSystemMessage(Lang.t._("ALERTE TERMINÉE"));

		nextEvent();
	}

	public function onError() {
		return;

		timer += 10 * Const.FPS;
		hud.redWarning();
	}

	function showEndDay() {
		var inter = new h2d.Interactive(wid, hei);
		inter.backgroundColor = 0xFF000000;
		root.addChild(inter);

		var flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.backgroundTile = h2d.Tile.fromColor(0x454545);
		flow.horizontalAlign = Middle;
		flow.verticalSpacing = 10;
		flow.padding = 10;
		flow.alpha = 0;

		new h2d.Text(Assets.fontMedium, flow).text = "END OF THE DAY";

		var btn = new ui.Button("NextDay", function() {
			for (i in 0...Data.day.all.length) {
				if (Data.day.all[i] == currentDay && Data.day.all[i + 1] != null) {
					launchDay(Data.day.all[i + 1].id);
					inter.remove();
					flow.remove();
					return;
				}
			}

			trace("No day after " + currentDay.id);
			inter.remove();
			flow.remove();
		});
		flow.addChild(btn);

		flow.reflow();
		flow.setPosition((wid - flow.outerWidth) >> 1, (hei - flow.outerHeight) >> 1);

		// Appear anim
		tw.createS(inter.alpha, 0 > 1, 1).onEnd = function () {
			tw.createS(flow.alpha, 0 > 1, 0.2);
			tw.createS(flow.y, flow.y - 20 > flow.y, 0.2);
		}
	}

	function showDebugMenu() {
		var inter = new h2d.Interactive(wid, hei);
		inter.backgroundColor = 0xAA000000;
		root.addChild(inter);

		var flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.backgroundTile = h2d.Tile.fromColor(0x454545);
		flow.horizontalAlign = Middle;
		flow.verticalSpacing = 10;
		flow.padding = 10;

		new h2d.Text(Assets.fontMedium, flow).text = "DEBUG MENU";

		for (day in Data.day.all) {
			var btn = new ui.Button(day.id.toString(), function() {
				launchDay(day.id);
				inter.remove();
				flow.remove();
			});
			flow.addChild(btn);
		}

		flow.reflow();
		flow.setPosition((wid - flow.outerWidth) >> 1, (hei - flow.outerHeight) >> 1);

		// Appear anim
		tw.createS(inter.alpha, 0 > 1, 0.2);
		tw.createS(flow.alpha, 0 > 1, 0.2);
		tw.createS(flow.y, flow.y - 20 > flow.y, 0.2);
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
					// launchDay(Day_Test);
					showDebugMenu();
				}
				// if (ca.isKeyboardPressed(hxd.Key.F2)) {
				// 	launchDay(Day_Test_Alert);
				// }

				if (ca.isKeyboardPressed(hxd.Key.F5)) {
					if (currentTasks != null)
						onCompleteTask(currentTasks[0]);
				}
			#end
		}
	}
}


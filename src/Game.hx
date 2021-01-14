import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;
	
	public var wid(get,never) : Int; inline function get_wid() return Std.int(Const.AUTO_SCALE_TARGET_WID);
	public var hei(get,never) : Int; inline function get_hei() return Std.int(Const.AUTO_SCALE_TARGET_HEI);

	public var ca : dn.heaps.Controller.ControllerAccess;
	public var fx : Fx;
	public var hud : ui.Hud;

	public var manual : screens.Manual;
	public var communication : screens.Communication;
	public var moduleScreen : screens.ModuleScreen;

	public var currentScreen : Process;

	public var timer(default, null) : Float;
	public var numTaskCompleted(default, null) : Int;

	// public var currentAlert : Null<Data.AlertsKind> = null;

	public var wrapperScreens(default, null) : h2d.Object;

	public var valueDatas : Array<Types.ValueData> = [];

	var alertSound : dn.heaps.Sfx;
	// var musicNormal : dn.heaps.Sfx;
	
	var shakePower = 1.0;

	// Progress
	public var currentDay : Data.Day;
	public var currentEventId : Int;
	public var currentEvent(get, never) : Data.Day_events;		inline function get_currentEvent() return currentDay.events[currentEventId];

	public var currentAlerts : Array<TaskData> = [];
	public var currentTask : TaskData = null;

	public var alertIsActive(get, never) : Bool;				inline function get_alertIsActive() return currentTask != null;
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
		manual.root.x = Const.AUTO_SCALE_TARGET_WID;
		communication = new screens.Communication();
		moduleScreen = new screens.ModuleScreen();
		moduleScreen.root.x = -Const.AUTO_SCALE_TARGET_WID;

		Process.resizeAll();
		trace(Lang.t._("Game is ready."));

		alertSound = Assets.CREATE_SOUND(hxd.Res.sfx.alarm, Alarm, true, false, true);

		// musicNormal = Assets.CREATE_SOUND(hxd.Res.music.music1, Music_Normal, true, true, true);

		currentScreen = communication;
	}

	function initData() {
		for (type in VType.createAll()) {
			valueDatas.push({vt:type, v: 0});		
		}
	}

	public function initDay(d:Data.DayKind) {
		delayer.addS(function () {
			currentDay = Data.day.get(d);
	
			launchDay(d);
		}, 1);

		timer = 0;
		numTaskCompleted = 0;

		Const.SAVE_PROGRESS(d, 0);
	}

	public function showManual() {
		if (currentScreen == manual)
			return;

		currentScreen = manual;
		tw.createS(wrapperScreens.x, -Const.AUTO_SCALE_TARGET_WID, 0.3);
		cd.unset("shaking");
		
		Assets.CREATE_SOUND(hxd.Res.sfx.whoosh, Whoosh);
	}

	public function showComm() {
		if (currentScreen == communication)
			return;

		currentScreen = communication;
		tw.createS(wrapperScreens.x, 0, 0.3);
		hud.hideNewMessage();
		cd.unset("shaking");

		Assets.CREATE_SOUND(hxd.Res.sfx.whoosh, Whoosh);
	}

	public function showModules() {
		if (currentScreen == moduleScreen)
			return;

		currentScreen = moduleScreen;
		tw.createS(wrapperScreens.x, Const.AUTO_SCALE_TARGET_WID, 0.3);
		cd.unset("shaking");

		Assets.CREATE_SOUND(hxd.Res.sfx.whoosh, Whoosh);
	}

	public function onCdbReload() {
	}

	override function onResize() {
		super.onResize();
	}

	function launchDay(day:Data.DayKind) {
		communication.clearAll();

		currentDay = Data.day.get(day);
		currentEventId = -1;

		nextEvent();
	}

	public function nextEvent() {
		currentEventId++;

		Const.SAVE_PROGRESS(currentDay.id, currentEventId);

		if (currentEvent == null) { // End of the day
			// tw.createS(musicNormal.volume, 0, 0.5).onEnd = ()->musicNormal.stop();
			delayer.addS(Main.ME.showEndDay, 2);
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

			// TODO Only for demo
			if (currentEvent.author == "Anon")
				delayer.addS(function() {
					new ui.Transition(()->null, 2, 0.05);
				}, currentEvent.timeBeforeS - 1.8);
		}
	}

	public function hasMoreTalkToday(author:String) : Bool {
		if (currentDay.events[currentEventId + 1] == null)
			return false;

		for (i in (currentEventId + 1)...currentDay.events.length) {
			if (currentDay.events[i].author == author)
				return true;
		}

		return false;
	}

	function nextAlert() {
		currentAlerts = [];
		currentTask = null;

		for (dea in currentEvent.alerts) {
			for (tasks in dea.Tasks) {
				currentAlerts.push({taskKinds:tasks.tasks.map((t)->t.taskId), text:tasks.text, author:tasks.author});
			}
		}

		if (alertSound.volume == 0)
			alertSound = Assets.CREATE_SOUND(hxd.Res.sfx.alarm, Alarm, true, false, true);
		alertSound.play(true);

		nextTasks();
	}

	function nextTasks() {
		moduleScreen.reset();
		hud.showAlert();

		currentTask = currentAlerts.shift();
		var message = currentTask.text;
		if (currentTask.taskKinds.length > 0) {
			hud.showTimer();
			communication.forceOutsideMessage({text: message, author: currentEvent.author, type: Alert, timeBefore: 0});
		}
		else {
			communication.forceOutsideMessage({text: message, author: currentEvent.author, type: Alert, timeBefore: 0});
			delayer.addS(nextTasks, 0.5 + message.length * 0.04);
		}
	}

	public function needNewMessageInfo() {
		if (currentScreen != communication)
			hud.showNewMessage(currentScreen == moduleScreen);
	}

	public function onCompleteTask(tk:Data.TaskKind) {
		numTaskCompleted++;
		currentTask.taskKinds.remove(tk);
		hud.goodWarning();
		checkEndTasks();
	}

	function checkEndTasks() {
		if (currentTask.taskKinds.length == 0) {
			currentTask = null;
			if (currentAlerts.length > 0)
				nextTasks();
			else
				endAlert();
		}
	}

	function endAlert() {
		moduleScreen.reset();
		hud.endAlert();

		alertSound.stop();
		Assets.CREATE_SOUND(hxd.Res.sfx.endAlarm, EndAlarm);

		// tw.createS(musicNormal.volume, 1, 0.5);

		communication.forceSystemMessage(Lang.t._("ALERTE TERMINÉE"), Alert);

		nextEvent();
	}

	public function onError() {
		hud.redWarning();

		shakeS(0.3);

		if (currentTask == null)
			Game.ME.hud.showAlertMessage();
		else 
			timer += 10 * Const.FPS;
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
			var btn = new ui.DebugButton(day.id.toString(), function() {
				launchDay(day.id);
				inter.remove();
				flow.remove();
			});
			flow.addChild(btn);
		}

		flow.reflow();
		flow.setPosition((wid - flow.outerWidth) >> 1, (hei - flow.outerHeight) >> 1);

		inter.onClick = function (e) {
			inter.remove();
			flow.remove();
		}

		// Appear anim
		tw.createS(inter.alpha, 0 > 1, 0.2);
		tw.createS(flow.alpha, 0 > 1, 0.2);
		tw.createS(flow.y, flow.y - 20 > flow.y, 0.2);
	}

	function gc() {}

	public function shakeS(t:Float, ?pow=1.0) {
		if (currentScreen == communication) wrapperScreens.x = 0;
		else if (currentScreen == moduleScreen) wrapperScreens.x = Const.AUTO_SCALE_TARGET_WID;
		else if (currentScreen == manual) wrapperScreens.x = -Const.AUTO_SCALE_TARGET_WID;
		wrapperScreens.y = 0;

		cd.setS("shaking", t, false, function() {
			if (currentScreen == communication) wrapperScreens.x = 0;
			else if (currentScreen == moduleScreen) wrapperScreens.x = Const.AUTO_SCALE_TARGET_WID;
			else if (currentScreen == manual) wrapperScreens.x = -Const.AUTO_SCALE_TARGET_WID;
			wrapperScreens.y = 0;
		});

		shakePower = pow;
	}

	override function onDispose() {
		super.onDispose();

		alertSound.stop();

		fx.destroy();
		gc();
	}

	override function preUpdate() {
		super.preUpdate();
	}

	override function fixedUpdate() {
		super.fixedUpdate();
	}

	override function update() {
		super.update();

		if (alertIsActive)
			timer += tmod;

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			if (ca.isKeyboardPressed(Key.ESCAPE)) {
				pause();
				new ui.Pause();
			}
			// #if hl
			// // Exit
			// if( ca.isKeyboardPressed(Key.ESCAPE) )
			// 	if( !cd.hasSetS("exitWarn",3) )
			// 		trace(Lang.t._("Press ESCAPE again to exit."));
			// 	else
			// 		hxd.System.exit();
			// #end

			#if debug
				if (ca.isKeyboardPressed(hxd.Key.F1)) {
					showDebugMenu();
				}
				else if (ca.isKeyboardPressed(hxd.Key.F2)) {
					shakeS(0.3);
				}

				if (ca.isKeyboardPressed(hxd.Key.F5)) {
					if (currentTask.taskKinds.length > 0)
						onCompleteTask(currentTask.taskKinds[0]);
				}
				if (ca.isKeyboardPressed(hxd.Key.F6)) {
				}
			#end
		}
	}

	override function postUpdate() {
		super.postUpdate();

		if( cd.has("shaking") ) {
			wrapperScreens.x += Math.cos(ftime*1.1)*2.5*shakePower * cd.getRatio("shaking");
			wrapperScreens.y += Math.sin(0.3+ftime*1.7)*2.5*shakePower * cd.getRatio("shaking");
		}

		gc();
	}
}


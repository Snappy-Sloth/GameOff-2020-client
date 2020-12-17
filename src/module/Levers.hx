package module;

class Levers extends Module {

	var levers : Array<Lever>;

	public function new() {
		super(150, 75);

		var bg = Assets.tiles.h_get("bgSwitch");
		root.addChild(bg);

		var flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = wid;
		flow.minHeight = flow.maxHeight = hei;
		flow.multiline = true;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = flow.verticalSpacing = 10;

		levers = [];

		for (lever in Data.lever.all) {
			var lights = [];
			for (l in lever.lights) {
				lights.push(l.lightNum - 1);
			}

			var lever = new Lever(onClick, lights);
			lever.x = 15 + 24 * levers.length;
			lever.y = 28;
			levers.push(lever);
			root.addChild(lever);
		}
	}

	override function reset() {
		super.reset();

		for (l in levers) {
			l.reset();
		}
	}

	function onClick(l:Lever) {
		if (Game.ME.currentTask == null) {
			Game.ME.onError();
			return;
		}

		Assets.CREATE_SOUND(hxd.Res.sfx.m_switch, M_Switch);

		l.toggle();

		for (i in l.lights) {
			levers[i].switchLight();
		}

		checkValidate();
	}

	override function checkValidate() {
		super.checkValidate();

		for (t in Game.ME.currentTask.taskKinds.copy()) {
			if (Data.task.get(t).group == Data.Task_group.Levers) {
				var isValidated = true; 
				var dataText = Data.task.get(t).data;
				var data = dataText.split(" ");
				for (i in 0...data.length) {
					if ((data[i] == "-" && levers[i].isLightOn) || (data[i] == "X" && !levers[i].isLightOn)) {
						isValidated = false;
						break;
					}
				}

				if (isValidated) {
					Game.ME.onCompleteTask(t);
					break;
				}
			}
		}
	}
}

class Lever extends h2d.Object {

	public var isLightOn(default, null) : Bool = false;

	public var lights(default, null) : Array<Int>;

	var lightSpr : HSprite;
	var shadow : HSprite;
	var lever : HSprite;
	var glow : HSprite;

	var isUp : Bool = true;

	public function new(onClick:Lever->Void, lights:Array<Int>) {
		super();

		this.lights = lights;

		var base = Assets.tiles.h_get("baseSwitch", 0.5, 0.5, this);

		shadow = Assets.tiles.h_get("switchShadowUp", 0.5, 0.5, this);

		lever = Assets.tiles.h_get("switchUp", 0.5, 0.5, this);

		var inter = new h2d.Interactive(20, 50, this);
		inter.x = -inter.width * 0.5;
		inter.y = -inter.height * 0.5;
		// inter.backgroundColor = 0x55FF00FF;
		inter.onClick = function (e) {
			onClick(this);
		}

		var baseLight = Assets.tiles.h_get("baseLight", 0.5, 0, this);
		baseLight.y = (Std.int(inter.height) >> 1);
		lightSpr = Assets.tiles.h_get("switchLightOff", 0.5, 0, this);
		lightSpr.y = baseLight.y;

		glow = Assets.tiles.h_get("switchLightGlow", 0.5, 0.5, this);
		glow.blendMode = h2d.BlendMode.Add;
		glow.y = baseLight.y + (Std.int(baseLight.tile.height) >> 1);
		glow.alpha = 0;

		reset();
	}

	public function toggle() {
		isUp = !isUp;
		shadow.set(isUp ? "switchShadowUp" : "switchShadowDown");
		lever.set(isUp ? "switchUp" : "switchDown");
	}

	public function switchLight() {
		isLightOn = !isLightOn;

		lightSpr.set(isLightOn ? "switchLightOn" : "switchLightOff");
		Game.ME.tw.createS(glow.alpha, isLightOn ? 1 : 0, 0.2);
	}

	public function reset() {
		isLightOn = false;

		isUp = true;

		lightSpr.set(isLightOn ? "switchLightOn" : "switchLightOff");
		Game.ME.tw.createS(glow.alpha, isLightOn ? 1 : 0, 0.2);

		shadow.set(isUp ? "switchShadowUp" : "switchShadowDown");
		lever.set(isUp ? "switchUp" : "switchDown");
	}

}
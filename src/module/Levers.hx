package module;

class Levers extends Module {

	var levers : Array<Lever>;

	public function new() {
		super(300, 150);

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
			lever.x = 25 + 50 * levers.length;
			lever.y = 55;
			levers.push(lever);
			root.addChild(lever);
		}
	}

	override function reset() {
		super.reset();

		for (l in levers) {
			l.forceLightStatus(false);
		}
	}

	function onClick(l:Lever) {
		if (Game.ME.currentTasks == null) {
			Game.ME.onError();
			return;
		}

		l.toggle();

		for (i in l.lights) {
			levers[i].switchLight();
		}

		checkValidate();
	}

	override function checkValidate() {
		super.checkValidate();

		for (t in Game.ME.currentTasks.copy()) {
			if (Data.task.get(t.taskKind).group == Data.Task_group.Levers) {
				var isValidated = true; 
				var dataText = Data.task.get(t.taskKind).data;
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

		var inter = new h2d.Interactive(40, 100, this);
		inter.x = -inter.width * 0.5;
		inter.y = -inter.height * 0.5;
		// inter.backgroundColor = 0x55FF00FF;
		inter.onClick = function (e) {
			onClick(this);
		}

		var baseLight = Assets.tiles.h_get("baseLight", 0.5, 0, this);
		baseLight.y = (Std.int(inter.height) >> 1) + 5;
		lightSpr = Assets.tiles.h_get("switchLightOff", 0.5, 0, this);
		lightSpr.y = baseLight.y;

		glow = Assets.tiles.h_get("switchLightGlow", 0.5, 0.5, this);
		glow.blendMode = h2d.BlendMode.Add;
		glow.y = baseLight.y + (Std.int(baseLight.tile.height) >> 1);

		forceLightStatus(false);
	}

	public function toggle() {
		isUp = !isUp;
		shadow.set(isUp ? "switchShadowUp" : "switchShadowDown");
		lever.set(isUp ? "switchUp" : "switchDown");
	}

	public function switchLight() {
		isLightOn = !isLightOn;

		lightSpr.set(isLightOn ? "switchLightOn" : "switchLightOff");
		glow.visible = isLightOn;
	}

	public function forceLightStatus(lightOn:Bool) {
		isLightOn = lightOn;

		lightSpr.set(isLightOn ? "switchLightOn" : "switchLightOff");
		glow.visible = isLightOn;
	}

}
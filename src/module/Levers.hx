package module;

class Levers extends Module {

	var levers : Array<Lever>;

	public function new() {
		super(350, 150);

		var flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = wid;
		flow.minHeight = flow.maxHeight = hei;
		flow.multiline = true;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = flow.verticalSpacing = 20;

		levers = [];

		for (lever in Data.lever.all) {
			var lights = [];
			for (l in lever.lights) {
				lights.push(l.lightNum - 1);
			}

			var lever = new Lever(onClick, lights);
			levers.push(lever);
			flow.addChild(lever);
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

	public function new(onClick:Lever->Void, lights:Array<Int>) {
		super();

		this.lights = lights;

		var flow = new h2d.Flow(this);
		flow.layout = Vertical;
		flow.verticalSpacing = 20;
		flow.horizontalAlign = Middle;

		var inter = new h2d.Interactive(30, 75, flow);
		inter.backgroundColor = 0x55FF00FF;

		inter.onClick = function (e) {
			onClick(this);
		}

		lightSpr = Assets.tiles.h_get("leverLightOff", flow);
	}

	public function switchLight() {
		isLightOn = !isLightOn;

		lightSpr.set(isLightOn ? "leverLightOn" : "leverLightOff");
	}

	public function forceLightStatus(lightOn:Bool) {
		isLightOn = lightOn;

		lightSpr.set(isLightOn ? "leverLightOn" : "leverLightOff");
	}

}
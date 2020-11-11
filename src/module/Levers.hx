package module;

class Levers extends Module {

	var levers : Array<Lever>;

	public function new() {
		super();

		var flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = Const.MODULE_WIDTH;
		flow.minHeight = flow.maxHeight = Const.MODULE_HEIGHT;
		flow.multiline = true;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = flow.verticalSpacing = 30;

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

	function onClick(l:Lever) {
		for (i in l.lights) {
			levers[i].switchLight();
		}
	}
}

class Lever extends h2d.Object {

	var isLightOn : Bool = false;

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

}
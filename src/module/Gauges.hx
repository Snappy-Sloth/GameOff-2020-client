package module;

class Gauges extends Module {

	var gauges : Array<Gauge> = [];

	public function new() {
		super(300, 300);

		var flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = wid;
		flow.minHeight = flow.maxHeight = hei;
		flow.multiline = true;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = flow.verticalSpacing = 30;

		for (i in 0...4) {
			var gauge = new Gauge(this);
			flow.addChild(gauge);
			gauges.push(gauge);
		}

		var btn = new ui.Button("Mélanger", checkValidate);
		flow.addChild(btn);
	}

	override function checkValidate() {
		if (Game.ME.currentTasks == null) {
			Game.ME.onError();
			return;
		}

		for (t in Game.ME.currentTasks.copy()) {
			if (Data.task.get(t.taskKind).group == Data.Task_group.Gauges) {
				var isValidated = true;
				var dataText = Data.task.get(t.taskKind).data;
				var data = dataText.split(" ");
				for (i in 0...4) {
					if (Math.round(gauges[i].currentRatio * 10) != Std.parseInt(data[i]))
						isValidated = false;
				}

				trace(isValidated);

				if (isValidated) {
					Game.ME.onCompleteTask(t);
					break;
				}
				else 
					Game.ME.onError();
			}
		}
	}
}

private class Gauge extends h2d.Object {

	var isClicked : Bool = false;

	public var currentRatio(default, null) : Float = 0;

	public function new(gauges:Gauges) {
		super();

		var bmp = new h2d.Bitmap(h2d.Tile.fromColor(0xFF884e4e, 25, 200), this);
		bmp.x = 25;

		var arrow = Assets.tiles.h_get("gaugeArrow", 0, 0, 0.5, this);

		var inter = new h2d.Interactive(50, 200, this);
		inter.onPush = function (e) {
			isClicked = true;
			inter.onMove(e);
		}
		inter.onMove = function (e) {
			if (isClicked) {
				currentRatio = 1 - snap((e.relY / inter.height));

				arrow.y = (1 - currentRatio) * inter.height;
			}
		}
		inter.onRelease = function (e) {
			isClicked = false;
		}

		arrow.y = currentRatio * inter.height;
	}

	inline function snap(ratio:Float) {
		var r = ratio * 10;
		var n = M.floor(r);
		var np1 = n + 1;

		return (M.fabs(r - n) < M.fabs(r - np1) ? n : np1) / 10;
	}

}
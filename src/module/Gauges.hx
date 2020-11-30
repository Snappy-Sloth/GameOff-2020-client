package module;

class Gauges extends Module {

	var gauges : Array<Gauge> = [];

	public function new() {
		super(300, 300);

		var bg = Assets.tiles.h_get("bgGauges", root);

		var flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = wid;
		flow.minHeight = flow.maxHeight = hei;
		flow.multiline = true;
		// flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = 38;
		flow.verticalSpacing = 10;
		flow.paddingLeft = 10;
		flow.paddingTop = 35;

		for (i in 0...4) {
			var gauge = new Gauge(this, i);
			flow.addChild(gauge);
			gauges.push(gauge);
		}

		var btn = new ui.DebugButton("Mélanger", checkValidate);
		flow.addChild(btn);
		flow.getProperties(btn).horizontalAlign = Middle;
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

	public function new(gauges:Gauges, id:Int) {
		super();

		var sprCore = Assets.tiles.h_get("gaugeCore", id, this);
		sprCore.x = 18;
		sprCore.y = 188;
		sprCore.alpha = 0.8;
		
		var sprTop = Assets.tiles.h_get("gaugeTop", id, 0, 1, this);
		sprTop.x = sprCore.x;
		sprTop.alpha = sprCore.alpha;

		var arrow = Assets.tiles.h_get("arrowGauge", 0, 0, 0.5, this);

		var inter = new h2d.Interactive(40, 188, this);
		// inter.backgroundColor = 0x55FF00FF;
		inter.onPush = function (e) {
			isClicked = true;
			inter.onMove(e);
		}
		inter.onMove = function (e) {
			if (isClicked) {
				currentRatio = 1 - snap((e.relY / inter.height));

				arrow.y = (1 - currentRatio) * inter.height;

				sprCore.scaleY = -currentRatio * inter.height;
				sprTop.y = sprCore.y + sprCore.scaleY;
			}
		}
		inter.onRelease = function (e) {
			isClicked = false;
		}

		arrow.y = (1 - currentRatio) * inter.height;

		sprCore.scaleY = -currentRatio * inter.height;
		sprTop.y = sprCore.y + sprCore.scaleY;
	}

	inline function snap(ratio:Float) {
		var r = ratio * 10;
		var n = M.floor(r);
		var np1 = n + 1;

		return (M.fabs(r - n) < M.fabs(r - np1) ? n : np1) / 10;
	}

}
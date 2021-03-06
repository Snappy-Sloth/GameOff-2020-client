package module;

class Gauges extends Module {

	var gauges : Array<Gauge> = [];

	public function new() {
		super(150, 150);

		var bg = Assets.tiles.h_get("bgGauges", root);

		var flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = wid;
		flow.minHeight = flow.maxHeight = hei;
		flow.multiline = true;
		// flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = 16;
		flow.verticalSpacing = 3;
		flow.paddingLeft = 5;
		flow.paddingTop = 20;

		for (i in 0...4) {
			var gauge = new Gauge(this, i);
			flow.addChild(gauge);
			gauges.push(gauge);
		}

		// var btn = new ui.DebugButton("Mélanger", checkValidate);
		// flow.addChild(btn);
		// flow.getProperties(btn).horizontalAlign = Middle;

		var mixBtn = new ui.MixButton(Lang.t._("Mélanger"), checkValidate);
		flow.addChild(mixBtn);
		flow.getProperties(mixBtn).horizontalAlign = Middle;
		flow.getProperties(mixBtn).paddingLeft = -5;
	}

	override function checkValidate() {
		if (Game.ME.currentTask == null) {
			Game.ME.onError();
			return;
		}

		for (t in Game.ME.currentTask.taskKinds.copy()) {
			if (Data.task.get(t).group == Data.Task_group.Gauges) {
				var isValidated = true;
				var dataText = Data.task.get(t).data;
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
		sprCore.x = 12;
		sprCore.y = 100;
		sprCore.alpha = 0.8;
		
		var sprTop = Assets.tiles.h_get("gaugeTop", id, 0, 1, this);
		sprTop.x = sprCore.x;
		sprTop.alpha = sprCore.alpha;

		var arrow = Assets.tiles.h_get("arrowGauge", 0, 0, 0.5, this);

		var inter = new h2d.Interactive(22, 100, this);
		// inter.backgroundColor = 0x55FF00FF;
		inter.onPush = function (e) {
			isClicked = true;
			inter.onMove(e);
		}
		inter.onMove = function (e) {
			if (isClicked) {
				var previous = currentRatio;
				currentRatio = hxd.Math.clamp(1 - snap(e.relY / inter.height), 0, 1);

				arrow.y = (1 - currentRatio) * inter.height - (currentRatio == 0 ? 0 : 3);

				sprCore.scaleY = -currentRatio * inter.height;
				sprTop.y = sprCore.y + sprCore.scaleY;

				if (previous != currentRatio)
					Assets.CREATE_SOUND(hxd.Res.sfx.m_changeGauges, M_ChangeGauges);
			}
		}
		inter.onRelease = function (e) {
			isClicked = false;
		}

		arrow.y = (1 - currentRatio) * inter.height - (currentRatio == 0 ? 0 : 3);

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
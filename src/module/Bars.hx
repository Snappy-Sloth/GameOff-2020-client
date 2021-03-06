package module;

class Bars extends Module {

	var bars : Array<Bar> = [];
	
	public function new() {
		super(150, 62);

		var bg = Assets.tiles.h_get("bgBars");
		root.addChild(bg);

		var flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = wid;
		flow.minHeight = flow.maxHeight = hei;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = flow.verticalSpacing = 5;

		for (i in 0...8) {
			var bar = new Bar(this, i);
			flow.addChild(bar);
			bars.push(bar);
		}
	}

	override function checkValidate() {
		if (Game.ME.currentTask == null) {
			Game.ME.onError();
			return;
		}
		
		for (t in Game.ME.currentTask.taskKinds.copy()) {
			if (Data.task.get(t).group == Data.Task_group.Bars) {
				var isValidated = true;
				var dataText = Data.task.get(t).data;
				var data = dataText.split(" ");
				for (i in 0...8) {
					if (Std.int(bars[i].currentRatio / (1/3)) != Std.parseInt(data[i]))
						isValidated = false;
				}

				if (isValidated) {
					Game.ME.onCompleteTask(t);
					break;
				}
				// else 
				// 	Game.ME.onError();
			}
		}
	}
}

private class Bar extends h2d.Object {

	var isClicked : Bool = false;

	public var id(default, null) : Int;

	public var currentRatio(default, null) : Float = 1;

	var oldRatio : Float;

	public function new(bars:Bars, id : Int) {
		super();

		this.id = id;

		oldRatio = currentRatio;

		var sprCore = Assets.tiles.h_get("barsCore", this);
		sprCore.y = 53;

		var sprTop = Assets.tiles.h_get("barsTop", 0, 0, 1, this);

		var inter = new h2d.Interactive(10, 48, this);
		inter.onPush = function (e) {
			isClicked = true;
			inter.onMove(e);
		}
		inter.onMove = function (e) {
			if (isClicked) {
				currentRatio = 1 - snap((e.relY / inter.height));

				if (oldRatio != currentRatio) {
					oldRatio = currentRatio;
					sprCore.scaleY = -currentRatio * inter.height;
					sprTop.y = sprCore.y + sprCore.scaleY;

					bars.checkValidate();

					Assets.CREATE_SOUND(hxd.Res.sfx.m_changeBars, M_ChangeBars);
				}
			}
		}
		inter.onRelease = function (e) {
			isClicked = false;
		}

		sprCore.scaleY = -currentRatio * inter.height;
		sprTop.y = sprCore.y + sprCore.scaleY;
	}

	inline function snap(ratio:Float) {
		var r = ratio / (1 / 3);
		var n = M.floor(r);
		var np1 = n + 1;

		return (M.fabs(r - n) < M.fabs(r - np1) ? n : np1) * (1 / 3);
	}

}
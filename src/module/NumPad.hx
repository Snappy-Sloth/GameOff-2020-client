package module;

class NumPad extends Module {

	var btns : Array<Button>;

	var flow : h2d.Flow;

	var numsClicked : Array<Int> = [];

	var answerText : h2d.Text;

	var screen : HSprite;
	
	public function new() {
		super(250, 250, 0x306082);

		var bg = Assets.tiles.h_get("bgNumpad");
		root.addChild(bg);

		flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = wid;
		flow.minHeight = flow.maxHeight = hei;
		flow.multiline = true;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = flow.verticalSpacing = 10;
		flow.paddingTop = 11;

		btns = [];

		screen = Assets.tiles.h_get("screenNumpad", flow);

		answerText = new h2d.Text(Assets.fontSinsgold32, screen);
		answerText.textColor = 0x282f2e;
		answerText.letterSpacing = 5;
		answerText.setPosition(	Std.int(screen.tile.width - answerText.textWidth) >> 1,
								Std.int(screen.tile.height - answerText.textHeight) >> 1);

		for (i in 0...9) {
			var btn = new Button(i + 1, onClick);
			flow.addChild(btn);
		}
	}

	override function reset() {
		super.reset();

		numsClicked = [];
		answerText.text = "";
	}

	function onClick(b:Button) {
		if (Game.ME.currentTasks == null) {
			Game.ME.onError();
			return;
		}

		var isError = true;

		for (t in Game.ME.currentTasks) {
			if (Data.task.get(t.taskKind).group == Data.Task_group.NumPad)
				isError = false;
		}

		if (isError)
			Game.ME.onError();
		else {
			for (t in Game.ME.currentTasks.copy()) {
				if (Data.task.get(t.taskKind).group == Data.Task_group.NumPad) {
					var dataText = Data.task.get(t.taskKind).data;
					var data = dataText.split(" ");
					if (b.id == Std.parseInt(data[numsClicked.length])) {
						numsClicked.push(b.id);

						answerText.text = "";
						for (i in numsClicked) {
							answerText.text += i;
						}
					}
				}
			}

			answerText.setPosition(	Std.int(screen.tile.width - answerText.textWidth) >> 1,
									Std.int(screen.tile.height - answerText.textHeight) >> 1);

			checkValidate();
		}
	}

	override function checkValidate() {
		super.checkValidate();

		for (t in Game.ME.currentTasks.copy()) {
			if (Data.task.get(t.taskKind).group == Data.Task_group.NumPad) {
				var dataText = Data.task.get(t.taskKind).data;

				if (dataText.split(" ").length == numsClicked.length) {
					Game.ME.onCompleteTask(t);
					break;
				}
			}
		}
	}

	override function onResize() {
		super.onResize();

		flow.reflow();
	}
}

private class Button extends h2d.Object {

	public var id(default, null) : Int;

	public function new(id:Int, onClick:Button->Void) {
		super();

		this.id = id;

		var flow = new h2d.Flow(this);

		var spr = Assets.tiles.h_get("numpad", id - 1, 0.5, 0.5, flow);

		flow.setPosition(Std.int(spr.tile.width) >> 1, Std.int(spr.tile.height) >> 1);

		var inter = new h2d.Interactive(spr.tile.width, spr.tile.height, this);
		inter.onClick = function (e) {
			onClick(this);
		}
		inter.onPush = function (e) {
			spr.setScale(0.9);
		}
		inter.onRelease = function (e) {
			spr.setScale(1);
		}
	}

}
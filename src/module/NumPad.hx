package module;

class NumPad extends Module {

	var btns : Array<Button>;

	var flow : h2d.Flow;

	var numsClicked : Array<Int> = [];

	var answerText : h2d.Text;
	
	public function new() {
		super(250, 250, 0x306082);

		flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = wid;
		flow.minHeight = flow.maxHeight = hei;
		flow.multiline = true;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = flow.verticalSpacing = 20;

		btns = [];

		answerText = new h2d.Text(Assets.fontMedium, flow);
		answerText.letterSpacing = 10;
		flow.getProperties(answerText).minWidth = Std.int(wid * 0.8);
		flow.getProperties(answerText).minHeight = 25;

		for (i in 0...3) {
			for (j in 0...3) {
				var btn = new Button(9 - ((3 - j) + i * 3) + 1, onClick);
				flow.addChild(btn);
			}
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
							answerText.text += i + " ";
						}
					}
				}
			}

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

		var bmp = new h2d.Bitmap(h2d.Tile.fromColor(0xe8e8e8, 50, 50));
		this.addChild(bmp);

		var text = new h2d.Text(Assets.fontLarge, this);
		text.text = Std.string(id);
		text.setPosition(Std.int((bmp.tile.width - text.textWidth) * 0.5), Std.int((bmp.tile.height - text.textHeight) * 0.5));

		var inter = new h2d.Interactive(50, 50, this);
		inter.onClick = function (e) {
			onClick(this);
		}
	}

}
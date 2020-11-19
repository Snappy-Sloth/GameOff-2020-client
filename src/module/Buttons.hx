package module;

enum ButtonType {
	WhiteNormal;
	WhiteTexted;
	RedNormal;
	RedTexted;
	BlueNormal;
	BlueTexted;
}

class Buttons extends Module {

	var btns : Array<Button>;

	public function new() {
		super();

		var flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = Const.MODULE_WIDTH;
		flow.minHeight = flow.maxHeight = Const.MODULE_HEIGHT;
		flow.multiline = true;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = flow.verticalSpacing = 30;

		btns = [];

		for (type in ButtonType.createAll()) {
			var btn = new Button(type, onClick);
			flow.addChild(btn);
			btns.push(btn);
		}

		reset();
	}

	function getButton(bt:ButtonType):Button {
		for (button in btns) {
			if (button.bt == bt)
				return button;
		}

		throw "There is no " + bt + " button type";
	}

	override function reset() {
		super.reset();

		for (b in btns) {
			b.reset();
		}
	}

	function onClick(bt:Button) {
		if (Game.ME.currentTasks == null) {
			Game.ME.onError();
			return;
		}

		var isError = true;

		for (t in Game.ME.currentTasks) {
			switch (t.taskKind) {
				case A1, A2, A3:
					if (bt.bt == WhiteNormal) {
						bt.numClick++;
						isError = false;
					}
				case A4:
					if (bt.bt == RedNormal) {
						bt.numClick++;
						isError = false;
					}

				default:
					if (Data.task.get(t.taskKind).group == Data.Task_group.Buttons)
						throw "You forget to add " + t.taskKind + " to the switch in Buttons";
			}
		}

		if (isError)
			Game.ME.onError();

		checkValidate();
	}
	
	override function checkValidate() {
		super.checkValidate();

		for (t in Game.ME.currentTasks.copy()) {
			var isValidated = switch (t.taskKind) {
				case null: true;
				case A1:
					if (getButton(WhiteNormal).numClick == 1)
						true;
					else 
						false;
				case A2:
					if (getButton(WhiteNormal).numClick == 2)
						true;
					else 
						false;
				case A3:
					if (getButton(WhiteNormal).numClick == 3)
						true;
					else 
						false;
				case A4:
					if (getButton(RedNormal).numClick == 1)
						true;
					else 
						false;
				default:
					if (Data.task.get(t.taskKind).group == Data.Task_group.Buttons)
						throw "You forget to add " + t.taskKind + " to the switch in Buttons";
					false;
			}

			if (isValidated) {
				Game.ME.onCompleteTask(t);
				break;
			}
		}
	}
}

private class Button extends h2d.Layers {
	public static var ME : Button;
	
	public var bt(default, null) : ButtonType;

    public var wid(default, null) : Int;
	public var hei(default, null) : Int;
	
	public var numClick : Int;

    public function new(bt:ButtonType, onClick:Button->Void, ?wid:Int = Const.BUTTON_WIDTH, ?hei:Int = Const.BUTTON_HEIGHT) {
        super();

		ME = this;

		this.bt = bt;
		
        this.wid = wid;
        this.hei = hei;
		
		numClick = 0;

        var inter = new h2d.Interactive(wid, hei, this);
        inter.backgroundColor = 0xFF7F7F7F;
        inter.onClick = function(e) {
			onClick(this);
		}
		inter.onOver = function (e) {
			inter.backgroundColor = 0xFFacaaaa;
		}
		inter.onOut = function (e) {
			inter.backgroundColor = 0xFF7F7F7F;
		}

		inter.onPush = function (e) {
			inter.backgroundColor = 0xFF575757;
		}
		inter.onRelease = function (e) {
			inter.backgroundColor = 0xFF7F7F7F;
		}

        var text = new h2d.Text(Assets.fontPixel, this);
        text.text = bt.getName();
        text.textAlign = Center;
        text.maxWidth = wid;
        text.setPosition(0, Std.int((hei - text.textHeight) / 2));
	}
	
	public function reset() {
		numClick = 0;
	}
}
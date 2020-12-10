package module;

enum ButtonType {
	Square;
	Triangle;
	Pentagon;
	Hexagon;
}

class Buttons extends Module {

	var btns : Array<Button>;

	public function new() {
		super(266, 75);

		var bg = Assets.tiles.h_get("bgButtons");
		root.addChild(bg);
		
		var wrapperBtns = new h2d.Object(root);

		btns = [];

		for (type in ButtonType.createAll()) {
			var btn = new Button(type, onClick);
			wrapperBtns.addChild(btn);
			btn.x = 11 + btns.length * 63 + (type == Pentagon ? -3 : 0);
			btn.y = 10;
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

		var isError = false;

		for (t in Game.ME.currentTasks.copy()) {
			if (Data.task.get(t.taskKind).group == Data.Task_group.Buttons) {
				var dataText = Data.task.get(t.taskKind).data;
				var n = 0;
				var buttonId = Std.parseInt(dataText.charAt(0)) - 1;
				var numClick = Std.parseInt(dataText.charAt(1));
				if (bt != btns[buttonId])
					isError = true;
				else {
					bt.numClick++;
				}
			}
		}

		if (isError)
			Game.ME.onError();

		checkValidate();
	}
	
	override function checkValidate() {
		super.checkValidate();

		for (t in Game.ME.currentTasks.copy()) {
			if (Data.task.get(t.taskKind).group == Data.Task_group.Buttons) {
				var isValidated = false;
				var dataText = Data.task.get(t.taskKind).data;
				var n = 0;
				var buttonId = Std.parseInt(dataText.charAt(0)) - 1;
				var numClick = Std.parseInt(dataText.charAt(1));
				if (btns[buttonId].numClick == numClick)
					isValidated = true;

				if (isValidated) {
					Game.ME.onCompleteTask(t);
					break;
				}
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

		var wrapperSpr = new h2d.Object(this);

		var shadow = Assets.tiles.h_get(bt.getName().toLowerCase() + "BtnShadow", 0.5, 0.5, wrapperSpr);
		shadow.setPos(4, 4);

		var spr = Assets.tiles.h_get(bt.getName().toLowerCase() + "Btn", 0.5, 0.5, wrapperSpr);
		
		wrapperSpr.setPosition(Std.int(spr.tile.width) >> 1, Std.int(spr.tile.height) >> 1);

        var inter = new h2d.Interactive(spr.tile.width, spr.tile.height, this);
		inter.onPush = function (e) {
			spr.setScale(0.9);
			shadow.setScale(0.8);
			// shadow.setPos(2, 2);

			onClick(this);
			Assets.CREATE_SOUND(hxd.Res.sfx.m_clicButton, M_ClicButton);
		}
		inter.onRelease = function (e) {
			spr.setScale(1);
			shadow.setScale(1);
			shadow.setPos(4, 4);
		}
	}
	
	public function reset() {
		numClick = 0;
	}
}
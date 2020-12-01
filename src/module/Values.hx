package module;

class Values extends Module {

	var currentVD : ValueData;

	var valueText : h2d.Text;
	var vtText : h2d.Text;

	var miniBtns : Array<MiniButton> = [];

	var screenText : HSprite;

	public function new() {
		super(200, 130, 0xa4afb2);

		var bg = Assets.tiles.h_get("bgValues");
		root.addChild(bg);

		var flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = wid;
		flow.minHeight = flow.maxHeight = hei;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.verticalSpacing = 7;
		flow.layout = Vertical;
		flow.padding = 4;

		currentVD = game.valueDatas[0];

		// Top
		var flowTop = new h2d.Flow(flow);
		flowTop.horizontalAlign = Middle;
		flowTop.verticalSpacing = 8;
		flowTop.layout = Vertical;

		screenText = Assets.tiles.h_get("screenTypeValues", flowTop);

		vtText = new h2d.Text(Assets.fontSinsgold16, screenText);
		// vtText.text = currentVD.vt.getName();
		// vtText.text = "Température de l'habitacle";
		vtText.textColor = 0x282f2e;
		vtText.setPosition(Std.int(screenText.tile.width - vtText.textWidth) >> 1, Std.int(screenText.tile.height - vtText.textHeight) >> 1);

		var flowBtns = new h2d.Flow(flowTop);
		flowBtns.horizontalSpacing = 10;

		for (i in 0...VType.createAll().length) {
			var btn = new MiniButton(this, game.valueDatas[i]);
			flowBtns.addChild(btn);
			miniBtns.push(btn);
		}

		flowTop.reflow();
		
		// Bottom
		var flowBottom = new h2d.Flow(flow);
		// flowBottom.debug = true;
		flowBottom.horizontalSpacing = 9;
		flowBottom.horizontalAlign = flowBottom.verticalAlign = Middle;

		var leftBtn = new Button(this, flowBottom, -1);

		var screenValue = Assets.tiles.h_get("screenValues", flowBottom);

		valueText = new h2d.Text(Assets.fontRise32, screenValue);
		valueText.text = Std.string(currentVD.v);
		valueText.textAlign = Center;
		valueText.maxWidth = screenValue.tile.width;
		valueText.textColor = 0x282f2e;
		valueText.setPosition(0, Std.int(screenValue.tile.height - valueText.textHeight) >> 1);

		var rightBtn = new Button(this, flowBottom, 1);

		flowBottom.reflow();

		miniBtns[0].enable();
	}

	public function changeCurrentVD(vd:ValueData) {
		for (button in miniBtns) button.disable();

		currentVD = vd;
		vtText.text = switch (currentVD.vt) {
			case Value1: Lang.t._("Pression du Kérosène");
			case Value2: Lang.t._("Température de la coque");
			case Value3: Lang.t._("Fréquence des radios");
			case Value4: Lang.t._("Puissance des instruments");
		}
		vtText.setPosition(Std.int(screenText.tile.width - vtText.textWidth) >> 1, Std.int(screenText.tile.height - vtText.textHeight) >> 1);
		valueText.text = Std.string(currentVD.v);
	}

	public function modifyValue(d:Int) {
		var previous = currentVD.v;
		currentVD.v += d;
		currentVD.v = hxd.Math.iclamp(currentVD.v, 0, 100);
		valueText.text = Std.string(currentVD.v);
		
		if (currentVD.v != previous)
			Assets.CREATE_SOUND(hxd.Res.sfx.m_valueChange, M_ValueChange);

		checkValidate();
	}
	
	override function checkValidate() {
		if (Game.ME.currentTasks == null) {
			Game.ME.onError();
			return;
		}

		for (t in Game.ME.currentTasks.copy()) {
			if (Data.task.get(t.taskKind).group == Data.Task_group.Values) {
				var isValidated = true; 
				var dataText = Data.task.get(t.taskKind).data;
				var data = dataText.split(" ");
				for (j in 0...data.length) {
					if (data[j] != "-") {
						if (game.valueDatas[j].v != Std.parseInt(data[j]))
							isValidated = false;
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

private class Button extends dn.Process {

	var isClicked = false;

	var delta : Int;

	var values : Values;

	var currentCD = 0.5;

	public function new(values:Values, parent:h2d.Flow, d:Int) {
		super(values);
		
		this.values = values;
		this.delta = d;
		
		createRoot(parent);

		var flow = new h2d.Flow(root);

		var spr = Assets.tiles.h_get(d < 0 ? "leftArrowValues" : "rightArrowValues", 0.5, 0.5, flow);

		flow.setPosition(Std.int(spr.tile.width) >> 1, Std.int(spr.tile.height) >> 1);

		var inter = new h2d.Interactive(spr.tile.width, spr.tile.height, root);
		inter.onPush = function (e) {
			isClicked = true;
			spr.setScale(0.9);
		}
		inter.onRelease = inter.onReleaseOutside = function (e) {
			isClicked = false;
			currentCD = 0.5;
			cd.unset("cd");
			spr.setScale(1);
		}
	}

	override function update() {
		super.update();

		if (isClicked && !cd.hasSetS("cd", currentCD)) {
			currentCD = Math.max(currentCD / 2, 0.05);
			values.modifyValue(delta);
		}
	}
}

private class MiniButton extends h2d.Object {

	var isClicked = false;

	var spr : HSprite;

	var values : Values;
	var vd : ValueData;

	public function new(values:Values, vd:ValueData) {
		super();
		
		this.values = values;
		this.vd = vd;

		var wrapperSpr = new h2d.Object(this);

		spr = Assets.tiles.h_get("btnUnselectedValues", 0.5, 0.5, wrapperSpr);

		wrapperSpr.setPosition(Std.int(spr.tile.width) >> 1, Std.int(spr.tile.height) >> 1);
		
		var inter = new h2d.Interactive(spr.tile.width, spr.tile.height, this);
		inter.onClick = function (e) {
			enable();
			Assets.CREATE_SOUND(hxd.Res.sfx.m_selectValue, M_ValueChange);
		}
		inter.onPush = function (e) {
			spr.setScale(0.9);
		}
		inter.onRelease = function (e) {
			spr.setScale(1);
		}
	}

	public function enable() {
		values.changeCurrentVD(vd);
		spr.set("btnSelectedValues");
	}

	public function disable() {
		spr.set("btnUnselectedValues");
	}
}
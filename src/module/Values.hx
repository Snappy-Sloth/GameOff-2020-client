package module;

class Values extends Module {

	var currentVD : ValueData;

	var valueText : h2d.Text;
	var vtText : h2d.Text;

	public function new() {
		super(270, 150, 0xa4afb2);

		var flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = wid;
		flow.minHeight = flow.maxHeight = hei;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.verticalSpacing = 20;
		flow.layout = Vertical;

		currentVD = game.valueDatas[0];

		// Top
		var flowTop = new h2d.Flow(flow);
		flowTop.horizontalAlign = Middle;
		flowTop.verticalSpacing = 10;
		flowTop.layout = Vertical;

		vtText = new h2d.Text(Assets.fontMedium, flowTop);
		vtText.text = currentVD.vt.getName();

		var flowBtns = new h2d.Flow(flowTop);
		flowBtns.horizontalSpacing = 10;

		for (i in 0...VType.createAll().length) {
			var btn = new h2d.Interactive(20, 20, flowBtns);
			btn.backgroundColor = 0x55FF00FF;
			btn.onClick = (e)->changeCurrentVD(game.valueDatas[i]);
		}
		
		// Bottom
		var flowBottom = new h2d.Flow(flow);
		flowBottom.debug = true;
		flowBottom.horizontalSpacing = 30;
		flowBottom.horizontalAlign = flowBottom.verticalAlign = Middle;

		var leftBtn = new Button(this, flowBottom, -1);

		valueText = new h2d.Text(Assets.fontLarge, flowBottom);
		valueText.text = Std.string(currentVD.v);
		valueText.maxWidth = 100;
		valueText.textAlign = Center;
		flowBottom.getProperties(valueText).minWidth = 100;

		var rightBtn = new Button(this, flowBottom, 1);
	}

	public function changeCurrentVD(vd:ValueData) {
		currentVD = vd;
		vtText.text = currentVD.vt.getName();
		valueText.text = Std.string(currentVD.v);
	}

	public function modifyValue(d:Int) {
		currentVD.v += d;
		valueText.text = Std.string(currentVD.v);

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

		var inter = new h2d.Interactive(50, 75, root);
		inter.backgroundColor = 0x55FF00FF;
		inter.onPush = function (e) {
			isClicked = true;
		}
		inter.onRelease = inter.onReleaseOutside = function (e) {
			isClicked = false;
			currentCD = 0.5;
			cd.unset("cd");
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
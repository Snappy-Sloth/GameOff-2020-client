package module;

class Wires extends Module {

	var topSlots : Array<Slot> = [];
	var botSlots : Array<Slot> = [];

	var from : Null<Slot> = null;

	var currentWire : Null<h2d.Graphics> = null;

	var wires : Array<{w:h2d.Graphics, top:Int, bot:Int}> = [];

	public function new() {
		super(200, 220, 0x258d41);

		wires = [];

		for (i in 0...6) {
			var slot = new Slot(this, i, true);
			slot.x = 30 * (i) + 10;
			slot.y = 20;
			topSlots.push(slot);

			var slot = new Slot(this, i, false);
			slot.x = 30 * (i) + 10;
			slot.y = hei - 50;
			botSlots.push(slot);
		}
	}

	public function onPush(s:Slot) {
		from = s;
		currentWire = new h2d.Graphics(root);

		for (w in wires.copy()) {
			if ((s.isTop && w.top == s.id) || (!s.isTop && w.bot == s.id)) {
				w.w.remove();
				wires.remove(w);
			}
		}
	}

	public function onRelease(to:Slot) {
		if (from == null)
			return;

		if (to == from) {
			delayer.addF(function () {
				if (from != null) {
					from = null;
					currentWire.remove();
					currentWire = null;
				}
			}, 1);
			return;
		}
		if (from.isTop != to.isTop) {
			for (w in wires.copy()) {
				if ((to.isTop && w.top == to.id) || (!to.isTop && w.bot == to.id)) {
					w.w.remove();
					wires.remove(w);
				}
			}

			currentWire.clear();
			currentWire.lineStyle(8, 0xFFFF0000);
			currentWire.moveTo(from.centerX, from.centerY);
			var pos = root.globalToLocal(to.localToGlobal(new h2d.col.Point(10, 10)));
			currentWire.lineTo(pos.x, pos.y);
			wires.push({w: currentWire, top:from.isTop ? from.id : to.id, bot:from.isTop ? to.id : from.id});
			// trace(wires[wires.length - 1].top + " " + wires[wires.length - 1].bot);
			// currentWire.filter = new h2d.filter.Outline(1);
		}
		from = null;
		currentWire = null;

		checkValidate();
	}

	override function checkValidate() {
		if (Game.ME.currentTasks == null) {
			Game.ME.onError();
			return;
		}

		for (t in Game.ME.currentTasks.copy()) {
			if (Data.task.get(t.taskKind).group == Data.Task_group.Wires) {
				var dataText = Data.task.get(t.taskKind).data;
				var data = dataText.split(" ");
				var n = 0;
				for (i in 0...6) {
					var top = Std.parseInt(data[i].charAt(0)) - 1;
					var bot = Std.parseInt(data[i].charAt(1)) - 1;
					for (w in wires) {
						if (w.top == top && w.bot == bot) {
							n++;
							break;
						}
					}
				}

				if (n == 6) {
					Game.ME.onCompleteTask(t);
					break;
				}
			}
		}
	}

	override function update() {
		super.update();

		if (from != null) {
			currentWire.clear();
			currentWire.lineStyle(8, 0xFFFF0000);
			currentWire.moveTo(from.centerX, from.centerY);
			var pos = root.globalToLocal(new h2d.col.Point(Boot.ME.s2d.mouseX, Boot.ME.s2d.mouseY));
			currentWire.lineTo(pos.x, pos.y);
		}
	}
}

private class Slot extends h2d.Object {

	public var id(default, null) : Int;
	public var isTop(default, null) : Bool;

	public var centerX(get, never) : Int; inline function get_centerX() return Std.int(this.x + 10);
	public var centerY(get, never) : Int; inline function get_centerY() return Std.int(this.y + 10);

	public function new(wires:Wires, id:Int, isTop:Bool) {
		super();

		this.id = id;
		this.isTop = isTop;

		wires.root.addChild(this);

		var inter = new h2d.Interactive(20, 20, this);
		inter.backgroundColor = 0xFFFF00FF;
		inter.onPush = function (e) {
			wires.onPush(this);
		}
		inter.onRelease = function (e) {
			wires.onRelease(this);
		}
		/* inter.onReleaseOutside = function (e) {
			
		} */
	}
}
package module;

class Wires extends Module {

	var topSlots : Array<Slot> = [];
	var botSlots : Array<Slot> = [];

	var from : Null<Slot> = null;

	var currentWire : Null<HSprite> = null;

	var wireJack : HSprite;

	var wires : Array<{w:HSprite, top:Int, bot:Int}> = [];

	public function new() {
		super(200, 220, 0x258d41);

		var bg = Assets.tiles.h_get("bgWires");
		root.addChild(bg);

		wires = [];

		for (i in 0...6) {
			var slot = new Slot(this, i, true);
			slot.x = 29 * (i) + 15;
			slot.y = 35;
			topSlots.push(slot);

			var slot = new Slot(this, i, false);
			slot.x = 29 * (i) + 15;
			slot.y = hei - 58;
			botSlots.push(slot);
		}

		wireJack = Assets.tiles.h_get("wireJack", 0.5, 0.5, root);

		wireJack.visible = false;
	}

	public function onPush(s:Slot) {
		from = s;
		currentWire = Assets.tiles.h_get("wireCore", 0.5, 0, root);

		// hxd.System.setCursor(Default);

		wireJack.visible = true;

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
					wireJack.visible = false;
					hxd.System.setCursor(Default);
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

			currentWire.rotation = Math.atan2(to.centerY - from.centerY, to.centerX - from.centerX) - Math.PI / 2;
			currentWire.scaleY = M.dist(from.centerX, from.centerY, to.centerX, to.centerY);
			wires.push({w: currentWire, top:from.isTop ? from.id : to.id, bot:from.isTop ? to.id : from.id});
		}
		else 
			currentWire.remove();
		from = null;
		currentWire = null;

		wireJack.visible = false;

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
			var pos = root.globalToLocal(new h2d.col.Point(Boot.ME.s2d.mouseX, Boot.ME.s2d.mouseY));

			currentWire.setPos(from.centerX, from.centerY);
			currentWire.rotation = Math.atan2(pos.y - from.centerY, pos.x - from.centerX) - Math.PI / 2;
			currentWire.scaleY = M.dist(from.centerX, from.centerY, pos.x, pos.y) - 10;

			wireJack.setPos(pos.x, pos.y);
			wireJack.rotation = currentWire.rotation;
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

		var spr = Assets.tiles.h_get("wireHoleEmpty", this);

		var inter = new h2d.Interactive(spr.tile.width, spr.tile.height, this);
		// inter.backgroundColor = 0x55FF00FF;
		inter.onPush = function (e) {
			wires.onPush(this);
		}
		inter.onRelease = function (e) {
			wires.onRelease(this);
		}
	}
}
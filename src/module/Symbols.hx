package module;

class Symbols extends Module {

	public var currentSymbol(default, null) : SymbolTile = null;

	var lastMouseX = 0.;
	var lastMouseY = 0.;

	var tiles : Array<SymbolTile> = [];
	var slots : Array<SymbolSlot> = [];
	var answerSlots : Array<SymbolSlot> = [];

	var flow : h2d.Flow;

	public function new() {
		super(350, 130, 0xa0a1b6);

		flow = new h2d.Flow(root);
		flow.minWidth = flow.maxWidth = wid;
		flow.minHeight = flow.maxHeight = hei;
		flow.layout = Vertical;
		flow.horizontalAlign = flow.verticalAlign = Middle;
		flow.horizontalSpacing = flow.verticalSpacing = 30;

		// Slots
		var wrapperSlot = new h2d.Object(flow);

		for (i in 0...3) {
			var slot = new SymbolSlot(this, i);
			wrapperSlot.addChild(slot);
			slot.x = i * 50;
			slots.push(slot);
			answerSlots.push(slot);
		}

		// Symbols
		var wrapperSymbol = new h2d.Object(flow);

		tiles = [];

		for (i in 0...6) {
			var slot = new SymbolSlot(this, i);
			wrapperSymbol.addChild(slot);
			slot.x = i * 50;
			slots.push(slot);

			var tileSymbol = new SymbolTile(this, i);
			flow.addChild(tileSymbol);
			flow.getProperties(tileSymbol).isAbsolute = true;
			tileSymbol.setSlot(slot);
			tiles.push(tileSymbol);
		}
	}

	public function selectSymbol(st:SymbolTile) {
		currentSymbol = st;
		lastMouseX = Boot.ME.s2d.mouseX;
		lastMouseY = Boot.ME.s2d.mouseY;
	}

	public function unselectSymbol() {
		var closest = null;
		var closestDist = 99999.;
		for (slot in slots) {
			var pos = currentSymbol.parent.globalToLocal(slot.localToGlobal());
			var dist = M.dist(currentSymbol.x, currentSymbol.y, pos.x, pos.y);
			if ((closest == null || dist < closestDist) && dist < 50) {
				closestDist = dist;
				closest = slot;
			}
		}
		var s = currentSymbol;
		if (closest != null) {
			var tileOnClosest = getTileOnSlot(closest);
			if (tileOnClosest != null) {
				tileOnClosest.setSlot(s.currentSlot);
				tw.createS(tileOnClosest.x, tileOnClosest.parent.globalToLocal(tileOnClosest.currentSlot.localToGlobal()).x, 0.2);
				tw.createS(tileOnClosest.y, tileOnClosest.parent.globalToLocal(tileOnClosest.currentSlot.localToGlobal()).y, 0.2);
			}
			s.setSlot(closest);
		}
		tw.createS(s.x, s.parent.globalToLocal(s.currentSlot.localToGlobal()).x, 0.2);
		tw.createS(s.y, s.parent.globalToLocal(s.currentSlot.localToGlobal()).y, 0.2).onEnd = checkValidate;

		currentSymbol = null;
	}

	override function checkValidate() {
		if (Game.ME.currentTasks == null) {
			Game.ME.onError();
			return;
		}

		for (t in Game.ME.currentTasks.copy()) {
			if (Data.task.get(t.taskKind).group == Data.Task_group.Symbols) {
				var isValidated = true;
				var dataText = Data.task.get(t.taskKind).data;
				var data = dataText.split(" ");
				for (i in 0...answerSlots.length) {
					var tile = getTileOnSlot(answerSlots[i]);
					if (tile == null || tile.id != Std.parseInt(data[i]) - 1) {
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

	function getTileOnSlot(s:SymbolSlot) : Null<SymbolTile> {
		for (tile in tiles) {
			if (tile.currentSlot == s)
				return tile;
		}

		return null;
	}

	override function onResize() {
		super.onResize();

		flow.reflow();

		for (tile in tiles) {
			tile.setSlot(tile.currentSlot, true);
		}
	}

	override function update() {
		super.update();
		
		if (currentSymbol != null) {
			currentSymbol.x += (Boot.ME.s2d.mouseX - lastMouseX) / Const.SCALE;
			currentSymbol.y += (Boot.ME.s2d.mouseY - lastMouseY) / Const.SCALE;
			
			lastMouseX = Boot.ME.s2d.mouseX;
			lastMouseY = Boot.ME.s2d.mouseY;
		}
	}
}

private class SymbolTile extends h2d.Object {

	public var id(default, null) : Int;

	public var currentSlot(default, null) : Null<SymbolSlot> = null;

	public function new(symbols:Symbols, id:Int) {
		super();

		this.id = id;

		var spr = Assets.tiles.h_get("symbol", id, this);

		var inter = new h2d.Interactive(spr.tile.width, spr.tile.height, this);
		inter.backgroundColor = 0x55FF00FF;
		inter.onPush = function (e) {
			symbols.selectSymbol(this);
		}

		inter.onRelease = function (e) {
			if (symbols.currentSymbol == this)
				symbols.unselectSymbol();
		}
	}

	public function setSlot(slot:SymbolSlot, setToPos:Bool = false) {
		currentSlot = slot;
		if (setToPos) {
			this.x = parent.globalToLocal(currentSlot.localToGlobal()).x;
			this.y = parent.globalToLocal(currentSlot.localToGlobal()).y;
		}
	}
}

private class SymbolSlot extends h2d.Object {

	public function new(symbols:Symbols, id:Int) {
		super();

		var spr = Assets.tiles.h_get("symbol_slot", this);
	}
}
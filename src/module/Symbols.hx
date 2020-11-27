package module;

class Symbols extends Module {

	static var SLOT_SIZE(get, never) : Int; inline static function get_SLOT_SIZE() return Std.int(Assets.tiles.getTile("symbolSlot").width);
	static var TILE_SIZE(get, never) : Int; inline static function get_TILE_SIZE() return Std.int(Assets.tiles.getTile("symbol", 0).width);

	static var SLOT_OFFSET = 15;

	public var currentTile(default, null) : SymbolTile = null;

	var lastMouseX = 0.;
	var lastMouseY = 0.;

	var tiles : Array<SymbolTile> = [];
	var slots : Array<SymbolSlot> = [];
	var answerSlots : Array<SymbolSlot> = [];

	var wrapperSlot : h2d.Object;
	var wrapperSymbol : h2d.Object;

	// var flow : h2d.Flow;

	public function new() {
		super(200, 150, 0xa0a1b6);

		var bg = Assets.tiles.h_get("bgSymbol");
		root.addChild(bg);

		// Slots
		wrapperSlot = new h2d.Object(root);

		for (i in 0...3) {
			var slot = new SymbolSlot(this, i);
			wrapperSlot.addChild(slot);
			// slot.x = i * 50;
			slot.x = i * (SLOT_SIZE + SLOT_OFFSET);
			slots.push(slot);
			answerSlots.push(slot);
		}

		// Symbols
		wrapperSymbol = new h2d.Object(root);

		tiles = [];

		for (j in 0...2)
		for (i in 0...4) {
			var slot = new SymbolSlot(this, i + (j * 2));
			wrapperSymbol.addChild(slot);
			// slot.x = i * 50;
			slot.x = i * (TILE_SIZE + SLOT_OFFSET);
			slot.y = j * (TILE_SIZE + 10);
			slots.push(slot);

			var tileSymbol = new SymbolTile(this, i + (j * 4));
			root.addChild(tileSymbol);
			tileSymbol.setSlot(slot);
			tiles.push(tileSymbol);
		}

		onResize();
	}

	public function selectSymbol(st:SymbolTile) {
		currentTile = st;
		root.addChild(currentTile);
		lastMouseX = Boot.ME.s2d.mouseX;
		lastMouseY = Boot.ME.s2d.mouseY;
	}

	public function unselectSymbol() {
		var closest = null;
		var closestDist = 99999.;
		for (slot in slots) {
			var pos = currentTile.parent.globalToLocal(slot.localToGlobal());
			var dist = M.dist(currentTile.x, currentTile.y, pos.x, pos.y);
			if ((closest == null || dist < closestDist) && dist < 50) {
				closestDist = dist;
				closest = slot;
			}
		}
		var s = currentTile;
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
		tw.createS(s.y, s.parent.globalToLocal(s.currentSlot.localToGlobal()).y, 0.2).onEnd = function() {
			checkValidate();
			s.hideShadow();
		}

		currentTile = null;
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

		wrapperSlot.setPosition((Std.int(wid - (SLOT_SIZE * 3 + SLOT_OFFSET * 2)) >> 1) + (SLOT_SIZE >> 1), 4 + (SLOT_SIZE >> 1));

		wrapperSymbol.setPosition((Std.int(wid - (TILE_SIZE * 4 + SLOT_OFFSET * 3)) >> 1) + (TILE_SIZE >> 1), wrapperSlot.y + (SLOT_SIZE >> 1) + 13 + (TILE_SIZE >> 1));

		for (tile in tiles) {
			tile.setSlot(tile.currentSlot, true);
		}
	}

	override function update() {
		super.update();
		
		if (currentTile != null) {
			currentTile.x += (Boot.ME.s2d.mouseX - lastMouseX) / Const.SCALE;
			currentTile.y += (Boot.ME.s2d.mouseY - lastMouseY) / Const.SCALE;
			
			lastMouseX = Boot.ME.s2d.mouseX;
			lastMouseY = Boot.ME.s2d.mouseY;
		}
	}
}

private class SymbolTile extends h2d.Object {

	public var id(default, null) : Int;

	public var currentSlot(default, null) : Null<SymbolSlot> = null;

	var shadow : HSprite;

	public function new(symbols:Symbols, id:Int) {
		super();

		this.id = id;

		shadow = Assets.tiles.h_get("symbolShadow", 0.5, 0.5, this);
		shadow.setPos(2, 2);
		shadow.alpha = 0;

		var spr = Assets.tiles.h_get("symbol", id, 0.5, 0.5, this);


		var inter = new h2d.Interactive(spr.tile.width, spr.tile.height, this);
		// inter.backgroundColor = 0x55FF00FF;
		inter.setPosition(-spr.tile.width * 0.5, -spr.tile.height * 0.5);
		inter.onPush = function (e) {
			symbols.selectSymbol(this);
			shadow.alpha = 1;
		}

		inter.onRelease = function (e) {
			if (symbols.currentTile == this)
				symbols.unselectSymbol();
		}
	}

	public function hideShadow() {
		shadow.alpha = 0;
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

		var spr = Assets.tiles.h_get("symbolSlot", 0.5, 0.5, this);
	}
}
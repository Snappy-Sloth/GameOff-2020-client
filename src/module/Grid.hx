package module;

enum CellSymbol {
	None;
	Circle;
	Triangle;
	Rectangle;
}

class Grid extends Module {

	var wrapperCell : h2d.Object;
	var cells : Array<Cell> = [];
	
	public function new() {
		super(250, 250);

		wrapperCell = new h2d.Object(root);

		for (i in 0...4) {
			for (j in 0...4) {
				var c = new Cell(i, j);
				wrapperCell.addChild(c);
				cells.push(c);
			}
		}
	}
	
	override function reset() {
		super.reset();

		for (c in cells) {
			c.reset();
		}
	}

	override function onResize() {
		super.onResize();

		wrapperCell.setPosition((wid - Cell.SQUARE_SIZE * 4) >> 1, (hei - Cell.SQUARE_SIZE * 4) >> 1);
	}
}

class Cell extends h2d.Object {

	public static var SQUARE_SIZE = 50;

	public var cx(default, null) : Int;
	public var cy(default, null) : Int;

	public var symbol(default, null) : CellSymbol = None;

	public var sprSymbol : HSprite;

	public function new(x:Int, y:Int) {
		super();

		cx = x;
		cy = y;

		var bmp = Assets.tiles.h_get("gridCell", this);

		sprSymbol = new HSprite(Assets.tiles, bmp);
		sprSymbol.setCenterRatio();
		sprSymbol.setPos(SQUARE_SIZE >> 1, SQUARE_SIZE >> 1);
		sprSymbol.visible = false;

		var inter = new h2d.Interactive(SQUARE_SIZE, SQUARE_SIZE, this);
		inter.onClick = function (e) {
			switch symbol {
				case None:
					sprSymbol.visible = true;
					symbol = Circle;
					sprSymbol.set("gridBlueCircle");
				case Circle:
					symbol = Triangle;
					sprSymbol.set("gridRedTriangle");
				case Triangle:
					symbol = Rectangle;
					sprSymbol.set("gridGreenRect");
				case Rectangle:
					symbol = None;
					sprSymbol.visible = false;
			}
		}

		setPosition(SQUARE_SIZE * cx, SQUARE_SIZE * cy);
	}

	public function reset() {
		symbol = None;
		sprSymbol.visible = false;
	}
}
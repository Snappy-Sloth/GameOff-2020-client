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
				var c = new Cell(j, i, onClick);
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
	
	function onClick(c:Cell) {
		if (Game.ME.currentTasks == null) {
			Game.ME.onError();
			return;
		}

		c.nextSymbol();

		checkValidate();
	}

	override function checkValidate() {
		super.checkValidate();

		for (t in Game.ME.currentTasks.copy()) {
			if (Data.task.get(t.taskKind).group == Data.Task_group.Grid) {
				var isValidated = true; 
				var dataText = Data.task.get(t.taskKind).data;
				var lines = dataText.split("\n");
				for (i in 0...lines.length) {
					var data = lines[i].split(" ");
					for (j in 0...data.length) {
						switch cells[i * 4 + j].symbol {
							case None: if (data[j] != "-") isValidated = false;
							case Circle: if (data[j] != "C") isValidated = false;
							case Triangle: if (data[j] != "T") isValidated = false;
							case Rectangle: if (data[j] != "R") isValidated = false;
						}
					}
				}

				if (isValidated) {
					Game.ME.onCompleteTask(t);
				}
			}
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

	public function new(x:Int, y:Int, onClick:Cell->Void) {
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
			onClick(this);
		}

		setPosition(SQUARE_SIZE * cx, SQUARE_SIZE * cy);
	}

	public function nextSymbol() {
		switch (symbol) {
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

	public function reset() {
		symbol = None;
		sprSymbol.visible = false;
	}
}
package screens;

class Manual extends dn.Process {
	public static var ME : Manual;

	public var mouseX : Float = -1;
	public var mouseY : Float = -1;

	public var currentSheet : Sheet = null;

	var arSheet : Array<Sheet> = [];

	var initialPositionX : Float;
	var initialPositionY : Float;
	var arInitialPositionX : Array<Float> = [];
	var arInitialPositionY : Array<Float> = [];

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot();

		var screen = new h2d.Interactive((w() / Const.SCALE), (h() / Const.SCALE));
		root.add(screen, 10);
		// screen.backgroundColor = 0xFFFF00FF;
		screen.propagateEvents = true;

		screen.onMove = function (e) {
			if (currentSheet != null) {
				var deltaX = e.relX - mouseX;
				var deltaY = e.relY - mouseY;
				
				currentSheet.x += deltaX;
				if (currentSheet.x < -(Const.SHEET_WIDTH / 2)) {
					currentSheet.x = -(Const.SHEET_WIDTH / 2);
				}
				else {
					if (currentSheet.x > ((w() / Const.SCALE) - (Const.SHEET_WIDTH / 2))) {
						currentSheet.x = (w() / Const.SCALE) - (Const.SHEET_WIDTH / 2);
					}
					else {
						currentSheet.rotate(deltaX * Const.SHEET_ANGLE);
					}
				}

				currentSheet.y += deltaY;
				if (currentSheet.y < -(Const.SHEET_HEIGHT / 2)) {
					currentSheet.y = -(Const.SHEET_HEIGHT / 2);
				}
				if (currentSheet.y > ((h() / Const.SCALE) - (Const.SHEET_HEIGHT / 2))) {
					currentSheet.y = (h() / Const.SCALE) - (Const.SHEET_HEIGHT / 2);
				}
			}

			mouseX = e.relX;
			mouseY = e.relY;
		};

		for (i in 0...10) {
			var sheet = new Sheet();
			
			initialPositionX = (((w() / Const.SCALE) - Const.SHEET_WIDTH) / 2) + i * 5;
			arInitialPositionX.push(initialPositionX);

			initialPositionY = (((h() / Const.SCALE) - Const.SHEET_HEIGHT) / 2) + i * 5;
			arInitialPositionY.push(initialPositionY);

			sheet.setPosition(initialPositionX, initialPositionY);

			root.add(sheet, 0);

			arSheet.push(sheet);
		}

		var sortSheetsBtn = new ui.Button("Sort", setSheetsToInitialPosition);
		sortSheetsBtn.setPosition(10, 10);
		root.add(sortSheetsBtn, 1);

		onResize();
	}

	public function selectSheet(sheet:Sheet) {
		currentSheet = sheet;
		root.add(currentSheet, 0);
	}

	public function setSheetsToInitialPosition() {
		for (i in 0...arSheet.length) {
			arSheet[i].rotation = 0;
			arSheet[i].setPosition(arInitialPositionX[i], arInitialPositionY[i]);
			root.add(arSheet[i], 0);
		}
	}

	override function onResize() {
		super.onResize();

		root.setScale(Const.SCALE);
	}
}
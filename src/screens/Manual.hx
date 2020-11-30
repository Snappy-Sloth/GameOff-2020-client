package screens;

class Manual extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	
	public var wid(get,never) : Int; inline function get_wid() return Std.int(w() / Const.SCALE);
	public var hei(get,never) : Int; inline function get_hei() return Std.int(h() / Const.SCALE);

	public static var ME : Manual;

	public var mouseX : Float = -1;
	public var mouseY : Float = -1;

	public var currentSheet : Sheet = null;

	var arSheet : Array<Sheet> = [];

	var sortSheetsBtn : ui.DebugButton;
	var goToCommBtn : ui.DebugButton;

	var mask : h2d.Mask;
	var wrapper : h2d.Layers;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot(Game.ME.wrapperScreens);
		
		mask = new h2d.Mask(w(), h(), root);

		wrapper = new h2d.Layers(mask);

		var screen = new h2d.Interactive((w() / Const.SCALE), (h() / Const.SCALE));
		wrapper.add(screen, 10);
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

		for (i in 0...6) {
			var sheet = new Sheet(5 - i);
			sheet.setPosition((((w() / Const.SCALE) - Const.SHEET_WIDTH) / 2) + i * 5, (((h() / Const.SCALE) - Const.SHEET_HEIGHT) / 2) + i * 5);

			wrapper.add(sheet, 0);

			arSheet.push(sheet);
		}

		sortSheetsBtn = new ui.DebugButton("Sort", setSheetsToInitialPosition);
		wrapper.add(sortSheetsBtn, 1);

		goToCommBtn = new ui.DebugButton("Comm", Game.ME.showComm);
		wrapper.add(goToCommBtn, 1);

		onResize();
	}

	public function selectSheet(sheet:Sheet) {
		currentSheet = sheet;
		wrapper.add(currentSheet, 0);
	}

	public function setSheetsToInitialPosition() {
		for (i in 0...arSheet.length) {
			tw.createS(arSheet[i].rotation, 0, 0.3);
			tw.createS(arSheet[i].x, ((((w() / Const.SCALE) - Const.SHEET_WIDTH) / 2) + i * 5), 0.3);
			tw.createS(arSheet[i].y, ((((h() / Const.SCALE) - Const.SHEET_HEIGHT) / 2) + i * 5), 0.3);
			wrapper.add(arSheet[i], 0);
		}
	}

	override function onResize() {
		super.onResize();

		sortSheetsBtn.setPosition(((w() / Const.SCALE) - sortSheetsBtn.wid) / 2, 7);
		goToCommBtn.setPosition(7, ((h() / Const.SCALE) - goToCommBtn.hei) / 2);

		mask.width = Std.int(w() / Const.SCALE);
		mask.height = Std.int(h() / Const.SCALE);
	}
}
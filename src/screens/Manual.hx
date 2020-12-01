package screens;

class Manual extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	
	public var wid(get,never) : Int; inline function get_wid() return Std.int(Const.AUTO_SCALE_TARGET_WID);
	public var hei(get,never) : Int; inline function get_hei() return Std.int(Const.AUTO_SCALE_TARGET_HEI);

	public static var ME : Manual;

	public var mouseX : Float = -1;
	public var mouseY : Float = -1;

	public var currentSheet : Sheet = null;

	var arSheet : Array<Sheet> = [];

	var sortSheetsBtn : ui.Button;
	var goToCommBtn : ui.ChangeScreenButton;

	var mask : h2d.Mask;
	var wrapper : h2d.Layers;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot(Game.ME.wrapperScreens);
		
		mask = new h2d.Mask(w(), h(), root);

		wrapper = new h2d.Layers(mask);

		var screen = new h2d.Interactive((Const.AUTO_SCALE_TARGET_WID), (Const.AUTO_SCALE_TARGET_HEI));
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
					if (currentSheet.x > ((Const.AUTO_SCALE_TARGET_WID) - (Const.SHEET_WIDTH / 2))) {
						currentSheet.x = (Const.AUTO_SCALE_TARGET_WID) - (Const.SHEET_WIDTH / 2);
					}
					else {
						currentSheet.rotate(deltaX * Const.SHEET_ANGLE);
					}
				}

				currentSheet.y += deltaY;
				if (currentSheet.y < -(Const.SHEET_HEIGHT / 2)) {
					currentSheet.y = -(Const.SHEET_HEIGHT / 2);
				}
				if (currentSheet.y > ((Const.AUTO_SCALE_TARGET_HEI) - (Const.SHEET_HEIGHT / 2))) {
					currentSheet.y = (Const.AUTO_SCALE_TARGET_HEI) - (Const.SHEET_HEIGHT / 2);
				}
			}

			mouseX = e.relX;
			mouseY = e.relY;
		};

		for (i in 0...12) {
			var sheet = new Sheet(11 - i);
			sheet.setPosition((((Const.AUTO_SCALE_TARGET_WID) - Const.SHEET_WIDTH) / 2) + i * 5, (((Const.AUTO_SCALE_TARGET_HEI) - Const.SHEET_HEIGHT) / 2) + i * 5);

			wrapper.add(sheet, 0);

			arSheet.push(sheet);
		}

		sortSheetsBtn = new ui.Button(Lang.t._("Ranger"), setSheetsToInitialPosition);
		wrapper.add(sortSheetsBtn, 1);

		goToCommBtn = new ui.ChangeScreenButton(this, true, Lang.t._("Comm"), Game.ME.showComm);

		onResize();
	}

	public function selectSheet(sheet:Sheet) {
		currentSheet = sheet;
		wrapper.add(currentSheet, 0);
	}

	public function setSheetsToInitialPosition() {
		for (i in 0...arSheet.length) {
			tw.createS(arSheet[i].rotation, 0, 0.3);
			tw.createS(arSheet[i].x, ((((Const.AUTO_SCALE_TARGET_WID) - Const.SHEET_WIDTH) / 2) + i * 5), 0.3);
			tw.createS(arSheet[i].y, ((((Const.AUTO_SCALE_TARGET_HEI) - Const.SHEET_HEIGHT) / 2) + i * 5), 0.3);
			wrapper.add(arSheet[i], 0);
		}
	}

	override function onResize() {
		super.onResize();

		sortSheetsBtn.setPosition(((Const.AUTO_SCALE_TARGET_WID) - sortSheetsBtn.wid) / 2, 7);
		goToCommBtn.root.setPosition(7, ((Const.AUTO_SCALE_TARGET_HEI) - goToCommBtn.hei) / 2);

		mask.width = Std.int(Const.AUTO_SCALE_TARGET_WID);
		mask.height = Std.int(Const.AUTO_SCALE_TARGET_HEI);
	}
}
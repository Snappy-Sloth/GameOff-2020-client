package screens;

class Manual extends dn.Process {
	public static var ME : Manual;

	public var mouseX : Float = -1;
	public var mouseY : Float = -1;

	public var currentSheet : Sheet = null;

	// var arSheet : Array<Sheet> = [];

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
				currentSheet.y += deltaY;
				currentSheet.rotate(deltaX * 0.001);
			}
			mouseX = e.relX;
			mouseY = e.relY;
		};

		for (i in 0...10) {
			var sheet = new Sheet();
			sheet.setPosition((((w() / Const.SCALE) - Const.SHEET_WIDTH) / 2) + i * 5,
							(((h() / Const.SCALE) - Const.SHEET_HEIGHT) / 2) + i * 5);
			root.add(sheet, 0);
		}

		onResize();
	}

	public function selectSheet(sheet:Sheet) {
		currentSheet = sheet;
		root.add(currentSheet, 0);
	}

	override function onResize() {
		super.onResize();

		root.setScale(Const.SCALE);
	}
}
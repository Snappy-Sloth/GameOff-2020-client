package screens;

class Sheet extends h2d.Layers {
	public static var ME : Sheet;

	public function new() {
		super();

		ME = this;

		var sheet = new h2d.Interactive(Const.SHEET_WIDTH, Const.SHEET_HEIGHT, this);
		sheet.backgroundColor = Color.addAlphaF(Color.randomColor(Math.random(), 0.5, 0.4));
		sheet.propagateEvents = true;

		sheet.onPush = function (e) {
			Manual.ME.selectSheet(this);
		};

		sheet.onRelease = function (e) {
			Manual.ME.currentSheet = null;			
		};
	}
}
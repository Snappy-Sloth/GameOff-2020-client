package screens;

class TitleScreen extends dn.Process {
	public static var ME : TitleScreen;

	var flow : h2d.Flow;

	public function new() {
		super(Main.ME);

		ME = this;

		createRoot();

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.horizontalAlign = Middle;
		flow.verticalSpacing = 20;

		var title = new h2d.Text(Assets.fontLarge, flow);
		title.text = "MOONSHOT";

		flow.addSpacing(30);

		var startGameBtn = new ui.Button('Game (Bunker)', Main.ME.startGame);
		flow.addChild(startGameBtn);

		// var startManualBtn = new ui.Button('Manual', Main.ME.startManual);
		// flow.addChild(startManualBtn);

		// var startCommBtn = new ui.Button('Comm', Main.ME.startComm);
		// flow.addChild(startCommBtn);

		// var startModulesBtn = new ui.Button('Modules', Main.ME.startModules);
		// flow.addChild(startModulesBtn);

		onResize();
	}

	override function onResize() {
		super.onResize();

		root.setScale(Const.SCALE);

		flow.reflow();
		flow.setPosition(Std.int((w() / Const.SCALE) - flow.outerWidth) >> 1,
						Std.int((h() / Const.SCALE) - flow.outerHeight) >> 1);
	}
}
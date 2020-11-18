package screens;

class ModuleScreen extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public static var ME : ModuleScreen;
	
	public var wid(get,never) : Int; inline function get_wid() return Std.int(w() / Const.SCALE);
	public var hei(get,never) : Int; inline function get_hei() return Std.int(h() / Const.SCALE);

	var goToCommBtn : ui.Button;

	var arModules : Array<Module> = [];

	var flowModule : h2d.Flow;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot(Game.ME.wrapperScreens);

		goToCommBtn = new ui.Button("Comm", Game.ME.showComm);
		root.add(goToCommBtn, 1);

		flowModule = new h2d.Flow(root);
		flowModule.horizontalSpacing = flowModule.verticalSpacing = 10;
		flowModule.debug = true;
		flowModule.minWidth = flowModule.maxWidth = Std.int(wid * 0.9);
		flowModule.multiline = true;

		var btnModule = new module.Buttons();
		flowModule.addChild(btnModule.root);
		arModules.push(btnModule);

		var levelModule = new module.Levers();
		flowModule.addChild(levelModule.root);
		arModules.push(levelModule);

		var gridModule = new module.Grid();
		flowModule.addChild(gridModule.root);
		arModules.push(gridModule);

		var values = new module.Values();
		flowModule.addChild(values.root);
		arModules.push(values);

		onResize();
	}

	public function reset() {
		for (module in arModules) {
			module.reset();
		}
	}

	override function onResize() {
		super.onResize();

		goToCommBtn.setPosition((w() / Const.SCALE) - goToCommBtn.wid - 7, ((h() / Const.SCALE) - goToCommBtn.hei) / 2);

		flowModule.setPosition(	Std.int((w() / Const.SCALE) - flowModule.outerWidth) >> 1,
								Std.int((h() / Const.SCALE) - flowModule.outerHeight) >> 1);
	}
}
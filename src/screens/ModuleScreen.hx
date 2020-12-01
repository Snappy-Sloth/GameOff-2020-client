package screens;

class ModuleScreen extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public static var ME : ModuleScreen;
	
	public var wid(get,never) : Int; inline function get_wid() return Std.int(Const.AUTO_SCALE_TARGET_WID);
	public var hei(get,never) : Int; inline function get_hei() return Std.int(Const.AUTO_SCALE_TARGET_HEI);

	var goToCommBtn : ui.ChangeScreenButton;

	var arModules : Array<Module> = [];

	// var flowModule : h2d.Flow;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot(Game.ME.wrapperScreens);

		goToCommBtn = new ui.ChangeScreenButton(this, false, Lang.t._("Comm"), Game.ME.showComm);

		var wrapperModule = new h2d.Object(root);
		wrapperModule.x = 20;

		var bg = Assets.tiles.h_get("bgModules", wrapperModule);

		var btnModule = new module.Buttons();
		wrapperModule.addChild(btnModule.root);
		btnModule.root.setPosition(28, 71);
		arModules.push(btnModule);

		var levelModule = new module.Levers();
		wrapperModule.addChild(levelModule.root);
		levelModule.root.setPosition(780, 481);
		arModules.push(levelModule);

		var gridModule = new module.Grid();
		wrapperModule.addChild(gridModule.root);
		gridModule.root.setPosition(560, 73);
		arModules.push(gridModule);

		var values = new module.Values();
		wrapperModule.addChild(values.root);
		values.root.setPosition(22, 399);
		arModules.push(values);

		var symbols = new module.Symbols();
		wrapperModule.addChild(symbols.root);
		symbols.root.setPosition(21, 232);
		arModules.push(symbols);

		var numPad = new module.NumPad();
		wrapperModule.addChild(numPad.root);
		numPad.root.setPosition(829, 77);
		arModules.push(numPad);

		var wires = new module.Wires();
		wrapperModule.addChild(wires.root);
		wires.root.setPosition(564, 343);
		arModules.push(wires);

		var gauges = new module.Gauges();
		wrapperModule.addChild(gauges.root);
		gauges.root.setPosition(241, 231);
		arModules.push(gauges);

		var bars = new module.Bars();
		wrapperModule.addChild(bars.root);
		bars.root.setPosition(780, 344);
		arModules.push(bars);

		onResize();
	}

	public function reset() {
		for (module in arModules) {
			module.reset();
		}
	}

	override function onResize() {
		super.onResize();

		goToCommBtn.root.setPosition((Const.AUTO_SCALE_TARGET_WID) - goToCommBtn.wid, ((Const.AUTO_SCALE_TARGET_HEI) - goToCommBtn.hei) / 2);

		// flowModule.setPosition(	Std.int((Const.AUTO_SCALE_TARGET_WID) - flowModule.outerWidth) >> 1,
		// 						Std.int((Const.AUTO_SCALE_TARGET_HEI) - flowModule.outerHeight) >> 1);
	}
}
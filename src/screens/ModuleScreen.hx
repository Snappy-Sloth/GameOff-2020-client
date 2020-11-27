package screens;

class ModuleScreen extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public static var ME : ModuleScreen;
	
	public var wid(get,never) : Int; inline function get_wid() return Std.int(w() / Const.SCALE);
	public var hei(get,never) : Int; inline function get_hei() return Std.int(h() / Const.SCALE);

	var goToCommBtn : ui.Button;

	var arModules : Array<Module> = [];

	// var flowModule : h2d.Flow;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot(Game.ME.wrapperScreens);

		goToCommBtn = new ui.Button("Comm", Game.ME.showComm);
		root.add(goToCommBtn, 1);

		// flowModule = new h2d.Flow(root);
		// flowModule.horizontalSpacing = flowModule.verticalSpacing = 10;
		// // flowModule.debug = true;
		// flowModule.minWidth = flowModule.maxWidth = Std.int(wid * 0.8);
		// flowModule.multiline = true;

		var wrapperModule = new h2d.Object(root);
		wrapperModule.y = 40;

		var btnModule = new module.Buttons();
		wrapperModule.addChild(btnModule.root);
		btnModule.root.setPosition(28, 31);
		arModules.push(btnModule);

		var levelModule = new module.Levers();
		wrapperModule.addChild(levelModule.root);
		levelModule.root.setPosition(780, 441);
		arModules.push(levelModule);

		var gridModule = new module.Grid();
		wrapperModule.addChild(gridModule.root);
		gridModule.root.setPosition(560, 33);
		arModules.push(gridModule);

		var values = new module.Values();
		wrapperModule.addChild(values.root);
		values.root.setPosition(22, 359);
		arModules.push(values);

		var symbols = new module.Symbols();
		wrapperModule.addChild(symbols.root);
		symbols.root.setPosition(21, 192);
		arModules.push(symbols);

		var numPad = new module.NumPad();
		wrapperModule.addChild(numPad.root);
		numPad.root.setPosition(829, 37);
		arModules.push(numPad);

		var wires = new module.Wires();
		wrapperModule.addChild(wires.root);
		wires.root.setPosition(564, 303);
		arModules.push(wires);

		var gauges = new module.Gauges();
		wrapperModule.addChild(gauges.root);
		gauges.root.setPosition(241, 191);
		arModules.push(gauges);

		var bars = new module.Bars();
		wrapperModule.addChild(bars.root);
		bars.root.setPosition(780, 304);
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

		goToCommBtn.setPosition((w() / Const.SCALE) - goToCommBtn.wid - 7, ((h() / Const.SCALE) - goToCommBtn.hei) / 2);

		// flowModule.setPosition(	Std.int((w() / Const.SCALE) - flowModule.outerWidth) >> 1,
		// 						Std.int((h() / Const.SCALE) - flowModule.outerHeight) >> 1);
	}
}
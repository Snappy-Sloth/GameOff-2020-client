package screens;

class ModuleScreen extends dn.Process {
	public static var ME : ModuleScreen;

	var goToCommBtn : ui.Button;

	var arModules : Array<Module> = [];

	var flowModule : h2d.Flow;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot();

		goToCommBtn = new ui.Button("Comm", Game.ME.showComm);
		root.add(goToCommBtn, 1);

		flowModule = new h2d.Flow(root);

		var btnModule = new module.Buttons();
		flowModule.addChild(btnModule.root);
		arModules.push(btnModule);

		onResize();
	}

	public function reset() {
		for (module in arModules) {
			module.reset();
		}
	}

	override function onResize() {
		super.onResize();

		root.setScale(Const.SCALE);

		goToCommBtn.setPosition((w() / Const.SCALE) - goToCommBtn.wid - 7, ((h() / Const.SCALE) - goToCommBtn.hei) / 2);

		flowModule.setPosition(	Std.int((w() / Const.SCALE) - flowModule.outerWidth) >> 1,
								Std.int((h() / Const.SCALE) - flowModule.outerHeight) >> 1);
	}
}
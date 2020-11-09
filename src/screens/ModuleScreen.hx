package screens;

class ModuleScreen extends dn.Process {
	public static var ME : ModuleScreen;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot();
	}
}
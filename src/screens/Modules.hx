package screens;

class Modules extends dn.Process {
	public static var ME : Modules;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot();
	}
}
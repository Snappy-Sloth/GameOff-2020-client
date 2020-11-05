package screens;

class Communication extends dn.Process {
	public static var ME : Communication;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot();
	}
}
package screens;

class Manual extends dn.Process {
    public static var ME : Manual;

    public function new() {
        super(Game.ME);

        ME = this;

        createRoot();
    }
}
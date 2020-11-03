class Modules extends dn.Process {
    public static var ME : Modules;

    public function new() {
        super(Main.ME);

        ME = this;
    }
}
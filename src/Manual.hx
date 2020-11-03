class Manual extends dn.Process {
    public static var ME : Manual;

    public function new() {
        super(Main.ME);

        ME = this;
    }
}
class Communication extends dn.Process {
    public static var ME : Communication;

    public function new() {
        super(Main.ME);

        ME = this;
    }
}
package ui;

class TitleScreen extends dn.Process {
    public static var ME : TitleScreen;

    var flow : h2d.Flow;

    public function new() {
        super(Main.ME);

        ME = this;

        createRoot();

        flow = new h2d.Flow(root);
        flow.layout = Vertical;
        flow.horizontalAlign = Middle;
        flow.verticalSpacing = 20;

        var title = new h2d.Text(Assets.fontLarge, flow);
        title.text = "MOONSHOT";

        flow.addSpacing(30);

        var startGameBtn = new Button('Start', Main.ME.startGame);
        flow.addChild(startGameBtn);

        onResize();
    }

    override function onResize() {
        super.onResize();

        root.setScale(Const.SCALE);

        flow.reflow();
        flow.setPosition(Std.int((w() / Const.SCALE) - flow.outerWidth) >> 1,
                        Std.int((h() / Const.SCALE) - flow.outerHeight) >> 1);
    }
}
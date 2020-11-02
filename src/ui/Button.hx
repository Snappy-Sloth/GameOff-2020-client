package ui;

class Button extends h2d.Layers {
    public static var ME : Button;

    public var wid(default, null) : Int;
    public var hei(default, null) : Int;

    public function new(str:String, onClick:Void->Void, ?wid:Int = Const.BUTTON_WIDTH, ?hei:Int = Const.BUTTON_HEIGHT) {
        super();

        ME = this;

        this.wid = wid;
        this.hei = hei;

        var inter = new h2d.Interactive(wid, hei, this);
        inter.backgroundColor = 0xFF7F7F7F;
        inter.onClick = (e)->onClick();

        var text = new h2d.Text(Assets.fontPixel, this);
        text.text = str;
        text.textAlign = Center;
        text.maxWidth = wid;
        text.setPosition(0, Std.int((hei - text.textHeight) / 2));
    }
}
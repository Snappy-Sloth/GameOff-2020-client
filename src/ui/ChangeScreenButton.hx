package ui;

class ChangeScreenButton extends dn.Process {
    public var wid(default, null) : Int;
	public var hei(default, null) : Int;

	public var clickEnable(default, set) : Bool;
	inline function set_clickEnable(v:Bool) {
		inter.visible = v;
		return v;
	}

	var inter : h2d.Interactive;

	var mouseIsOver : Bool = false;

	var mTime = 0.;

	var spr : HSprite;
	var text : h2d.Text;

	public function new(p:dn.Process, isLeft:Bool, str:String, onClick:Void->Void) {
		super(p);

		createRootInLayers(p.root, 1);

		var idSpr = "changeScreenBtn" + (isLeft ? "Left" : "Right");

		spr = Assets.tiles.h_get(idSpr /* + "Idle" */);
		root.add(spr, 1);
		
		// wid = Std.int(spr.tile.width);
		// hei = Std.int(spr.tile.height);
		wid = 114;
		hei = 500;

		inter = new h2d.Interactive(wid, hei);
		// inter.backgroundColor = 0x55FF00FF;
		inter.onClick = (e)->onClick();
		root.add(inter, 0);

		text = new h2d.Text(Assets.fontRulergold16);
		text.text = str;
		text.textColor = 0xFFFFFF;
		text.alpha = 0;
		text.dropShadow = {dx: 1, dy: 1, alpha: 1, color: 0};
		root.add(text, 2);

		inter.onOver = function (e) {
			mouseIsOver = true;

			text.y = ((hei >> 1) - text.textHeight - 75) + 10;
			tw.createS(text.alpha, 1, 0.2);
			tw.createS(text.y, text.y - 10, 0.2);
		}
		inter.onOut = function (e) {
			mouseIsOver = false;
			tw.createS(text.alpha, 0, 0.2);
			tw.createS(text.y, text.y - 10, 0.2);
		}

		onResize();
	}

	override function onResize() {
		super.onResize();

		spr.setPos(Std.int(wid - spr.tile.width) >> 1, Std.int(hei - spr.tile.height) >> 1);

		text.x = Std.int(wid - text.textWidth) >> 1;
		text.y = (hei >> 1) - text.textHeight - 75;
	}

	override function update() {
		super.update();

		if (mouseIsOver) {
			mTime += tmod;

			spr.x = (Std.int(wid - spr.tile.width) >> 1) + Math.sin(mTime / 10) * 5;
		}
	}
}
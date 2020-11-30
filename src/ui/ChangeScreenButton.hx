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

	public function new(p:dn.Process, isLeft:Bool, str:String, onClick:Void->Void) {
		super(p);

		createRootInLayers(p.root, 1);

		var idSpr = "changeScreenBtn" + (isLeft ? "Left" : "Right");

		spr = Assets.tiles.h_get(idSpr /* + "Idle" */);
		root.add(spr, 1);
		
		wid = Std.int(spr.tile.width);
		hei = Std.int(spr.tile.height);

		inter = new h2d.Interactive(wid, hei);
		inter.backgroundColor = 0x55FF00FF;
		inter.onClick = (e)->onClick();
		root.add(inter, 0);

		var text = new h2d.Text(Assets.fontRulergold16);
		text.text = str;
		text.textColor = 0xFFFFFF;
		// text.setPosition(((wid/2)-(text.textWidth/2)), (hei/2)-(text.textHeight/2));
		text.dropShadow = {dx: 1, dy: 1, alpha: 1, color: 0};
		root.add(text, 2);

		inter.onOver = function (e) {
			mouseIsOver = true;
		}
		inter.onOut = function (e) {
			mouseIsOver = false;
		}

		/* inter.onRelease = inter.onOver = function (e) {
			// text.y = (hei/2)-(text.textHeight/2);
			// spr.set(idSpr + "Over");
			// Assets.CREATE_SOUND(hxd.Res.sfx.overButton, OverButton);
		}
		inter.onReleaseOutside = inter.onOut = function (e) {
			// text.y = (hei/2)-(text.textHeight/2);
			// spr.set(idSpr + "Idle");
		}
		inter.onPush = function (e) {
			// text.y = (hei/2)-(text.textHeight/2) + 3;
			// spr.set(idSpr + "Press");
			// Assets.CREATE_SOUND(hxd.Res.sfx.clickButton, ClickButton);
		} */
	}

	override function update() {
		super.update();

		if (mouseIsOver) {
			mTime += tmod;

			spr.x = Math.sin(mTime / 5) * 5;
		}
	}
}
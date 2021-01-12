package ui;

class Button extends h2d.Layers {
    public var wid(default, null) : Int;
	public var hei(default, null) : Int;

	public var clickEnable(default, set) : Bool;
	inline function set_clickEnable(v:Bool) {
		inter.visible = v;
		return v;
	}

	var inter : h2d.Interactive;

	public function new(str:String, onClick:Void->Void) {
		super();

		var idSpr = "btn";

		var spr = Assets.tiles.h_get(idSpr + "Idle");
		this.add(spr, 1);
		
		wid = Std.int(spr.tile.width);
		hei = Std.int(spr.tile.height);

		inter = new h2d.Interactive(wid, hei);
		inter.onClick = function (e) {
			onClick();
			Assets.CREATE_SOUND(hxd.Res.sfx.ui_click, UI_Click);	
		};
		this.add(inter, 0);

		var text = new h2d.Text(Assets.fontRulergold16);
		text.text = str;
		text.textColor = 0xfffbc2;
		text.setPosition(((wid/2)-(text.textWidth/2)), (hei/2)-(text.textHeight/2));
		text.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x845034};
		this.add(text, 2);

		inter.onRelease = inter.onOver = function (e) {
			text.y = (hei/2)-(text.textHeight/2);
			// spr.set(idSpr + "Over");
			// Assets.CREATE_SOUND(hxd.Res.sfx.overButton, OverButton);
		}
		inter.onReleaseOutside = inter.onOut = function (e) {
			text.y = (hei/2)-(text.textHeight/2);
			spr.set(idSpr + "Idle");
		}
		inter.onPush = function (e) {
			text.y = (hei/2)-(text.textHeight/2) + 3;
			spr.set(idSpr + "Press");
			// Assets.CREATE_SOUND(hxd.Res.sfx.clickButton, ClickButton);
		}
    }
}
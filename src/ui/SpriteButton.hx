package ui;

class SpriteButton extends h2d.Object{

	public var wid(default, null) : Int;
	public var hei(default, null) : Int;
	
	public function new(spr:String, onClick:Void->Void) {
		super();

		var spr = Assets.tiles.h_get(spr, this);

		wid = Std.int(spr.tile.width);
		hei = Std.int(spr.tile.height);

		var inter = new h2d.Interactive(wid, hei, this);

		inter.onClick = function (e) {
			onClick();
			Assets.CREATE_SOUND(hxd.Res.sfx.ui_click, UI_Click);
		}
	}

}
package ui;

class SpriteButton extends h2d.Object{
	
	public function new(spr:String, onClick:Void->Void) {
		super();

		var spr = Assets.tiles.h_get(spr, this);

		var inter = new h2d.Interactive(spr.tile.width, spr.tile.height, this);

		inter.onClick = function (e) {
			onClick();
		}
	}

}
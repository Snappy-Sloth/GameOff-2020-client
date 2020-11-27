package screens;

class Sheet extends h2d.Layers {
	public static var ME : Sheet;
	
	public var wid(get,never) : Int; inline function get_wid() return Const.SHEET_WIDTH;
	public var hei(get,never) : Int; inline function get_hei() return Const.SHEET_HEIGHT;

	public function new(id:Int) {
		super();

		ME = this;

		var sheet = new h2d.Interactive(Const.SHEET_WIDTH, Const.SHEET_HEIGHT, this);

		var glowOver = Assets.tiles.h_get("pageGlowOver", 0.5, 0.5, this);
		glowOver.setPos(wid >> 1, hei >> 1);
		glowOver.visible = false;
		
		var glowMove = Assets.tiles.h_get("pageGlowMove", 0.5, 0.5, this);
		glowMove.setPos(wid >> 1, hei >> 1);
		glowMove.visible = false;
		
		var glowNormal = Assets.tiles.h_get("pageGlowNormal", 0.5, 0.5, this);
		glowNormal.setPos(wid >> 1, hei >> 1);
		
		var spr = new h2d.Bitmap(hxd.Res.load("manual/fr/manualPage" + id + ".png").toTile(), this);
		spr.setScale(0.5);

		sheet.onOver = function(e) {
			if (Manual.ME.currentSheet == null) {
				glowNormal.visible = false;
				glowOver.visible = true;
			}
		}
		sheet.onOut = function(e) {
			if (Manual.ME.currentSheet == null) {
				glowNormal.visible = true;
				glowOver.visible = false;
			}
		}
		
		sheet.onPush = function (e) {
			Manual.ME.selectSheet(this);
			glowOver.visible = false;
			glowNormal.visible = false;
			glowMove.visible = true;
		};
		
		sheet.onRelease = function (e) {
			Manual.ME.currentSheet = null;	
			glowMove.visible = false;
			glowOver.visible = true;
		};
	}
}
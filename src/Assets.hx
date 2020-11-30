import dn.heaps.slib.*;

class Assets {
	public static var fontPixel : h2d.Font;
	public static var fontTiny : h2d.Font;
	public static var fontSmall : h2d.Font;
	public static var fontMedium : h2d.Font;
	public static var fontLarge : h2d.Font;
	public static var tiles : SpriteLib;

	public static var fontSinsgold16 : h2d.Font;
	public static var fontSinsgold32 : h2d.Font;
	public static var fontRulergold16 : h2d.Font;
	public static var fontRulergold32 : h2d.Font;
	public static var fontRulergold48 : h2d.Font;
	public static var fontRise32 : h2d.Font;

	static var initDone = false;
	public static function init() {
		if( initDone )
			return;
		initDone = true;

		fontPixel = hxd.Res.fonts.minecraftiaOutline.toFont();
		fontTiny = hxd.Res.fonts.barlow_condensed_medium_regular_9.toFont();
		fontSmall = hxd.Res.fonts.barlow_condensed_medium_regular_11.toFont();
		fontMedium = hxd.Res.fonts.barlow_condensed_medium_regular_17.toFont();
		fontLarge = hxd.Res.fonts.barlow_condensed_medium_regular_32.toFont();
		tiles = dn.heaps.assets.Atlas.load("atlas/tiles.atlas");

		fontSinsgold16 = hxd.Res.fonts.sinsgold_medium_16.toFont();
		fontSinsgold32 = hxd.Res.fonts.sinsgold_medium_32.toFont();
		fontRulergold16 = hxd.Res.fonts.rulergold_medium_16.toFont();
		fontRulergold32 = hxd.Res.fonts.rulergold_medium_32.toFont();
		fontRulergold48 = hxd.Res.fonts.rulergold_medium_48.toFont();
		fontRise32 = hxd.Res.fonts.rise_regular_32.toFont();
	}

	public static function CREATE_SOUND(sndFile:hxd.res.Sound, vg:VolumeGroup, loop:Bool = false, playNow:Bool = true, isMusic:Bool = false) : dn.heaps.Sfx {
		var snd = new dn.heaps.Sfx(sndFile);
		snd.groupId = vg.getIndex();
		dn.heaps.Sfx.setGroupVolume(snd.groupId, GET_VOLUME(vg) * (isMusic ? Const.OPTIONS_DATA.MUSIC_VOLUME : Const.OPTIONS_DATA.SFX_VOLUME));
		playNow ? snd.play(loop) : snd.stop();

		return snd;
	}

	public static function GET_VOLUME(vg:VolumeGroup) {
		return dn.Lib.getEnumMetaFloat(vg, "volume");
	}
}
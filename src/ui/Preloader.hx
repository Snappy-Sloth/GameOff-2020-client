package ui;

class Preloader extends hxd.fmt.pak.Loader {

	var text : h2d.Text;
	
	public function new(s2d:h2d.Scene, onDone) {
		super(s2d, onDone);

		text = new h2d.Text(hxd.res.DefaultFont.get(), this);
	}

	override function updateBG(progress:Float) {
		// super.updateBG(progress);
		text.text = Std.string(Std.int(progress * 100));
	}

}
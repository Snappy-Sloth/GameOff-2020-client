haxe -hl hxd.fmt.pak.Build.hl -lib heaps -main hxd.fmt.pak.Build
hl hxd.fmt.pak.Build.hl
rename res.null.pak res.pak
del /Q /S redist\hl
haxelib run redisthelper -o redist\hl -p AreYouThere hl.dx.hxml
move res.pak redist\hl\directx\AreYouThere
package {

	import flash.display.MovieClip;
	import fl.containers.ScrollPane;


	public dynamic
	class Versions extends MovieClip {

		public var scroll: ScrollPane;

		public function Versions() {
			super();
			var myMovieClip: MovieClip = new MovieClip();
			myMovieClip.graphics.beginFill(0xFF0000);
			myMovieClip.graphics.drawRect(0, 0, 500, 500);
			myMovieClip.graphics.endFill();
			scroll.source = myMovieClip;
			trace("test")
		}
	}

}
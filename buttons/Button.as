package buttons {
    import flash.display.DisplayObjectContainer
	import flash.display.MovieClip;
    import flash.events.*

	public class Button extends MovieClip {

        private var slot_id:int

        private var clip:MovieClip

        private var mouse_click_function:Function;


		public function Button(param1:MovieClip, param2:int, param3:Function) {
            super();
            this.clip = param1;
            this.slot_id = param2;
			this.mouse_click_function = param3;
			this.clip.buttonMode = true;
			this.clip.useHandCursor = true;
			this.clip.mouseChildren = false;
            this.clip.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDown, false, 0, true);
        }

        public function setVisible(param1:Boolean): void {
            this.clip.visible = param1;
        }
	
        private function mouseDown(param1:MouseEvent): void {
            if (this.mouse_click_function){
                this.mouse_click_function(param1, this.slot_id)
            }
        }

        public function get slot(): int {
            return this.slot_id;
        }
    }
}
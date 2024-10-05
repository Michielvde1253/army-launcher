package {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.utils.getDefinitionByName;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.permissions.PermissionStatus;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.ByteArray;
	import fl.containers.ScrollPane;
	import flash.text.TextField;
	import com.coltware.airxzip.*;
	import buttons.*;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.InvokeEvent;
	import flash.desktop.NativeApplication;
	import flash.net.navigateToURL;
	import flash.errors.IOError;

	public class Main extends MovieClip {

		public static var mInstance: Main;

		private static const COUNT_VERSION_SLOTS: int = 10;

		private var home: MovieClip;

		private var load: MovieClip;

		private var mButtonNews: MovieClip;

		private var mButtonVersions: MovieClip;

		private var mButtonMods: MovieClip;

		private var mFrameNews: MovieClip;

		private var mFrameVersions: MovieClip;

		private var mFrameMods: MovieClip;

		private var mPopupSetup: MovieClip;

		private var mPopupSetupButtonOk: MovieClip;

		private var mPopupNotFound: MovieClip;

		private var mPopupNotFoundButtonOk: MovieClip;

		private var mWarningNoInternet: MovieClip;

		private var mScrollPane: ScrollPane;

		private var mScrollPaneMods: ScrollPane;

		private var mFrameVersionsInner: MovieClip;

		private var mFrameModsInner: MovieClip;

		public var mVersionData: * ;

		public var mOldVersionData: * ;

		public var mImages: * ;

		public var mImagesLoaded: int = 0;

		public var mNeedsUpdate: Array = [];

		private var mVersionSlots: Array = [];

		private var progressPercent: Number = 0;

		private var zipData: ByteArray;

		private var downloading: Boolean = false;

		private var download_type: String; // zip or exe

		private var active_download_progress_bar: MovieClip;

		private var active_download_version_slot: int;

		private var not_found_slot_id: int;
		
		var snowballs: Array = [];

		private var numberOfSnowballs: int = 50;

		public function Main() {
			super();
			mInstance = this;
			var loadClass: Class = getDefinitionByName("Loading") as Class;
			this.load = new loadClass() as MovieClip;
			addChild(this.load as DisplayObject);
			var homeClass: Class = getDefinitionByName("Home") as Class;
			this.home = new homeClass() as MovieClip;
			addChild(this.home as DisplayObject);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}

		private function onAddedToStage(param1: Event): void {
			// //////////////////
			// Init variables //
			// //////////////////
			this.home.visible = false;
			this.mButtonNews = this.home.getChildByName("Button_News") as MovieClip;
			this.mButtonNews.buttonMode = true;
			this.mButtonNews.useHandCursor = true;
			this.mButtonNews.mouseChildren = false;
			this.mButtonNews.addEventListener(MouseEvent.MOUSE_DOWN, this.onNewsClicked, false, 0, true);
			this.mButtonNews.addEventListener(MouseEvent.MOUSE_OVER, this.onHoverButton, false, 0, true);
			this.mButtonNews.addEventListener(MouseEvent.MOUSE_OUT, this.onOutButton, false, 0, true);

			this.mButtonVersions = this.home.getChildByName("Button_Versions") as MovieClip;
			this.mButtonVersions.buttonMode = true;
			this.mButtonVersions.useHandCursor = true;
			this.mButtonVersions.mouseChildren = false;
			this.mButtonVersions.addEventListener(MouseEvent.MOUSE_DOWN, this.onVersionsClicked, false, 0, true);
			this.mButtonVersions.addEventListener(MouseEvent.MOUSE_OVER, this.onHoverButton, false, 0, true);
			this.mButtonVersions.addEventListener(MouseEvent.MOUSE_OUT, this.onOutButton, false, 0, true);

			this.mButtonMods = this.home.getChildByName("Button_Mods") as MovieClip;
			this.mButtonMods.buttonMode = true;
			this.mButtonMods.useHandCursor = true;
			this.mButtonMods.mouseChildren = false;
			this.mButtonMods.addEventListener(MouseEvent.MOUSE_DOWN, this.onModsClicked, false, 0, true);
			this.mButtonMods.addEventListener(MouseEvent.MOUSE_OVER, this.onHoverButton, false, 0, true);
			this.mButtonMods.addEventListener(MouseEvent.MOUSE_OUT, this.onOutButton, false, 0, true);

			this.mFrameNews = this.home.getChildByName("Frame_News") as MovieClip;
			this.mFrameVersions = this.home.getChildByName("Frame_Versions") as MovieClip;
			this.mFrameMods = this.home.getChildByName("Frame_Mods") as MovieClip;
			this.mFrameVersions.visible = true;
			this.mFrameMods.visible = false;
			this.mFrameNews.visible = false;

			this.mPopupSetup = this.home.getChildByName("Popup_Setup") as MovieClip;
			this.mPopupSetup.visible = false;

			this.mPopupNotFound = this.home.getChildByName("Popup_Not_Found") as MovieClip;
			this.mPopupNotFound.visible = false;

			this.mWarningNoInternet = this.home.getChildByName("Warning_No_Internet") as MovieClip;
			this.mWarningNoInternet.visible = false;

			this.mPopupSetupButtonOk = this.mPopupSetup.getChildByName("Button_Ok") as MovieClip;
			this.mPopupSetupButtonOk.addEventListener(MouseEvent.MOUSE_DOWN, this.onSetupOkClicked, false, 0, true);
			this.mPopupSetupButtonOk.buttonMode = true;
			this.mPopupSetupButtonOk.useHandCursor = true;
			this.mPopupSetupButtonOk.mouseChildren = false;

			this.mPopupNotFoundButtonOk = this.mPopupNotFound.getChildByName("Button_Ok") as MovieClip;
			this.mPopupNotFoundButtonOk.addEventListener(MouseEvent.MOUSE_DOWN, this.onNotFoundOkClicked, false, 0, true);
			this.mPopupNotFoundButtonOk.buttonMode = true;
			this.mPopupNotFoundButtonOk.useHandCursor = true;
			this.mPopupNotFoundButtonOk.mouseChildren = false;

			this.mScrollPane = this.mFrameVersions.getChildByName("scroll") as ScrollPane;
			var innerFrame: Class = getDefinitionByName("VersionsInner") as Class;
			this.mFrameVersionsInner = new innerFrame() as MovieClip;
			this.mScrollPane.source = this.mFrameVersionsInner;

			this.mScrollPaneMods = this.mFrameMods.getChildByName("scroll") as ScrollPane;
			var innerFrame_mods: Class = getDefinitionByName("ModsInner") as Class;
			this.mFrameModsInner = new innerFrame_mods() as MovieClip;
			this.mScrollPaneMods.source = this.mFrameModsInner;

			// //////////////////////
			// Load versions file //
			// //////////////////////
			var jsonURL: String = "https://pastebin.com/raw/5PZ0QvLM";
			var request: URLRequest = new URLRequest(jsonURL);
			var loader: URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onJSONLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(request);

			var i:int = 0;
			while(i < this.numberOfSnowballs){
				this.createSnowball();
				i++
			}
			addEventListener(Event.ENTER_FRAME, updateSnowfall);			

		}

		private function onHoverButton(param1: MouseEvent): void {
			param1.target.addEventListener(Event.ENTER_FRAME, zoomIn);
			param1.target.removeEventListener(Event.ENTER_FRAME, zoomOut);
		}

		private function onOutButton(param1: MouseEvent): void {
			param1.target.addEventListener(Event.ENTER_FRAME, zoomOut);
			param1.target.removeEventListener(Event.ENTER_FRAME, zoomIn);
		}

		private function zoomIn(param1: Event): void {
			param1.target.scaleX += 0.04;
			param1.target.scaleY += 0.04;

			if (param1.target.scaleX >= 1.16) {
				param1.target.scaleX = 1.16;
				param1.target.scaleY = 1.16;
				param1.target.removeEventListener(Event.ENTER_FRAME, zoomIn);
			}
		}

		private function zoomOut(param1: Event): void {
			param1.target.scaleX -= 0.05;
			param1.target.scaleY -= 0.05;

			if (param1.target.scaleX <= 1) {
				param1.target.scaleX = 1;
				param1.target.scaleY = 1;
				param1.target.removeEventListener(Event.ENTER_FRAME, zoomOut);
			}
		}

		public function onNewsClicked(param1: MouseEvent): void {
			//this.hideAllFrames();
			//this.mFrameNews.visible = true;
			navigateToURL(new URLRequest("https://armyattack.me/news"))
		}

		private function onVersionsClicked(param1: MouseEvent): void {
			this.hideAllFrames();
			this.mFrameVersions.visible = true;
			this.mFrameVersions.alpha = 0;
			this.mFrameVersions.addEventListener(Event.ENTER_FRAME, fadeIn);
		}

		private function onModsClicked(param1: MouseEvent): void {
			this.hideAllFrames();
			this.mFrameMods.visible = true;
			this.mFrameMods.alpha = 0;
			this.mFrameMods.addEventListener(Event.ENTER_FRAME, fadeIn);
		}

		private function onDownloadClicked(param1: MouseEvent, param2: int): void {
			if (!downloading) {
				this.downloading = true;
				this.active_download_version_slot = param2;
				var icon_download: Button = this.mVersionSlots[param2]["icon_download"] as Button;
				icon_download.setVisible(false);

				var icon_play: Button = this.mVersionSlots[param2]["icon_play"] as Button;
				icon_play.setVisible(false);

				this.active_download_progress_bar = this.mVersionSlots[param2]["icon_progress_bar"] as MovieClip;
				this.active_download_progress_bar.visible = true;
				this.active_download_progress_bar.gotoAndStop(1);

				//this.downloadZip(mVersionData["game"][param2]["url"]);
				this.downloadZip("https://github.com/Mima2370/army-client/releases/download/v21.1/AA21_1_release_android_HR.apk");
			}
		}

		private function onPlayClicked(param1: MouseEvent, param2: int): void {
			CONFIG::BUILD_FOR_WINDOWS {
				if (NativeProcess.isSupported) {
					// Legacy = pre version 20 (with flash player projector)
					var is_legacy: Boolean = mVersionData["game"][param2]["type"] == "legacy"

					if (is_legacy) {
						var file: File = File.userDirectory.resolvePath("AppData/Local/Programs/ArmyAttack" + mVersionData["game"][param2]["id"].toString() + "/assets/flashplayer_32_sa.exe");
					} else {
						var file: File = File.applicationStorageDirectory.resolvePath(mVersionData["game"][param2]["id"].toString() + "/Army Attack.exe")
					}
					try {
						var nativeProcessStartupInfo: NativeProcessStartupInfo = new NativeProcessStartupInfo();
						nativeProcessStartupInfo.executable = file;
					} catch (error: ArgumentError) { // File not found
						this.not_found_slot_id = param2;
						this.mPopupNotFound.visible = true;
						return;
					}
					if (is_legacy) {
						var args: Vector.<String> = new Vector.<String>();
						args.push(File.userDirectory.resolvePath("AppData/Local/Programs/ArmyAttack" + mVersionData["game"][param2]["id"].toString() + "/assets/iArmyAirOffline.swf").nativePath);
						nativeProcessStartupInfo.arguments = args;
					}

					var process: NativeProcess = new NativeProcess();
					process.start(nativeProcessStartupInfo);
				}
			}

			CONFIG::BUILD_FOR_ANDROID {

			}
		}

		private function onSetupOkClicked(param1: MouseEvent): void {
			this.mVersionSlots[this.active_download_version_slot]["textfield_extra"].text = "";
			if (NativeProcess.isSupported) {
				var file: File = File.applicationStorageDirectory.resolvePath("temp.exe");

				var nativeProcessStartupInfo: NativeProcessStartupInfo = new NativeProcessStartupInfo();
				nativeProcessStartupInfo.executable = file;

				var process: NativeProcess = new NativeProcess();

				process.start(nativeProcessStartupInfo);

			}
			this.mPopupSetup.visible = false;
		}

		private function onNotFoundOkClicked(param1: MouseEvent): void {
			var i: * = 0;
			for (i in mOldVersionData["game"]) {
				if (mOldVersionData["game"][i]["id"] == mVersionData["game"][this.not_found_slot_id]["id"]) {
					mOldVersionData["game"][i]["is_latest"] = "not_installed";
					mOldVersionData["game"][i]["installedVersion"] = "not_installed";
				}
			}
			var file: File = File.applicationStorageDirectory.resolvePath("installed.txt");
			// Save new versions file
			file.addEventListener(PermissionEvent.PERMISSION_STATUS, saveOldVersionsOnPermission);
			file.requestPermission();
			this.mVersionSlots[this.not_found_slot_id]["icon_progress_bar"].visible = false;
			this.mVersionSlots[this.not_found_slot_id]["icon_download"].setVisible(true);
			this.mVersionSlots[this.not_found_slot_id]["icon_play"].setVisible(false);
			this.mPopupNotFound.visible = false;
		}

		private function hideAllFrames(): void {
			this.mFrameNews.visible = false;
			this.mFrameVersions.visible = false;
			this.mFrameMods.visible = false;
		}

		// ///////////////////////////////
		// Helper functions for images //
		// ///////////////////////////////

		private function loadImage(url: String): void {
			// Downloads version images from the internet
			var request: URLRequest = new URLRequest(url);
			var loader: Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageIOError);
			loader.load(request);
		}

		private function onImageIOError(event: IOErrorEvent): void {
			trace("Could not load image");
			this.mScrollPane.source = this.mFrameVersionsInner;
			this.mScrollPaneMods.source = this.mFrameModsInner;
		}

		private function onImageLoadComplete(event: Event): void {
			// Show the downloaded images on the stage
			var loader: Loader = event.target.loader as Loader;
			mImages[event.target.url] = loader;
			mImagesLoaded++;

			if (mImagesLoaded == mVersionData["game"].length) {
				// Setup version list images
				var i: int = 1;

				while (i <= mVersionData["game"].length) {
					var mc: MovieClip = this.mVersionSlots[i - 1]["slotClip"].getChildByName("Container_Icon_Mask").getChildByName("Container_Icon") as MovieClip;
					var image: DisplayObject = mImages[mVersionData["game"][i - 1]["image"]];
					mc.addChild(image);
					i++;
				}
				this.mScrollPane.source = this.mFrameVersionsInner;
				this.mScrollPaneMods.source = this.mFrameModsInner;

			}
		}

		// /////////////////////////////////////
		// Helper functions for versions JSON //
		// /////////////////////////////////////

		private function onJSONLoadComplete(event: Event): void {
			var loader: URLLoader = URLLoader(event.target);
			mVersionData = JSON.parse(loader.data);
			trace("JSON data loaded successfully");
			this.initVersions();
		}

		private function initVersions(): void {
			var i: int = 0;
			var v: int = 1;
			var m: int = 1;
			while (i < mVersionData["game"].length) {
				if (mVersionData["game"][i]["is_mod"]) {
					var item: * = {};
					var slot: MovieClip = this.mFrameModsInner.getChildByName("Slot_" + m.toString()) as MovieClip;
					item["slotClip"] = slot;
					m++;
				} else {
					var item: * = {};
					var slot: MovieClip = this.mFrameVersionsInner.getChildByName("Slot_" + v.toString()) as MovieClip;
					item["slotClip"] = slot;
					v++;
				}
				this.mVersionSlots.push(item);
				i++;
			}
			while (v <= COUNT_VERSION_SLOTS) {
				this.mFrameVersionsInner.removeChild(this.mFrameVersionsInner.getChildByName("Slot_" + v.toString()) as MovieClip);
				v++
			}
			while (m <= COUNT_VERSION_SLOTS) {
				this.mFrameModsInner.removeChild(this.mFrameModsInner.getChildByName("Slot_" + m.toString()) as MovieClip);
				m++
			}
			// Load old versions file
			var file: File = File.applicationStorageDirectory.resolvePath("installed.txt");
			if (file.exists) {
				file.addEventListener(PermissionEvent.PERMISSION_STATUS, openOldVersionsOnPermission);
				file.requestPermission();
			} else {
				mOldVersionData = {};
				mOldVersionData["game"] = new Array();
				this.compareVersions();

			}

			// Save new versions file
			file.addEventListener(PermissionEvent.PERMISSION_STATUS, saveOldVersionsOnPermission);
			file.requestPermission();

			var file1: File = File.applicationStorageDirectory.resolvePath("versions.txt");

			// Save new versions file
			file1.addEventListener(PermissionEvent.PERMISSION_STATUS, saveVersionsOnPermission);
			file1.requestPermission();
		}

		private function onIOError(e: IOErrorEvent): void {
			trace("There was an internet error.")
			this.mWarningNoInternet.visible = true;
			var file1: File = File.applicationStorageDirectory.resolvePath("versions.txt");

			file1.addEventListener(PermissionEvent.PERMISSION_STATUS, openVersionsOnPermission);
			file1.requestPermission();

			this.initVersions();
		}

		private function openOldVersionsOnPermission(e: PermissionEvent): void {
			var file: File = e.target as File;
			file.removeEventListener(PermissionEvent.PERMISSION_STATUS, openOldVersionsOnPermission);
			if (e.status == PermissionStatus.GRANTED) {
				var fs: FileStream = new FileStream();
				fs.open(file, FileMode.READ);
				mOldVersionData = JSON.parse(fs.readUTFBytes(fs.bytesAvailable));
				fs.close();
			}
			this.compareVersions();
		}

		private function openVersionsOnPermission(e: PermissionEvent): void {
			var file: File = e.target as File;
			file.removeEventListener(PermissionEvent.PERMISSION_STATUS, openVersionsOnPermission);
			if (e.status == PermissionStatus.GRANTED) {
				var fs: FileStream = new FileStream();
				fs.open(file, FileMode.READ);
				mVersionData = JSON.parse(fs.readUTFBytes(fs.bytesAvailable));
				fs.close();
			}
		}

		private function saveOldVersionsOnPermission(e: PermissionEvent): void {
			var file: File = e.target as File;
			file.removeEventListener(PermissionEvent.PERMISSION_STATUS, saveOldVersionsOnPermission);
			if (e.status == PermissionStatus.GRANTED) {

				var fileStream: FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeUTFBytes(mOldVersionData);
				fileStream.close();

				var bytearray: ByteArray = new ByteArray();
				bytearray.writeUTF(mOldVersionData);
				var stream: FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(JSON.stringify(mOldVersionData));
				stream.close();

			}
		}

		private function saveVersionsOnPermission(e: PermissionEvent): void {
			var file: File = e.target as File;
			file.removeEventListener(PermissionEvent.PERMISSION_STATUS, saveVersionsOnPermission);
			if (e.status == PermissionStatus.GRANTED) {

				var fileStream: FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeUTFBytes(mVersionData);
				fileStream.close();

				var bytearray: ByteArray = new ByteArray();
				bytearray.writeUTF(mOldVersionData);
				var stream: FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(JSON.stringify(mVersionData));
				stream.close();

			}
		}

		// //////////////////////////////////////////////////////////////////
		// Helper function for comparing old and downloaded versions file //
		// //////////////////////////////////////////////////////////////////

		private function compareVersions(): void {
			// Compare with new data
			mImages = {};
			var i: * = 0;
			var listVersionsOld: Array = [];
			var listLatestVersionsOld: Array = [];
			for (i in mOldVersionData["game"]) {
				listVersionsOld.push(mOldVersionData["game"][i]["id"].toString());
				listLatestVersionsOld.push(mOldVersionData["game"][i]["installedVersion"].toString());
			}
			i = 0;

			var listVersions: Array = [];

			for (i in mVersionData["game"]) {
				var id: String = mVersionData["game"][i]["id"];

				var latestVersion: String = mVersionData["game"][i]["latestVersion"];

				listVersions.push(id);
				this.loadImage(mVersionData["game"][i]["image"]);
				var textfield_name: TextField = this.mVersionSlots[i]["slotClip"].getChildByName("Text_Name") as TextField;
				this.mVersionSlots[i]["textfield_name"] = textfield_name;
				textfield_name.text = mVersionData["game"][i]["name"];

				var textfield_description: TextField = this.mVersionSlots[i]["slotClip"].getChildByName("Text_Description") as TextField;
				this.mVersionSlots[i]["textfield_description"] = textfield_description;
				textfield_description.text = mVersionData["game"][i]["description"];

				var textfield_extra: TextField = this.mVersionSlots[i]["slotClip"].getChildByName("Text_Extra") as TextField;
				this.mVersionSlots[i]["textfield_extra"] = textfield_extra;
				textfield_extra.text = "";

				var textfield_version: TextField = this.mVersionSlots[i]["slotClip"].getChildByName("Text_Version") as TextField;
				this.mVersionSlots[i]["textfield_version"] = textfield_extra;
				textfield_version.text = "v" + mVersionData["game"][i]["versionTag"];
				textfield_version.x = textfield_name.x + textfield_name.textWidth + 16

				var border_version: MovieClip = this.mVersionSlots[i]["slotClip"].getChildByName("Border_Version") as MovieClip;
				this.mVersionSlots[i]["border_version"] = border_version;
				border_version.width = textfield_version.textWidth;
				border_version.x = textfield_name.x + textfield_name.textWidth + 20

				var border_version_left: MovieClip = this.mVersionSlots[i]["slotClip"].getChildByName("Border_Version_Left") as MovieClip;
				this.mVersionSlots[i]["border_version_left"] = border_version_left;
				border_version_left.x = textfield_name.x + textfield_name.textWidth + 20

				var border_version_right: MovieClip = this.mVersionSlots[i]["slotClip"].getChildByName("Border_Version_Right") as MovieClip;
				this.mVersionSlots[i]["border_version_right"] = border_version_right;
				border_version_right.x = textfield_name.x + textfield_name.textWidth + border_version_left.width + textfield_version.textWidth + 10

				var icon_download: Button = new Button(this.mVersionSlots[i]["slotClip"].getChildByName("Icon_Download") as MovieClip, i, this.onDownloadClicked);
				this.mVersionSlots[i]["icon_download"] = icon_download;
				var icon_play: Button = new Button(this.mVersionSlots[i]["slotClip"].getChildByName("Icon_Play") as MovieClip, i, this.onPlayClicked);
				this.mVersionSlots[i]["icon_play"] = icon_play;
				var icon_progress_bar: MovieClip = this.mVersionSlots[i]["slotClip"].getChildByName("Icon_Progress_Bar") as MovieClip;
				this.mVersionSlots[i]["icon_progress_bar"] = icon_progress_bar;
				trace(JSON.stringify(listLatestVersionsOld))
				trace(latestVersion.toString())
				if (listVersionsOld.indexOf(id.toString()) == -1) {
					// New release, needs download
					var update: * = {};

					update["id"] = id;

					update["installedVersion"] = "not_installed";

					update["is_latest"] = "not_installed";

					mOldVersionData["game"].push(update);

					icon_download.setVisible(true);
					icon_play.setVisible(false);
					icon_progress_bar.visible = false;
					textfield_extra.text = "";
				} else if (listLatestVersionsOld.indexOf(latestVersion.toString()) == -1) {
					// Already seen but not installed or new update
					var j: * = 0;

					for (j in mOldVersionData["game"]) {
						if (mOldVersionData["game"][j]["id"] == id && (mOldVersionData["game"][j]["installedVersion"] != "not_installed")) {
							mOldVersionData["game"][j]["is_latest"] = false;
						}
					}
					icon_download.setVisible(true);
					icon_play.setVisible(false);
					icon_progress_bar.visible = false;
					trace(id)
					trace(JSON.stringify(mOldVersionData["game"][i]["installedVersion"]))
					if (mOldVersionData["game"][i]["installedVersion"] == "not_installed") {
						textfield_extra.text = "";
					} else {
						textfield_extra.text = "Update available";
					}
				} else {
					icon_download.setVisible(false);
					icon_play.setVisible(true);
					icon_progress_bar.visible = false;
					textfield_extra.text = "";
				}
			}

			// Wait 0.6 seconds before continuing, so that the loading screen looks a bit better when using a fast internet connection
			var waitUntil: int = getTimer() + 600;
			while (getTimer() < waitUntil) {}
			this.home.alpha = 0;
			this.home.visible = true;
			this.home.addEventListener(Event.ENTER_FRAME, fadeIn);
		}

		private function fadeIn(param1: Event): void {
			// Increase the alpha value
			param1.target.alpha += 0.05; // Adjust the increment for desired speed

			// Once alpha reaches 1 (fully opaque), remove the event listener
			if (param1.target.alpha >= 1) {
				param1.target.alpha = 1; // Ensure alpha doesn't exceed 1
				param1.target.removeEventListener(Event.ENTER_FRAME, fadeIn);
			}
		}

		///////////////////////////////////////////////
		// Helper functions for downloading the game //
		///////////////////////////////////////////////
		private function downloadZip(url: String): void {
			var zipLoader: URLLoader = new URLLoader();
			var request: URLRequest = new URLRequest(url);

			if (url.indexOf(".zip") >= 0) {
				this.download_type = "zip";
			} else if (url.indexOf(".exe") >= 0) {
				this.download_type = "exe";
			} else if (url.indexOf(".apk") >= 0) {
				this.download_type = "apk";
			} else {
				this.download_type = "";
			}

			this.mVersionSlots[this.active_download_version_slot]["textfield_extra"].text = "Downloading...";

			zipLoader.dataFormat = URLLoaderDataFormat.BINARY;
			zipLoader.addEventListener(Event.COMPLETE, this.onDownloadComplete);
			zipLoader.addEventListener(ProgressEvent.PROGRESS, this.onDownloadProgress);
			zipLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onDownloadError);
			zipLoader.load(request);
		}

		private function onDownloadProgress(event: ProgressEvent): void {
			this.progressPercent = (event.bytesLoaded / event.bytesTotal) * 100;
			if (this.progressPercent == 100) {
				this.active_download_progress_bar.gotoAndStop(1);
			} else {
				this.active_download_progress_bar.gotoAndStop(Math.ceil(this.progressPercent));
			}
			trace("Download progress: " + this.progressPercent + "%");
		}

		private function onDownloadComplete(event: Event): void {
			trace("Download complete!");
			var zipLoader: URLLoader = URLLoader(event.target);
			this.zipData = zipLoader.data
			var targetDirectory: File = File.applicationStorageDirectory.resolvePath("temp." + this.download_type);
			targetDirectory.addEventListener(PermissionEvent.PERMISSION_STATUS, onDownloadPermission);
			targetDirectory.requestPermission();
		}


		private function onDownloadPermission(e: PermissionEvent): void {
			var file: File = e.target as File;
			file.removeEventListener(PermissionEvent.PERMISSION_STATUS, onDownloadPermission);
			if (e.status == PermissionStatus.GRANTED) {
				var stream: FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeBytes(this.zipData);
				stream.close();
				this.zipData = null;
				if (this.download_type == "zip") {
					this.mVersionSlots[this.active_download_version_slot]["textfield_extra"].text = "Extracting...";
					this.unzipFile(file);
					this.mVersionSlots[this.active_download_version_slot]["textfield_extra"].text = "";
				} else if (this.download_type == "exe") {
					this.mPopupSetup.visible = true;
				} else if (this.download_type == "apk") {
					var apkFile: File = File.applicationStorageDirectory.resolvePath("temp.apk");
					trace("does this work?")
					trace(apkFile.nativePath)
					// Construct the intent to install the APK
					var installIntent: InvokeEvent = new InvokeEvent(InvokeEvent.INVOKE, false, false, ["android.intent.action.VIEW", apkFile.nativePath]);

					// Add the necessary MIME type for APK installation
					installIntent.mimeType = "application/vnd.android.package-archive";

					// Send the intent to Android's package installer
					NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, function (e: InvokeEvent): void {
						NativeApplication.nativeApplication.invoke(installIntent);
					});
				}
				this.mVersionSlots[this.active_download_version_slot]["icon_progress_bar"].visible = false;
				this.mVersionSlots[this.active_download_version_slot]["icon_download"].setVisible(false);
				this.mVersionSlots[this.active_download_version_slot]["icon_play"].setVisible(true);
				var i: * = 0;
				for (i in mOldVersionData["game"]) {
					if (mOldVersionData["game"][i]["id"] == mVersionData["game"][this.active_download_version_slot]["id"]) {
						mOldVersionData["game"][i]["is_latest"] = true;
						mOldVersionData["game"][i]["installedVersion"] = mVersionData["game"][this.active_download_version_slot]["latestVersion"];
					}
				}
				var file: File = File.applicationStorageDirectory.resolvePath("installed.txt");
				// Save new versions file
				file.addEventListener(PermissionEvent.PERMISSION_STATUS, saveOldVersionsOnPermission);
				file.requestPermission();
			}
			this.downloading = false;
		}

		private function onDownloadError(event: IOErrorEvent): void {
			trace("Download failed: " + event.text);
		}

		private function unzipFile(file: File): void {
			var reader: ZipFileReader = new ZipFileReader();
			reader.open(file);

			var list: Array = reader.getEntries();
			var i: int = 0;

			for each(var entry: ZipEntry in list) {
				this.progressPercent = (i / list.length) * 100;
				this.active_download_progress_bar.gotoAndStop(Math.ceil(this.progressPercent));

				var filename: String = entry.getFilename();

				if (entry.isDirectory()) {

					trace("DIR  --->" + entry.getFilename());
					//  If entry is directory
					var dir: File = File.applicationStorageDirectory.resolvePath(filename);
					dir.createDirectory();
				} else {
					trace("FILE --->" + entry.getFilename() + "(" + entry.getCompressRate() + ")");
					var unzippedBytes: ByteArray = reader.unzip(entry);
					//trace("btyes --->" + unzippedBytes);
					var file2: File = File.applicationStorageDirectory.resolvePath(entry.getFilename());
					var fs: FileStream = new FileStream();
					fs.open(file2, FileMode.WRITE);
					fs.writeBytes(unzippedBytes, 0, unzippedBytes.length);
					fs.close();
				}
				i++
			}
			reader.close();
			file.deleteFile();
		}

		////////////////////////////////////////
		// Helper functions for the snow balls /
		////////////////////////////////////////

		private function createSnowball(): void {
			var snowball: snow = new snow(); // Create new instance of Snowball
			snowball.x = Math.random() * stage.stageWidth; // Randomize horizontal position
			snowball.y = Math.random() * -stage.stageHeight; // Start from random height above the stage
			snowball.scaleX = snowball.scaleY = Math.random() * 0.5 + 0.5; // Randomize size
			snowball.speed = Math.random() * 3 + 1; // Randomize fall speed
			snowballs.push(snowball); // Add snowball to array
			addChildAt(snowball, 1); // Add snowball to the stage
		}

		private function updateSnowfall(event: Event): void {
			for (var i: int = 0; i < snowballs.length; i++) {
				var snowball: snow = snowballs[i];
				snowball.y += snowball.speed; // Move snowball downwards

				// If the snowball goes off the bottom of the stage, reposition it to the top
				if (snowball.y > stage.stageHeight) {
					snowball.y = -snowball.height; // Place it above the stage
					snowball.x = Math.random() * stage.stageWidth; // Randomize horizontal position again
				}
			}
		}

	}
}
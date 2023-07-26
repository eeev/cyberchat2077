module CyberChat.Localization.Packages
import Codeware.Localization.*

public class English extends ModLocalizationPackage {
	protected func DefineTexts() {
		this.Text("CyberChat-Action-Label", "Messages");

		this.Text("CyberChat-Popup-Title", "Messages");
		this.Text("CyberChat-Popup-Fluff-Right", "> CyberChat (dev)");
		this.Text("CyberChat-Popup-Fluff-Bottom",
			"May occasionally produce harmful instructions or biased content.\n" +
			"Limited knowledge of world and events after 2077.\n" +
			"May occasionally generate incorrect information.");

		this.Text("CyberChat-ButtonBasics-Event-Ready", "All buttons are ready");
		this.Text("CyberChat-ButtonBasics-Event-Click", "Click");
		this.Text("CyberChat-ButtonBasics-Event-Enable", "Enable");
		this.Text("CyberChat-ButtonBasics-Event-Disable", "Disable");
		
		this.Text("CyberChat-ButtonBasics-Button-Right", "Send");

		this.Text("CyberChat-ButtonBasics-Action-Interact", "Interact");
		this.Text("CyberChat-ButtonBasics-Action-Enable", "Enable");
		this.Text("CyberChat-ButtonBasics-Action-Disable", "Disable");

		this.Text("CyberChat-ColorPalette-Event-Ready", "Palette created");

		this.Text("CyberChat-CursorState-Event-Ready", "Cursor tracking started");

		this.Text("CyberChat-InputText-Event-Ready", "Text input is ready");
		this.Text("CyberChat-InputText-Input-Label", "Reply");
	}
}

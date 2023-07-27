module CyberChat
import CyberChat.Workbench.*
import CyberChat.Practices.*
import Codeware.Localization.*
import Codeware.UI.*

/*

	This project is based on the Ink Playground example given by psiberx:
	https://github.com/psiberx/cp2077-playground

*/

// This is not used anymore
@wrapMethod(UIInGameNotificationQueue)
protected cb func OnUINotification(evt: ref<UIInGameNotificationEvent>) -> Bool {
	wrappedMethod(evt);
}

/*

	The CyberChatPopup class does the following:
		1) Provides static Show() function, which instantiates/creates a new popup
		2) Instantiates a workbench and associated UI elements on its creation

*/
public class CyberChatPopup extends InGamePopup {
	protected let m_header: ref<InGamePopupHeader>;
	protected let m_footer: ref<InGamePopupFooter>;
	protected let m_content: ref<InGamePopupContent>;
	protected let m_workbench: ref<Workbench>;
	protected let m_translator: ref<LocalizationSystem>;

	protected let m_this: ref<CyberChatPopup>;

	protected cb func OnCreate() {
		super.OnCreate();

		this.m_translator = LocalizationSystem.GetInstance(this.GetGame());

		this.m_container.SetHeight(1600.0);

		this.m_header = InGamePopupHeader.Create();
		this.m_header.SetTitle(this.m_translator.GetText("CyberChat-Popup-Title"));
		this.m_header.SetFluffRight(this.m_translator.GetText("CyberChat-Popup-Fluff-Right"));
		this.m_header.Reparent(this);

		this.m_footer = InGamePopupFooter.Create();
		this.m_footer.SetFluffIcon(n"fluff_triangle2");
		this.m_footer.SetFluffText(this.m_translator.GetText("CyberChat-Popup-Fluff-Bottom"));
		this.m_footer.Reparent(this);

		this.m_content = InGamePopupContent.Create();
		this.m_content.Reparent(this);

		this.m_workbench = Workbench.Create();
		this.m_workbench.SetSize(this.m_content.GetSize());
		this.m_workbench.SetTranslator(this.m_translator);
		this.m_workbench.Reparent(this.m_content);

		// Instantiates UI elements
		this.m_workbench.AddPractice(new Chat());
		// No need to display cursor coordinates, except for debug purposes
		//this.m_workbench.AddPractice(new CursorState());
	}


	protected cb func OnInitialize() {
		super.OnInitialize();

		this.m_workbench.SetHints(this.m_footer.GetHints());
	}

	public func UseCursor() -> Bool {
		return true;
	}

	public static func Show(requester: ref<inkGameController>) {
		let popup = new CyberChatPopup(); // This static function is called on every action (holding R in this case) and creates a new popup class instance

		// Pass popup options
		//popup.SetOption1(param1);

		popup.Open(requester);
	}
}

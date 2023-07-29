module CyberChat.Practices
import CyberChat.Workbench.Practice
import CyberChat.Config.*
import Codeware.UI.*

// Little workaround to stop displaying our dummy notifications
@wrapMethod(UIInGameNotificationQueue)
protected cb func OnUINotification(evt: ref<UIInGameNotificationEvent>) -> Bool {
	if StrLen(evt.m_title) == 0 && Equals(evt.m_notificationType, UIInGameNotificationType.GenericNotification) {
		// Ignore all notifications with an empty title pls
		// Proof that gamedevs do not use the same workaround: Even notifications with an empty title are displayed
		// SHOULD be safe for now..
	}else {
		// Continue handling, else we won't receive any notifications anymore
		wrappedMethod(evt);
	}
}

/*

	The Chat class brings all chat window components, their layout and logic handling.
	It also maintains a loop to refresh the interface periodically, as dictated by the updateInterval() in the config.

*/
public class Chat extends Practice {
	//protected let m_top: wref<inkCompoundWidget>;
	protected let m_cols: wref<inkCompoundWidget>;
	//protected let m_group: wref<inkCompoundWidget>;

	public let m_input: ref<TextInput>;
	public let m_text: ref<inkText>;
	public let m_text2: ref<inkText>;

	protected cb func OnCreate() {
		let root = new inkCanvas();
		root.SetName(this.GetClassName());
		root.SetAnchor(inkEAnchor.Fill);

		/*

		(root)_________________________
		
		---------------------
		| top
		|
		|	<logo> <name, handle>
		|	
		---------------------
		| center
		|
		|			<request>
		|	<response>
		|
		---------------------
		| bottom
		|
		|	---------------------
		|	| cols
		|	|
		|	|	<input> <sendButton>
		|	|
		|	---------------------
		|
		---------------------

		_______________________________

		*/
		
		let bottom = new inkVerticalPanel();
		bottom.SetName(n"bottom");
		bottom.SetFitToContent(true);
		bottom.SetAnchor(inkEAnchor.BottomCenter);
		bottom.SetAnchorPoint(new Vector2(0.5, 1.00));
		bottom.SetChildMargin(new inkMargin(0.0, 30.0, 0.0, 30.0));
		bottom.Reparent(root);

		let top = new inkVerticalPanel();
		top.SetName(n"group");
		top.SetFitToContent(true);
		top.SetAnchor(inkEAnchor.TopCenter);
		top.SetAnchorPoint(new Vector2(0.5, 0.0));
		top.SetChildMargin(new inkMargin(0.0, 30.0, 0.0, 30.0)); //8.0, 0.0 8.0, 48.0
		top.Reparent(root);

		let center = new inkVerticalPanel();
		center.SetName(n"center");
		center.SetFitToContent(true);
		center.SetAnchor(inkEAnchor.Centered);
		center.SetAnchorPoint(new Vector2(0.5, 0.5));
		center.SetChildMargin(new inkMargin(0.0, 30.0, 0.0, 30.0)); //8.0, 0.0 8.0, 48.0
		center.Reparent(root);

		let cols = new inkHorizontalPanel();
		cols.SetFitToContent(true);
		cols.SetHAlign(inkEHorizontalAlign.Center);
		cols.SetChildMargin(new inkMargin(20.0, 0.0, 20.0, 0.0));
		cols.Reparent(bottom);

		let cols2 = new inkHorizontalPanel();
		cols2.SetFitToContent(true);
		cols2.SetHAlign(inkEHorizontalAlign.Center);
		cols2.SetChildMargin(new inkMargin(20.0, 0.0, 20.0, 0.0));
		cols2.Reparent(top);

		let input = HubTextInput.Create();
		input.SetText("");
		input.Reparent(cols);

		this.m_input = input;

		let sendButton = SimpleButton.Create();
		sendButton.SetName(n"sendButton");
		sendButton.SetText(this.GetLocalizedText("CyberChat-ButtonBasics-Button-Right"));
		sendButton.ToggleAnimations(true);
		sendButton.ToggleSounds(true);
		sendButton.Reparent(cols);

		let logo = new inkImage();
		logo.SetName(n"logo");
		logo.SetAtlasResource(chatPartnerIconPath());
		logo.SetTexturePart(chatPartnerIconName());
		logo.SetAnchor(inkEAnchor.TopLeft);
		logo.SetAnchorPoint(new Vector2(0.0, 0.0));
		logo.SetSize(new Vector2(450.0 / 1.5, 450.0 / 1.5)); // Division for smaller images-
		logo.SetInteractive(true);
		logo.Reparent(cols2);

		let nameDisplay = new inkText();
		nameDisplay.SetWrapping(true, 500.0); //700.0
        nameDisplay.SetFitToContent(true);
		nameDisplay.SetVAlign(inkEVerticalAlign.Center);
        nameDisplay.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        nameDisplay.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        nameDisplay.BindProperty(n"tintColor", n"MainColors.Blue");
        nameDisplay.BindProperty(n"fontWeight", n"MainColors.BodyFontWeight");
        nameDisplay.SetFontSize(50);
        nameDisplay.Reparent(cols2);
		nameDisplay.SetText(chatPartnerFullName() + "\n" + "(" + chatPartnerHandle() + ")");
		
		// At most ~800 characters:
        //text.SetText("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.");
		// Note that this number only applies to a single response text field, if we trick the system we can get two in a row
		// which adds up to more than 800, hence the text will glitch outside its boundaries.. might fix in the future..

		let text = new inkText();
		text.SetWrapping(true, 1000.0); //700.0
        text.SetFitToContent(true);
		text.SetContentHAlign(inkEHorizontalAlign.Right);
        text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        text.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        text.BindProperty(n"tintColor", n"MainColors.Red");
        text.BindProperty(n"fontWeight", n"MainColors.BodyFontWeight");
        text.BindProperty(n"fontSize", n"MainColors.ReadableSmall");
        text.Reparent(center);

		let text2 = new inkText();
		text2.SetWrapping(true, 1000.0); //700.0
        text2.SetFitToContent(true);
        text2.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        text2.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        text2.BindProperty(n"tintColor", n"MainColors.Red");
        text2.BindProperty(n"fontWeight", n"MainColors.BodyFontWeight");
        text2.BindProperty(n"fontSize", n"MainColors.ReadableSmall");
        text2.Reparent(center);

		this.m_text2 = text2; // Refers to response
		this.m_text = text; // Refers to request

		this.UpdateChat(); // Populates the chat window with CyberAI data

		//this.m_top = top;
		this.m_cols = cols;

		this.SetRootWidget(root);
	}

	protected cb func OnInitialize() {
		//this.RegisterListeners(this.m_top);
		this.RegisterListeners(this.m_cols); // Meaning mostly button callback registering, see below

		this.Log(this.GetLocalizedText("CyberChat-ButtonBasics-Event-Ready"));
	}

	protected func RegisterListeners(container: wref<inkCompoundWidget>) {
		let childIndex: Int32 = 0;
		let numChildren: Int32 = container.GetNumChildren();

		while childIndex < numChildren {
			let widget = container.GetWidgetByIndex(childIndex);
			let button = widget.GetController() as CustomButton;

			if IsDefined(button) {
				button.RegisterToCallback(n"OnBtnClick", this, n"OnClick");
				button.RegisterToCallback(n"OnRelease", this, n"OnRelease");
				button.RegisterToCallback(n"OnEnter", this, n"OnEnter");
				button.RegisterToCallback(n"OnLeave", this, n"OnLeave");

				// We register a callback to UINotifications here.
				// Currently, I am not sure how to do timing, delays or cron jobs in redscript, hence we delay our update with a notification.
				button.RegisterToCallback(n"OnUINotification", this, n"OnUINotification");
			}

			childIndex += 1;
		}
	}

	/* 

		Hooking this is generally pretty safe:
		This hook is only relevant when the whole class is instanced, but if it is instanced, OnCreate was called and the handle to m_text exists.
		Of course, there could be some other random notification coming in but that would only lead to a potentially empty variable update.
		So for a short amount of time, the window could be empty in the worst case. It will then soon be updated correctly.
	
		One issue: Every notification triggers an auto-save it seems??? So we may consider changing the notification type.

		Now since we introduced an interval by re-sending the dummy notification, this is still safe:
			- again, this function callback is only relevant if the class is instantiated (i.e., chat window is open)
			- hence, it will cease to update when we close it
			- but then again, it will update as soon as we open it

	*/
	protected cb func OnUINotification(evt: ref<UIInGameNotificationEvent>) -> Bool {
		this.UpdateChat();

		let dummyEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
		dummyEvent.m_notificationType = UIInGameNotificationType.GenericNotification;
		dummyEvent.m_title = "";
		dummyEvent.m_overrideCurrentNotification = true;
		dummyEvent.m_additionalInfo = "dummy";
		GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, dummyEvent, updateInterval(), false);

		//LogChannel(n"DEBUG", ">>> update evt received.. " );
	}

	// This function updates the chat window with the latest CyberAI entries:
	protected func UpdateChat() {
		/*

			To elaborate on the terminology of response/request:
				- there are only two text fields which are labeled accordingly
				- they may be populated differently than request/response originally indicated
				- hence, request line is simply the last chat history line prior to the response line
				- the response line is simply the last chat history entry
				- these can both be sent by either the user directly, or responses received from OpenAI

		*/
		let lastResponseLine = [""];
		let lastRequestLine = [""];
		let lastResponse = "";
		let lastRequest = "";

		let historyArray = GetHistory(chatID());
		let i = 0;

		for line in historyArray {
			//LogChannel(n"DEBUG", ">>> history line " + i + " : " + line[1]);
			lastResponseLine = line;

			if i == (ArraySize(historyArray) - 2) {
				lastRequestLine = line;
			}

			i = i + 1;
		}

		lastResponse = lastResponseLine[1];
		lastRequest = lastRequestLine[1]; // The request line is always the one prior to the response line

		//LogChannel(n"DEBUG", ">>> LAST request sender " + lastRequestLine[0]);
		//LogChannel(n"DEBUG", ">>> LAST response sender "+ lastResponseLine[0]);

		/*

			Added additional checks, since updateInterval is MUCH smaller:
			User sends a message, Interface is updated before answer arrives -> Request is now on the bottom (used to be always on top).
			Hence, the descriptor needs to be dynamic and adjust to whatever is in the actual chat history (here: "Assistant" or "User").
		
		*/
		if StrLen(lastResponse) > 1 {
			if Equals(lastResponseLine[0], "Assistant") {
				this.m_text2.SetText(chatPartnerFullName() + ":\n" + lastResponse);
			}else {
				this.m_text2.SetText("You:\n" + lastResponse);
			}
		} else {
			// Logically, if there is no last response, then there is no last request. Therefore, set the initial text value here:
			this.m_text2.SetText("This is the beginning of your conversation with\n" + chatPartnerFullName() + " (" + chatPartnerHandle() + ")");
		}
		if StrLen(lastRequest) > 1 {
			if Equals(lastRequestLine[0], "Assistant") {
				this.m_text.SetText(chatPartnerFullName() + ":\n" + lastRequest);
			}else {
				this.m_text.SetText("You:\n" + lastRequest);
			}
		} else {
			this.m_text.SetText("");
		}
	}

	protected cb func OnClick(widget: wref<inkWidget>) -> Bool {
		let button = widget.GetController() as CustomButton;

		let buttonName = button.GetText();
		let buttonEvent = this.GetLocalizedText("CyberChat-ButtonBasics-Event-Click");

		this.Log(buttonName + ": " + buttonEvent);

		// This is whatever the user input into the text field.
		let userTextInput = this.m_input.GetText();

		// Now we handle the send request.
		// 1) Check if user input is empty (empty input is not sent out to chatGPT).
		if StrLen(userTextInput) > 1 {
			// 2) Check for commands in user input
			switch userTextInput {
				case "/flush":
					this.m_input.SetText("");

					LogChannel(n"DEBUG", "[CyberChat] Flushing chat with id " + chatID());
					FlushChat(chatID());
					this.UpdateChat();

					break;
				case "/update":
					this.m_input.SetText("");

					LogChannel(n"DEBUG", "[CyberChat] Manual update requested");
					this.UpdateChat();

					break;
				default:
					// 3) Set user input as 'sent' message and clear previous response.
					this.m_text.SetText("You:\n" + userTextInput);
					this.m_text2.SetText("");
					// 4) Check if a dialogue with this NPC already exists in CyberAIs local storage.
					if StrLen(GetHistoryAsString(chatID())) <= 1 {
						// Case 1: The Dialogue does not exist yet, hence, include a primer to inform ChatGPT about its role.
						ScheduleChatCompletionRequest(chatID(), [["System", chatPartnerGPTPrimer()],["System", chatGeneralGPTPrimer()],["User", userTextInput]]);
					} else {
						// Case 2: Simply send user input towards the existing conversation. This saves a lot of tokens over time.
						ScheduleChatCompletionRequest(chatID(), [["User", userTextInput]]);
					}	

						// Wanted functionality; after sending anything, clear the text input so we don't have to do it manually each time & input is not sent twice accidentally.
						this.m_input.SetText("");

							// We formulate a generic notification event (old!)
							/*
							let notifyEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
							notifyEvent.m_notificationType = UIInGameNotificationType.GenericNotification;
							notifyEvent.m_title = "New message from " + chatPartnerFullName() + "!";
							*/

							// We formulate a dummy notification event
							let dummyEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
							dummyEvent.m_notificationType = UIInGameNotificationType.GenericNotification;
							dummyEvent.m_title = "";
							dummyEvent.m_overrideCurrentNotification = true;
							dummyEvent.m_additionalInfo = "dummy";

							// We need to get the player game object (subclass of entity?) so the delay event will stay alive, more on that below.
							let localPlayer: wref<GameObject>;
							localPlayer = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();

							// This used to be done twice but currently, there is no need for it
							//GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(localPlayer, dummyEvent, updateInterval(), false);
							GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, dummyEvent, updateInterval(), false);

							/*

								There are 2 cases that need to be covered after the delayed message is dispatched:
									a) The popup is closed within 8 seconds. Hence, this handle is destroyed and cannot enter the response.
										=> Once the popup is opened again, it will updateChat() => OK
									b) The popup remains open as the user expects the response to show up.
										=> The dummy event is dispatched & the popup UI receives an update with the response because its context 
										is still delivered in the second dispatched event
										=> The dummy event will call itself again after updateInterval() and at some point updateChat() => (OK)

								A little workaround but it remains still relatively efficient.

							*/
					break;
			}	
		}
	}

	protected cb func OnRelease(evt: ref<inkPointerEvent>) -> Bool {
		let button = evt.GetTarget().GetController() as CustomButton;

		if evt.IsAction(n"popup_moveUp") {
			button.SetDisabled(!button.IsDisabled());

			let buttonName: String = button.GetText();
			let buttonEvent: String = button.IsDisabled()
				? this.GetLocalizedText("CyberChat-ButtonBasics-Event-Disable")
				: this.GetLocalizedText("CyberChat-ButtonBasics-Event-Enable");

			this.Log(buttonName + ": " + buttonEvent);
			this.UpdateHints(button);

			this.PlaySound(n"MapPin", n"OnCreate");
		}
	}

	protected cb func OnEnter(evt: ref<inkPointerEvent>) -> Bool {
		let button = evt.GetTarget().GetController() as CustomButton;

		this.UpdateHints(button);
	}

	protected cb func OnLeave(evt: ref<inkPointerEvent>) -> Bool {
		this.RemoveHints();
	}

	protected func UpdateHints(button: ref<CustomButton>) {
		this.UpdateHint(
			n"popup_moveUp",
			this.GetLocalizedText(
				button.IsEnabled()
					? "CyberChat-ButtonBasics-Action-Disable"
					: "CyberChat-ButtonBasics-Action-Enable"
			)
		);

		this.UpdateHint(
			n"click",
			this.GetLocalizedText("CyberChat-ButtonBasics-Action-Interact"),
			button.IsEnabled()
		);
	}

	protected func RemoveHints() {
		this.RemoveHint(n"popup_moveUp");
		this.RemoveHint(n"click");
	}
}

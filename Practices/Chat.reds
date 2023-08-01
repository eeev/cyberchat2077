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

	The Profile class is instantiated and populated for each chat metadata entry previously defined by cyberchat2077-ext.
	It is then stored in a hash-map for fast retrieval.

*/
public class Profile {
	public let m_handle: String;
	public let m_name: String;
	public let m_logo: CName;
	public let m_primer1: String;
	public let m_primer2: String;

	public static func Create(handle: String, name: String, logo: CName, primer1: String, primer2: String) -> ref<Profile> {
		let self = new Profile();
		self.m_handle = handle;
		self.m_name = name;
		self.m_logo = logo;
		self.m_primer1 = primer1;
		self.m_primer2 = primer2;

		return self;
	}
}

/*

	The Chat class brings all chat window components, their layout and logic handling.
	It also maintains a loop to refresh the interface periodically, as dictated by the updateInterval() in the config.

*/
public class Chat extends Practice {
	// Compound widgets to register listeners
	protected let m_cols: wref<inkCompoundWidget>;
	protected let m_verts: wref<inkCompoundWidget>;

	// In-memory data structures that are dynamically updated
	protected let m_hashMap: ref<inkHashMap>;

	// UI elements that are dynamically updated
	public let m_input: ref<TextInput>;
	public let m_text: ref<inkText>;
	public let m_text2: ref<inkText>;
	public let m_nameDisplay: ref<inkText>;
	public let m_logo: ref<inkImage>;

	// Currently displayed chat metadata 
	// (should be updated from profile every chat tab button click and in OnCreate())
	private let m_displayedChatHandle: String;
	private let m_displayedChatName: String;
	private let m_displayedChatLogo: CName;
	private let m_displayedChatPrimer1: String;
	private let m_displayedChatPrimer2: String;

	protected cb func OnCreate() {
		/*

			Get chat-relevant data from cyberchat2077-ext

		*/
		LogChannel(n"DEBUG", "[CyberChat] Retrieving existing chats..");

		// Existing chats are created as TweakDB entries by cyberchat2077-ext upon loading into a save game
		// They exist session-based, like chats themselves
		let profileListTDB = TweakDBInterface.GetFlat(t"CyberChat.ALL_PROFILES");
		let profileList = StrSplit(ToString(profileListTDB), ";", false);
		let hashMap = new inkHashMap();

		for profile in profileList {
			LogChannel(n"DEBUG", "[CyberChat] Found profile: '" + profile + "'");
			let handleTDBID = TDBID.Create("CyberChat." + profile + "_handle");
			let nameTDBID = TDBID.Create("CyberChat." + profile + "_name");
			let logoTDBID = TDBID.Create("CyberChat." + profile + "_logo");
			let primer1TDBID = TDBID.Create("CyberChat." + profile + "_primer1");
			let primer2TDBID = TDBID.Create("CyberChat." + profile + "_primer2");

			let handle = TweakDBInterface.GetFlat(handleTDBID);
			let name = TweakDBInterface.GetFlat(nameTDBID);
			let logo = TweakDBInterface.GetFlat(logoTDBID);
			let primer1 = TweakDBInterface.GetFlat(primer1TDBID);
			let primer2 = TweakDBInterface.GetFlat(primer2TDBID);

			let indexTDBID = TDBID.Create(profile);
			hashMap.Insert(TDBID.ToNumber(indexTDBID), Profile.Create(ToString(handle), ToString(name), StringToName(ToString(logo)), ToString(primer1), ToString(primer2)));
			//let retrievedProfileTest: ref<Profile> = hashMap.Get(TDBID.ToNumber(handleTDBID)) as Profile;
			//LogChannel(n"DEBUG", "[CyberChat] Check profile; handle: " + retrievedProfileTest.m_handle + " name: " + retrievedProfileTest.m_name);
		}
		this.m_hashMap = hashMap;

		// There needs to be a default chat to show initially.
		this.m_displayedChatHandle = "(void)";

		/*

			Create UI components

		*/
		let root = new inkCanvas();
		root.SetName(this.GetClassName());
		root.SetAnchor(inkEAnchor.Fill);

		/*

		(root)_________________________
		
						---------------------
						| colsss
						|
						|	... <@panam> <@judy> <@xyz> ...
						|
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
		top.SetName(n"top");
		top.SetFitToContent(true);
		top.SetAnchor(inkEAnchor.TopCenter);
		top.SetAnchorPoint(new Vector2(0.5, 0.0));
		top.SetChildMargin(new inkMargin(0.0, 30.0, 0.0, 30.0)); //8.0, 0.0 8.0, 48.0
		top.Reparent(root);

		let colsss = new inkHorizontalPanel();
		colsss.SetFitToContent(true);
		colsss.SetHAlign(inkEHorizontalAlign.Center);
		colsss.SetChildMargin(new inkMargin(10.0, 0.0, 10.0, 0.0));
		colsss.Reparent(top);

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

			// For each chat handle, create an individual tab button:
			for profile in profileList {
				let chatTabButton = SimpleButton.Create();
				chatTabButton.SetName(StringToName(profile));
				chatTabButton.SetText(profile); // This is important: It is used to index the hash map below!
				chatTabButton.ToggleAnimations(true);
				chatTabButton.ToggleSounds(true);
				chatTabButton.Reparent(colsss);
			}

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
		logo.SetTexturePart(n""); // Hard-coded for the same reason as above: Some default value has to be set!
		logo.SetAnchor(inkEAnchor.TopLeft);
		logo.SetAnchorPoint(new Vector2(0.0, 0.0));
		logo.SetSize(new Vector2(0.1, 0.1)); // Division for smaller images-
		logo.SetInteractive(true);
		logo.Reparent(cols2);
		this.m_logo = logo;

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
		nameDisplay.SetText("Welcome, V!"); // Hard-coded for the same reason as above: Some default value has to be set!
		this.m_nameDisplay = nameDisplay;

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
		this.m_text = text; // Refers to request

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

		this.UpdateChat(); // Populates the chat window with CyberAI data

		this.m_cols = cols;
		this.m_verts = colsss;

		this.SetRootWidget(root);
	}

	protected cb func OnInitialize() {
		//this.RegisterListeners(this.m_top);
		this.RegisterListeners(this.m_cols); // Meaning mostly button callback registering, see below
		this.RegisterListeners(this.m_verts);

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

		Now since we introduced an interval by re-sending the dummy notification, this is still safe:
			- again, this function callback is only relevant if the class is instantiated (i.e., chat window is open)
			- hence, it will cease to update when we close it
			- but then again, it will update as soon as we open it

	*/
	protected cb func OnUINotification(evt: ref<UIInGameNotificationEvent>) -> Bool {
		// Update the currently displayed chat, this will only update the latest chat defined by this.m_displayedChatHandle
		// and that variable is updated on every chat switch or OnCreate(), where it is initially set to some default value.
		this.UpdateChat();

		// Every updateInterval(), loop send a dummy request (until we ESC or C this window)
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
		LogChannel(n"DEBUG", "[CyberChat] Updating chat for " + this.m_displayedChatHandle);

		let lastResponseLine = [""];
		let lastRequestLine = [""];
		let lastResponse = "";
		let lastRequest = "";

		let historyArray = GetHistory(this.m_displayedChatHandle);
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
				this.m_text2.SetText(this.m_displayedChatName + ":\n" + lastResponse);
			} else if Equals(lastResponseLine[0], "User") {
				this.m_text2.SetText("You:\n" + lastResponse);
			} else {
				// Debug only! Normally we would hide system messages, they only provide primer or continuity information.
				//this.m_text2.SetText("<" + lastResponse + ">");
				this.m_text2.SetText("");
			}
		} else {
			// Handle both cases in which no definite chat exists:
			if Equals(this.m_displayedChatHandle, "(void)") {
				this.m_text2.SetText("");
			} else {
				// If there is no last response, then there is no last request. Therefore, set the initial text value here:
				this.m_text2.SetText("This is the beginning of your conversation with\n" + this.m_displayedChatName + " (" + this.m_displayedChatHandle + ")");
			}
		}
		if StrLen(lastRequest) > 1 {
			if Equals(lastRequestLine[0], "Assistant") {
				this.m_text.SetText(this.m_displayedChatName + ":\n" + lastRequest);
			}else if Equals(lastRequestLine[0], "User") {
				this.m_text.SetText("You:\n" + lastRequest);
			}else {
				// Debug only! See above.
				//this.m_text.SetText("<" + lastRequest + ">");
				this.m_text.SetText("");
			}
		} else {
			this.m_text.SetText("");
		}

		// Update other UI elements:
		if NotEquals(this.m_displayedChatHandle, "(void)") {
			this.m_nameDisplay.SetText(this.m_displayedChatName + "\n" + "(" + this.m_displayedChatHandle + ")");
			this.m_logo.SetTexturePart(this.m_displayedChatLogo);
			this.m_logo.SetSize(new Vector2(450.0 / 1.5, 450.0 / 1.5)); // Division for smaller images-
		}
	}

	protected cb func OnClick(widget: wref<inkWidget>) -> Bool {
		let button = widget.GetController() as CustomButton;

		let buttonName = button.GetText();
		LogChannel(n"DEBUG", "[CyberChat] Button pressed: " + buttonName);
		let buttonEvent = this.GetLocalizedText("CyberChat-ButtonBasics-Event-Click");

		this.Log(buttonName + ": " + buttonEvent);

		// This is whatever the user input into the text field.
		let userTextInput = this.m_input.GetText();

		// Now we handle the send request.
		if Equals(buttonName, "Send") {
			// 1) Check if user input is empty (empty input is not sent out to chatGPT).
			if StrLen(userTextInput) > 1 {
				// 2) Check for commands in user input
				switch userTextInput {
					case "/flush":
						this.m_input.SetText("");

						LogChannel(n"DEBUG", "[CyberChat] Flushing chat with id " + this.m_displayedChatHandle);
						FlushChat(this.m_displayedChatHandle);
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
						if StrLen(GetHistoryAsString(this.m_displayedChatHandle)) <= 1 {
							// Case 1: The Dialogue does not exist yet, hence, include a primer to inform ChatGPT about its role.
							ScheduleChatCompletionRequest(this.m_displayedChatHandle, [["System", this.m_displayedChatPrimer1],["System", this.m_displayedChatPrimer2],["User", userTextInput]]);
						} else {
							// Case 2: Simply send user input towards the existing conversation. This saves a lot of tokens over time.
							ScheduleChatCompletionRequest(this.m_displayedChatHandle, [["User", userTextInput]]);
						}

							// Wanted functionality; after sending anything, clear the text input so we don't have to do it manually each time & input is not sent twice accidentally.
							this.m_input.SetText("");

								// We formulate a generic notification event (old!)
								/*
								let notifyEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
								notifyEvent.m_notificationType = UIInGameNotificationType.GenericNotification;
								notifyEvent.m_title = "New message from " + this.m_displayedChatName + "!";
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
		} else {
			// If this button is not the send button, then the button name is the chat handle to load:
			let indexTDBID = TDBID.Create(buttonName);
			let retrievedProfileTest: ref<Profile> = this.m_hashMap.Get(TDBID.ToNumber(indexTDBID)) as Profile;

			this.m_displayedChatHandle = retrievedProfileTest.m_handle;
			this.m_displayedChatName = retrievedProfileTest.m_name;
			this.m_displayedChatLogo = retrievedProfileTest.m_logo;
			this.m_displayedChatPrimer1 = retrievedProfileTest.m_primer1;
			this.m_displayedChatPrimer2 = retrievedProfileTest.m_primer2;
			this.UpdateChat();
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

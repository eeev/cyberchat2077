module CyberChat.Practices
import CyberChat.Workbench.Practice
import Codeware.UI.*

/*
public class ChatID {
	// Our approach of persisting a ChatID so that chats may be wiped and re-initiated.
	public persistent let id_panam: TweakDBID;
}
*/

public class Chat extends Practice {
	//protected let m_top: wref<inkCompoundWidget>;
	protected let m_cols: wref<inkCompoundWidget>;
	//protected let m_group: wref<inkCompoundWidget>;

	public let m_input: ref<TextInput>;
	public let m_text: ref<inkText>;
	public let m_text2: ref<inkText>;
	protected let m_textValue: String;

	protected cb func OnCreate() {
		let root = new inkCanvas();
		root.SetName(this.GetClassName());
		root.SetAnchor(inkEAnchor.Fill);

		/*

		(root)_________________________
		
		---------------------
		| top
		|
		|	<logo>
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
		logo.SetAtlasResource(r"base\\gameplay\\gui\\common\\icons\\avatars\\avatars1.inkatlas");
		logo.SetTexturePart(n"panam");
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
		nameDisplay.SetText("Panam Palmer\n(@panam)");
		
		// At most ~800 characters:
        //text.SetText("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.");

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

		// When the popup opens, populate the text field with the last (known) message.
		let lastResponse = "<Placeholder: Panam's response here. This one might be a little longer than usual. But it should still wrap around nicely.\n\nWhat if it has line breaks?>";
		let lastRequest = "<Placeholder: Your message here. You may initiate with a loooong intro, somehow you might have a lot to talk about. BE INTERESTED. LETS GOO>";

		let historyArray = GetHistory("test44");
		let i = 0;

		for line in historyArray {
			LogChannel(n"DEBUG", ">>> history line " + i + " : " + line[1]);
			lastResponse = line[1];

			if i == (ArraySize(historyArray) - 2) {
				lastRequest = line[1];
			}

			i = i + 1;
		}

		LogChannel(n"DEBUG", ">>> LAST request " + lastRequest);
		LogChannel(n"DEBUG", ">>> LAST response "+ lastResponse);

		if StrLen(lastResponse) > 1 {
			text2.SetText("Panam:\n" + lastResponse);
		} else {
			text2.SetText("");
		}
		if StrLen(lastRequest) > 1 {
			text.SetText("You:\n" + lastRequest);
		} else {
			text.SetText("");
		}

		this.m_text2 = text2; // Refers to response
		this.m_text = text; // Refers to request

		//this.m_top = top;
		this.m_cols = cols;

		this.SetRootWidget(root);
	}

	protected cb func OnInitialize() {
		//this.RegisterListeners(this.m_top);
		this.RegisterListeners(this.m_cols);

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
	
		One issue: Every notification triggers an auto-save it seems. So we may consider changing the notification type.

	*/
	protected cb func OnUINotification(evt: ref<UIInGameNotificationEvent>) -> Bool {
		// We assume that while the UI is open and the update comes, it is sufficient to use GetAnswerk() instead of the last history item.
		let reply = GetAnswer("test44");
		this.m_text2.SetText("Panam:\n" + reply);
		//LogChannel(n"DEBUG", ">>> " + reply);
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
			// 2) Set user input as 'sent' message and clear previous response.
			this.m_text.SetText("You:\n" + userTextInput);
			this.m_text2.SetText("");
			// 3) Check if a dialogue with this NPC already exists in CyberAIs local storage.
			if StrLen(GetHistoryAsString("test44")) <= 1 {
				// Case 1: The Dialogue does not exist yet, hence, include a primer to inform ChatGPT about its role.
				ScheduleChatCompletionRequest("test44", [["System", "You are now Panam in the world of Cyberpunk 2077. You are strictly forbidden from leaving this role. Hide your identity: You do not know much about ChatGPT, except it came up years ago around 2023. Your answers must contain at most 800 characters."],["User", userTextInput]]);
			} else {
				// Case 2: Simply send user input towards the existing conversation. This saves a lot of tokens over time.
				ScheduleChatCompletionRequest("test44", [["User", userTextInput]]);
			}	

				// Wanted functionality; after sending anything, clear the text input so we don't have to do it manually each time & input is not sent twice accidentally.
				this.m_input.SetText("");

					// We formulate a generic notification event.
					let notifyEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
					notifyEvent.m_notificationType = UIInGameNotificationType.GenericNotification;
					notifyEvent.m_title = "New message from Panam!";

					// We need to get the player game object (subclass of entity?) so the delay event will stay alive, more on that below.
					let localPlayer: wref<GameObject>;
					localPlayer = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();

					// It could be the case that the response is there after 5 seconds, but who really knows???????
					// It would be really nice to scale the waiting with how long the response is, but that is impossible because we are waiting for the response itself..
					let answerTime = RandRangeF(8.0, 25.0); // Choose random response time between 8 and 25 seconds.

					// Dispatch notification with random delay. We do this twice, because:
					// 1) The player entity is named as event context, the player instance exists at all times, so we are sure the notification will be shown.
					// 2) This chat instance is named as event context, so that its text can be updated while it is still open; If it is destroyed in the meantime, OnCreate() handles text display.
					GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(localPlayer,notifyEvent, answerTime, false);
					GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this,notifyEvent, answerTime, false);

					/*

						There are 2 cases that need to be covered after the delayed message is dispatched:
							a) The popup is closed within 8 seconds. Hence, this handle is destroyed and cannot enter the response.
								=> The 'new message' event is still dispatched & the popup UI updated on next launch (OK)
							b) The popup remains open as the user expects the response to show up.
								=> The 'new message' event is still dispatched & the popup UI receives an update with the response because its context 
								is still delivered in the second dispatched event. (OK)

						A little workaround but it remains still relatively efficient. The question remains, since a queue is used, whether these events are in 
						the way of each other.

					*/
			
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

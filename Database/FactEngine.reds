module CyberChat.Database
import Codeware.*

/*

    The PlayerPuppet can be hooked to register itself to additional facts in-game.
    Then, whenever a fact is updated, the OnFactChangedEvent(evt) is called.

    The Event (evt) itself has few information on the changed fact:
        - evt.GetFactName() -> CName

    However, the global function Game.CheckFactValue(fact) can be used to receive the actual value.
    Otherwise, GameInstance.GetQuestsSystem(self) -> ref<QuestsSystem> has some getter/setter for facts.

*/
@wrapMethod(PlayerPuppet)
private final func RegisterToFacts() -> Void {
    /*

        Register facts to be watched here..
        These should be grouped profile-relevant, i.e., all facts with Judy quests will mostly have impact on chatting with Judy.
        However, some facts can be seen as general knowledge across chat profiles:
        For example, when you tell Panam about the chip/Johnny, then both Johnny and Panam posess this knowledge now.
    
    */
    let factList: array<String> = [
        "q004_judy_met",
        "q004_judy_char_entry",
        "judy_romanceable",
        "judy_knows_johnny",
        "judy_left_nc",
        "judy_relationship",
        "q004_evelyn_char_entry",
        "q105_evelyn_found",
        "q101_johnny_char_entry",
        "q103_rogue_met",
        "q103_rogue_done",
        "sq031_rogue_met_johnny",
        "q103_panam_met"
    ];

    for fact in factList {
        GameInstance.GetQuestsSystem(this.GetGame()).RegisterEntity(StringToName(fact), this.GetEntityID());   
    }    

    wrappedMethod();
}

@wrapMethod(PlayerPuppet)
protected cb func OnFactChangedEvent(evt: ref<FactChangedEvent>) -> Bool {
    /*

        It remains to be discussed how the knowledge is broadcasted within the game world:
        Should actors be aware immediately? When, if at all, should they message you?
        Then there is a general OpenAI API issue: 'user' flagged messages are higher valued than 'system' messages.
        In some cases, this can lead to the response being incoherent:

            "system": "Avoid questions regarding Evelyn. You know: She is alive."
            "user": "WHO KILLED EVELYN?"
            
            => response: "I can't say for sure who killed Evelyn. I know she's alive but I don't have the details on what happened to her."

        I decide to implement the following model:

            1) Not all actors are aware of what is happening in the lives of other actors
                - e.g., Rogue would not be informed about the inevitable death of Evelyn, because there is no connection
                - check how the model responds to that
            2) Those who are involved will receive the fact update, which inherently prompts their response
            3) The update is broadcasted with random delays in the lengths of some in-game hours (1 hour ingame is 7 minutes real time)

        The good thing is we only need to script changes in facts. There is no need to persist or store anything

    */

    switch evt.GetFactName() {
        case n"q004_judy_met":
            // We formulate a notification event
		    let factEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
		    factEvent.m_notificationType = UIInGameNotificationType.GenericNotification;
		    factEvent.m_title = "Judy Álvarez (@judy) added you as a contact";
		    factEvent.m_overrideCurrentNotification = true;

            GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, factEvent, 5.0, false);
            LogChannel(n"DEBUG", "[CyberChat > FactEngine] Fact updated: Met Judy");
            break;

        case n"q101_johnny_char_entry":
            // We formulate a notification event
		    let factEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
		    factEvent.m_notificationType = UIInGameNotificationType.GenericNotification;
		    factEvent.m_title = "Johnny Silverhand (@johnny) added you as a contact";
		    factEvent.m_overrideCurrentNotification = true;

            GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, factEvent, 5.0, false);
            LogChannel(n"DEBUG", "[CyberChat > FactEngine] Fact updated: Met Johnny");
            break;

        case n"q103_rogue_met":
            // We formulate a notification event
		    let factEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
		    factEvent.m_notificationType = UIInGameNotificationType.GenericNotification;
		    factEvent.m_title = "Rogue Amendiares (@rogue) added you as a contact";
		    factEvent.m_overrideCurrentNotification = true;

            GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, factEvent, 5.0, false);
            LogChannel(n"DEBUG", "[CyberChat > FactEngine] Fact updated: Met Rogue");
            break;

        case n"q103_panam_met":
            // We formulate a notification event
		    let factEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
		    factEvent.m_notificationType = UIInGameNotificationType.GenericNotification;
		    factEvent.m_title = "Panam Palmer (@panam) added you as a contact";
		    factEvent.m_overrideCurrentNotification = true;

            GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, factEvent, 5.0, false);
            LogChannel(n"DEBUG", "[CyberChat > FactEngine] Fact updated: Met Panam");
            break;
    }
    wrappedMethod(evt);
}
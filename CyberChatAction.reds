import CyberChat.CyberChatPopup
import Codeware.Localization.LocalizationSystem

/*

	This script does the following:
		- Creates the binding of a CyberChatPopup creation to user input
		- Checks, whether the player is not inside a vehicle and displays the UI hint

*/

@replaceMethod(BaseContextEvents)
protected final func UpdateGenericExplorationInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) {
	if this.ShouldForceRefreshInputHints(stateContext, scriptInterface) {
		this.RemoveGenericExplorationInputHints(stateContext, scriptInterface);
		this.RemoveCyberChatPopupInputHints(stateContext, scriptInterface);
		return;
	}

	let isValidState = this.IsStateValidForExploration(stateContext, scriptInterface);

	if isValidState || (this.IsInHighLevelState(stateContext, n"exploration") && DefaultTransition.HasRightWeaponEquipped(scriptInterface)) {
		if !stateContext.GetBoolParameter(n"isCyberChatPopupInputHintDisplayed", true) {
			this.ShowCyberChatPopupInputHints(stateContext, scriptInterface);
		}
	} else {
		if stateContext.GetBoolParameter(n"isCyberChatPopupInputHintDisplayed", true) {
			this.RemoveCyberChatPopupInputHints(stateContext, scriptInterface);
		}
	}

	if isValidState {
		if !stateContext.GetBoolParameter(n"isLocomotionInputHintDisplayed", true) {
			this.ShowGenericExplorationInputHints(stateContext, scriptInterface);
		}
	} else {
		if stateContext.GetBoolParameter(n"isLocomotionInputHintDisplayed", true) {
			this.RemoveGenericExplorationInputHints(stateContext, scriptInterface);
		}
	}
}

@addMethod(InputContextTransitionEvents)
protected final func ShowCyberChatPopupInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) {
	let localization = LocalizationSystem.GetInstance(scriptInterface.GetGame());
	let actionLabel = localization.GetText("CyberChat-Action-Label");

	this.ShowInputHint(scriptInterface, n"Choice2_Hold", n"CyberChatPopup", actionLabel, inkInputHintHoldIndicationType.Hold, true);

	stateContext.SetPermanentBoolParameter(n"isCyberChatPopupInputHintDisplayed", true, true);
}

@addMethod(InputContextTransitionEvents)
protected final func RemoveCyberChatPopupInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) {
	this.RemoveInputHintsBySource(scriptInterface, n"CyberChatPopup");

	stateContext.RemovePermanentBoolParameter(n"isCyberChatPopupInputHintDisplayed");
}

@wrapMethod(InputContextTransitionEvents)
protected final func RemoveAllInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) {
	this.RemoveCyberChatPopupInputHints(stateContext, scriptInterface);
	wrappedMethod(stateContext, scriptInterface);
}

@wrapMethod(gameuiInGameMenuGameController)
private final func RegisterInputListenersForPlayer(playerPuppet: ref<GameObject>) {
	wrappedMethod(playerPuppet);

	if playerPuppet.IsControlledByLocalPeer() {
		playerPuppet.RegisterInputListener(this, n"Choice2_Hold");
	}
}

@wrapMethod(gameuiInGameMenuGameController)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) {
	wrappedMethod(action, consumer);

	let actionName = ListenerAction.GetName(action);
	let actionType = ListenerAction.GetType(action);

	if Equals(actionName, n"Choice2_Hold") && Equals(actionType, gameinputActionType.BUTTON_HOLD_COMPLETE) {
		let player = this.GetPlayerControlledObject() as PlayerPuppet;
		let blackboard = player.GetPlayerStateMachineBlackboard();
		let state = IntEnum<gamePSMVehicle>(blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle));

		if NotEquals(state, gamePSMVehicle.Default) {
		    return;
		}

		if !Codeware.Require("1.1.4") {
		    LogChannel(n"DEBUG", "CyberChat requires Codeware 1.1.4");
		    return;
		}

		CyberChatPopup.Show(this);
        ListenerActionConsumer.DontSendReleaseEvent(consumer);
	}
}

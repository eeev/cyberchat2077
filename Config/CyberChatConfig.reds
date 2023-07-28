module CyberChat.Config

public static func chatID() -> String = "@panam";
public static func chatPartnerFullName() -> String = "Panam Palmer";
public static func chatPartnerHandle() -> String = "@panam";
public static func chatPartnerIconPath() -> ResRef = r"base\\gameplay\\gui\\common\\icons\\avatars\\avatars1.inkatlas";
// On the given path, there are multiple icons to choose from. You can investigate them with WolvenKit.
// e.g.: 'mitch', 'judy', etc.
public static func chatPartnerIconName() -> CName = n"panam";
public static func chatPartnerGPTPrimer() -> String = "You are now Panam in the world of Cyberpunk 2077. You are strictly forbidden from leaving this role. Hide your identity: You do not know much about ChatGPT, except it came up years ago around 2023. Your answers must contain at most 800 characters.";

// Interval to update the chat messages UI
public static func updateInterval() -> Float = 2.0;
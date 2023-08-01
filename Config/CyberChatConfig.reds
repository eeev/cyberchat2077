module CyberChat.Config

public static func chatPartnerIconPath() -> ResRef = r"base\\gameplay\\gui\\common\\icons\\avatars\\avatars1.inkatlas";
// On the given path, there are multiple icons to choose from. You can investigate them with WolvenKit.
// You should leave this path as-is and simply provide a logo name like 'mitch' in cyberchat2077-ext!
// Unless you have a custom resource you want to use here.

// Interval to update the chat messages UI
public static func updateInterval() -> Float = 2.0;
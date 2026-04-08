import QtQuick
import qs.Modules.Plugins

PluginSettings {
	pluginId: "dmsFullScreenPowerMenu"

	StringSetting {
		settingKey: "logoutCommand"
		label: "Log Out Command"
		description: "Command to log out of the session"
		defaultValue: "loginctl terminate-session"
	}

	StringSetting {
		settingKey: "lockCommand"
		label: "Lock Screen Command"
		description: "Command to lock the screen"
		defaultValue: "loginctl lock-session"
	}

	SliderSetting {
		settingKey: "dimOpacity"
		label: "Background Dim Intensity"
		description: "How dark the background dims when the menu is open (0 = transparent, 100 = fully black)"
		defaultValue: 75
		minimum: 0
		maximum: 100
		unit: "%"
	}
}

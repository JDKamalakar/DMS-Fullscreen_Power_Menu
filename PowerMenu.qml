import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Widgets
import qs.Common
import qs.Modules.Plugins

PluginComponent {
	id: root

	// -------------------------------------------------------------------------
	// IPC — trigger via: dms ipc dmsFullScreenPowerMenu toggle
	// -------------------------------------------------------------------------

	IpcHandler {
		target: "dmsFullScreenPowerMenu"

		function toggle(): string {
			root.toggle();
			return overlay.visible ? "opened" : "closed";
		}

		function open(): string {
			if (!overlay.visible) root.open();
			return "opened";
		}

		function close(): string {
			if (overlay.visible) root.close();
			return "closed";
		}
	}

	function open() {
		overlay.visible = true;
	}

	function close() {
		overlay.visible = false;
	}

	function toggle() {
		if (overlay.visible) root.close();
		else root.open();
	}

	// -------------------------------------------------------------------------
	// FULLSCREEN OVERLAY WINDOW
	// -------------------------------------------------------------------------

	PanelWindow {
		id: overlay
		visible: false
		color: "transparent"

		WlrLayershell.namespace: "dms:plugins:dmsFullScreenPowerMenu"
		WlrLayershell.layer: WlrLayershell.Overlay
		WlrLayershell.exclusiveZone: -1
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

		anchors {
			top: true
			left: true
			right: true
			bottom: true
		}

		// Background dim
		Rectangle {
			anchors.fill: parent
			color: "#000000"
			opacity: overlay.visible ? (pluginData && pluginData.dimOpacity != null ? pluginData.dimOpacity / 100 : 0.75) : 0
			Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }

			MouseArea {
				anchors.fill: parent
				onClicked: root.close()
			}
		}

		// Power Menu Card
		Rectangle {
			id: menuCard
			anchors.centerIn: parent
			width: 480
			height: 240
			radius: 28
			color: "#1C1B1F" // M3 Dark Surface

			scale: overlay.visible ? 1.0 : 0.88
			opacity: overlay.visible ? 1.0 : 0.0
			Behavior on scale   { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }
			Behavior on opacity { NumberAnimation { duration: 250 } }

			// Escape key to close
			Keys.onEscapePressed: root.close()

			ColumnLayout {
				anchors.fill: parent
				anchors.margins: 28
				spacing: 20

				Text {
					text: "Power"
					font.pixelSize: 24
					font.weight: Font.Medium
					color: "#E6E1E5"
					Layout.alignment: Qt.AlignHCenter
				}

				RowLayout {
					spacing: 12
					Layout.fillWidth: true
					Layout.fillHeight: true

					PowerButton {
						label: "Shut Down"
						iconSource: "system-shutdown"
						accentColor: "#FFB4AB"
						onActivated: {
							root.close();
							shutdownProc.running = true;
						}
					}

					PowerButton {
						label: "Restart"
						iconSource: "system-reboot"
						accentColor: "#D0BCFF"
						onActivated: {
							root.close();
							rebootProc.running = true;
						}
					}

					PowerButton {
						label: "Suspend"
						iconSource: "system-suspend"
						accentColor: "#CCC2DC"
						onActivated: {
							root.close();
							suspendProc.running = true;
						}
					}

					PowerButton {
						label: "Log Out"
						iconSource: "system-log-out"
						accentColor: "#EADDFF"
						onActivated: {
							root.close();
							logoutProc.command = (pluginData && pluginData.logoutCommand ? pluginData.logoutCommand : "loginctl terminate-session $XDG_SESSION_ID").split(" ");
							logoutProc.running = true;
						}
					}

					PowerButton {
						label: "Lock"
						iconSource: "system-lock-screen"
						accentColor: "#EFB8C8"
						onActivated: {
							root.close();
							lockProc.command = (pluginData && pluginData.lockCommand ? pluginData.lockCommand : "loginctl lock-session").split(" ");
							lockProc.running = true;
						}
					}

					PowerButton {
						label: "Cancel"
						iconSource: "window-close"
						accentColor: "#938F99"
						onActivated: root.close()
					}
				}
			}
		}

		// Keyboard handler on overlay background
		Item {
			anchors.fill: parent
			focus: overlay.visible
			Keys.onEscapePressed: root.close()
		}
	}

	// -------------------------------------------------------------------------
	// PROCESSES
	// -------------------------------------------------------------------------

	Process { id: shutdownProc; command: ["systemctl", "poweroff"] }
	Process { id: rebootProc;   command: ["systemctl", "reboot"]   }
	Process { id: suspendProc;  command: ["systemctl", "suspend"]  }
	Process { id: logoutProc   }
	Process { id: lockProc     }

	// -------------------------------------------------------------------------
	// POWER BUTTON COMPONENT
	// -------------------------------------------------------------------------

	component PowerButton: Item {
		property string label: ""
		property string iconSource: ""
		property color accentColor: "#D0BCFF"
		signal activated()

		Layout.fillWidth: true
		Layout.fillHeight: true

		Rectangle {
			id: btnBg
			anchors.fill: parent
			radius: 20
			color: ma.pressed
				? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.28)
				: ma.containsMouse
					? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.14)
					: "transparent"
			border.color: ma.containsMouse ? accentColor : "#3B383E"
			border.width: 1

			Behavior on color        { ColorAnimation { duration: 120 } }
			Behavior on border.color { ColorAnimation { duration: 120 } }

			ColumnLayout {
				anchors.centerIn: parent
				spacing: 10

				// Icon circle
				Rectangle {
					width: 48
					height: 48
					radius: 24
					color: ma.pressed ? Qt.darker(accentColor, 1.3) : accentColor
					Layout.alignment: Qt.AlignHCenter

					Behavior on color { ColorAnimation { duration: 120 } }

					IconImage {
						anchors.centerIn: parent
						source: Quickshell.iconPath(iconSource)
						width: 22
						height: 22
						implicitWidth: 22
						implicitHeight: 22
					}
				}

				Text {
					text: label
					color: ma.containsMouse ? accentColor : "#CAC4D0"
					font.pixelSize: 12
					font.weight: Font.Medium
					Layout.alignment: Qt.AlignHCenter
					Behavior on color { ColorAnimation { duration: 120 } }
				}
			}

			MouseArea {
				id: ma
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: parent.parent.activated()
			}
		}
	}

	Component.onCompleted: {
		console.info("dmsFullScreenPowerMenu: daemon loaded — use 'dms ipc dmsFullScreenPowerMenu toggle' to open");
	}
}

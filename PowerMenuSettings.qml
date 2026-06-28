import QtQuick
import Quickshell

import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "fullscreenPowerMenu"

    // -------------------------------------------------------------------------
    // REUSABLE COMPONENTS
    // -------------------------------------------------------------------------

    component SectionContainer: Rectangle {
        width: parent.width
        height: sectionContent.implicitHeight + Theme.spacingM * 2
        color: Theme.surfaceContainer
        radius: Theme.cornerRadius
        border.color: Theme.outline
        border.width: 1
        opacity: 0.8

        default property alias content: sectionContent.data

        Column {
            id: sectionContent
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingM
        }
    }

    component SettingsSlider: Column {
        id: sliderSection
        width: parent.width
        spacing: Theme.spacingXS

        property string iconName: ""
        property string title: ""
        property string description: ""
        property string settingKey: ""
        property int defaultValue: 0
        property int minimumValue: 0
        property int maximumValue: 100
        property string unit: "%"
        property bool sliderEnabled: true

        Row {
            width: parent.width
            spacing: Theme.spacingM
            DankIcon {
                name: sliderSection.iconName
                size: 22
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.8
            }
            Column {
                width: Math.max(0, parent.width - 54 - Theme.spacingM * 2)
                StyledText {
                    text: sliderSection.title
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
                StyledText {
                    text: sliderSection.description
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }
            Rectangle {
                id: resetBtn
                width: 32; height: 32
                radius: Theme.cornerRadius
                anchors.verticalCenter: parent.verticalCenter
                color: resetMa.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.04)
                border.color: resetMa.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4) : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.15)
                border.width: 1
                opacity: (slider.value !== sliderSection.defaultValue && sliderSection.sliderEnabled) ? (resetMa.containsMouse ? 1.0 : 0.9) : 0.0
                visible: opacity > 0
                scale: resetMa.pressed ? 0.9 : (resetMa.containsMouse ? 1.05 : 1.0)
                
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                DankRipple { 
                    id: resetRip
                    anchors.fill: parent
                    cornerRadius: parent.radius
                    rippleColor: Theme.primary 
                }

                DankIcon {
                    id: resetIcon
                    name: "restart_alt"
                    size: 18
                    anchors.centerIn: parent
                    color: resetMa.containsMouse ? Theme.primary : Theme.surfaceVariantText
                    SequentialAnimation on rotation {
                        running: resetMa.containsMouse; loops: Animation.Infinite
                        NumberAnimation { to: 8; duration: 75 }
                        NumberAnimation { to: -8; duration: 150 }
                        NumberAnimation { to: 0; duration: 75 }
                        onRunningChanged: { if (!running) resetIcon.rotation = 0; }
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: resetMa
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: slider.value !== sliderSection.defaultValue && sliderSection.sliderEnabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        resetAnim.restart();
                        root.saveValue(sliderSection.settingKey, sliderSection.defaultValue);
                    }
                    onPressed: (m) => resetRip.trigger(m.x, m.y)
                }
            }

            NumberAnimation {
                id: resetAnim
                target: slider
                property: "value"
                to: sliderSection.defaultValue
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        DankSlider {
            id: slider
            property string settingKey: sliderSection.settingKey
            width: parent.width
            minimum: sliderSection.minimumValue
            maximum: sliderSection.maximumValue
            unit: sliderSection.unit
            enabled: sliderSection.sliderEnabled
            function loadValue() {
                if (root)
                    value = root.loadValue(settingKey, sliderSection.defaultValue);
            }
            Component.onCompleted: loadValue()
            onSliderValueChanged: newValue => {
                value = newValue;
                root.saveValue(settingKey, newValue);
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: (wheel) => { wheel.accepted = true; }
            }
        }
    }

    component CommandField: Column {
        id: cmdField
        width: parent.width
        spacing: Theme.spacingM

        property string iconName: ""
        property string title: ""
        property string description: ""
        property string settingKey: ""
        property string defaultValue: ""

        Row {
            width: parent.width
            spacing: Theme.spacingM
            DankIcon {
                name: cmdField.iconName
                size: 22
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.8
            }
            Column {
                width: Math.max(0, parent.width - 22 - Theme.spacingM)
                StyledText {
                    text: cmdField.title
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
                StyledText {
                    text: cmdField.description
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }
        }
        DankTextField {
            id: textField
            property string settingKey: cmdField.settingKey
            width: parent.width
            text: cmdField.defaultValue
            function loadValue() {
                if (root)
                    text = root.loadValue(settingKey, cmdField.defaultValue);
            }
            Component.onCompleted: loadValue()
            onEditingFinished: root.saveValue(settingKey, text)
        }
    }

    component SettingsToggle: Column {
        id: toggleSection
        width: parent.width
        spacing: Theme.spacingXS

        property string iconName: ""
        property string title: ""
        property string description: ""
        property string settingKey: ""
        property bool defaultValue: false

        property alias checked: toggle.checked

        function loadValue() {
            if (root) {
                var loaded = root.loadValue(settingKey, defaultValue);
                checked = loaded === true || loaded === "true";
            }
        }

        Row {
            width: parent.width
            spacing: Theme.spacingM

            DankIcon {
                name: toggleSection.iconName
                size: 22
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.8
            }

            Column {
                // Ensure the text column takes up the remaining space properly
                width: Math.max(0, parent.width - 74 - Theme.spacingM * 2)
                spacing: 2
                StyledText {
                    text: toggleSection.title
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
                StyledText {
                    text: toggleSection.description
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }

            Item {
                width: 52
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                DankToggle {
                    id: toggle
                    anchors.centerIn: parent
                    Component.onCompleted: toggleSection.loadValue()
                    onToggled: function (checked) {
                        root.saveValue(toggleSection.settingKey, checked);
                    }
                }
            }
        }

        // Spacer to match the vertical rhythm of Sliders which have a second row
        Item {
            width: 1
            height: Theme.spacingXS
        }
    }

    // -------------------------------------------------------------------------
    // SETTINGS UI
    // -------------------------------------------------------------------------

    Column {
        id: rootWrapper
        width: parent.width
        spacing: Theme.spacingM

        function loadValue() {
            var groups = [orientationGroup, generalGroup, cmdGroup];
            for (var g = 0; g < groups.length; g++) {
                var group = groups[g];
                for (var i = 0; i < group.children.length; i++) {
                    var item = group.children[i];
                    if (item.loadValue)
                        item.loadValue();
                    else if (item.children) {
                        for (var j = 0; j < item.children.length; j++) {
                            var subItem = item.children[j];
                            if (subItem.loadValue)
                                subItem.loadValue();
                        }
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
        // ORIENTATION
        // ---------------------------------------------------------------------
        SectionContainer {
            Column {
                id: orientationGroup
                width: parent.width
                spacing: Theme.spacingXS
                Row {
                    width: parent.width
                    spacing: Theme.spacingM
                    DankIcon {
                        name: "screen_rotation"
                        size: 22
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: 0.8
                    }
                    Column {
                        width: Math.max(0, parent.width - 22 - Theme.spacingM)
                        StyledText {
                            text: "Menu Orientation"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                        StyledText {
                            text: "Change the button grid flow depending on device orientation."
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }
                DankDropdown {
                    id: orientationDropdown
                    width: parent.width

                    property string settingKey: "menuOrientation"
                    property string defaultValue: "dynamic"
                    property var optionList: [
                        {
                            label: "Dynamic (Auto-detect)",
                            value: "dynamic"
                        },
                        {
                            label: "Horizontal Flow",
                            value: "horizontal"
                        },
                        {
                            label: "Vertical Flow",
                            value: "vertical"
                        }
                    ]

                    options: ["Dynamic (Auto-detect)", "Horizontal Flow", "Vertical Flow"]

                    function loadValue() {
                        if (root) {
                            var loadedVal = root.loadValue(settingKey, defaultValue);
                            for (var i = 0; i < optionList.length; i++) {
                                if (optionList[i].value === loadedVal) {
                                    currentValue = optionList[i].label;
                                    break;
                                }
                            }
                        }
                    }

                    Component.onCompleted: loadValue()

                    onValueChanged: newValue => {
                        for (var i = 0; i < optionList.length; i++) {
                            if (optionList[i].label === newValue) {
                                root.saveValue(settingKey, optionList[i].value);
                                break;
                            }
                        }
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
        // APPEARANCE
        // ---------------------------------------------------------------------
        SectionContainer {
            Column {
                id: generalGroup
                width: parent.width
                spacing: Theme.spacingM

                SettingsSlider {
                    iconName: "visibility"
                    title: "Menu Transparency"
                    description: "Opacity of the power menu floating container."
                    settingKey: "menuOpacity"
                    defaultValue: 20
                    maximumValue: 100
                }

                SettingsSlider {
                    iconName: "opacity"
                    title: "Background Dim Intensity"
                    description: "How dark the background dims when the menu is open."
                    settingKey: "dimOpacity"
                    defaultValue: 60
                    maximumValue: 100
                }

                SettingsToggle {
                    id: animToggle
                    iconName: "auto_fix_high"
                    title: "Animations"
                    description: "Enable or disable all menu animations."
                    settingKey: "animationsEnabled"
                    defaultValue: true
                }

                SettingsToggle {
                    id: tintToggle
                    iconName: "palette"
                    title: "Primary Color Tint"
                    description: "Apply a subtle primary color tint to the menu background."
                    settingKey: "primaryTintEnabled"
                    defaultValue: false
                }

                SettingsSlider {
                    iconName: "format_color_fill"
                    title: "Tint Intensity"
                    description: "Adjust the intensity of the primary color tint."
                    settingKey: "tintIntensity"
                    defaultValue: 30
                    minimumValue: 5
                    maximumValue: 100
                    sliderEnabled: tintToggle.checked
                    opacity: tintToggle.checked ? 1.0 : 0.4
                }

                SettingsSlider {
                    iconName: "speed"
                    title: "Animation Speed"
                    description: "Controls the speed of all menu animations. Higher = faster."
                    settingKey: "animationSpeed"
                    defaultValue: 100
                    minimumValue: 25
                    maximumValue: 300
                    sliderEnabled: animToggle.checked
                    opacity: animToggle.checked ? 1.0 : 0.4
                }
            }
        }

        // ---------------------------------------------------------------------
        // COMMANDS
        // ---------------------------------------------------------------------
        SectionContainer {
            Column {
                id: cmdGroup
                width: parent.width
                spacing: Theme.spacingM

                CommandField {
                    iconName: "power_settings_new"
                    title: "Shutdown Command"
                    description: "Command executed to power off the machine."
                    settingKey: "shutdownCommand"
                    defaultValue: "systemctl poweroff"
                }
                CommandField {
                    iconName: "restart_alt"
                    title: "Restart Command"
                    description: "Command executed to reboot the machine."
                    settingKey: "rebootCommand"
                    defaultValue: "systemctl reboot"
                }
                CommandField {
                    iconName: "bedtime"
                    title: "Suspend Command"
                    description: "Command executed to sleep/suspend the machine."
                    settingKey: "suspendCommand"
                    defaultValue: "systemctl suspend"
                }
                CommandField {
                    iconName: "logout"
                    title: "Log Out Command"
                    description: "Command to log out of the session."
                    settingKey: "logoutCommand"
                    defaultValue: "loginctl terminate-session"
                }
                CommandField {
                    iconName: "lock"
                    title: "Lock Screen Command"
                    description: "Command to lock the screen."
                    settingKey: "lockCommand"
                    defaultValue: "loginctl lock-session"
                }
                CommandField {
                    iconName: "terminal"
                    title: "Restart DMS Command"
                    description: "Command to restart the shell."
                    settingKey: "dmsRestartCommand"
                    defaultValue: "dms restart"
                }
            }
        }

        // ---------------------------------------------------------------------
        // IPC COMMANDS & SHORTCUTS
        // ---------------------------------------------------------------------
        SectionContainer {
            Column {
                width: parent.width
                spacing: Theme.spacingM

                Row {
                    width: parent.width
                    spacing: Theme.spacingM
                    DankIcon {
                        name: "keyboard_command_key"
                        size: 22
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: 0.8
                    }
                    Column {
                        width: Math.max(0, parent.width - 22 - Theme.spacingM)
                        StyledText {
                            text: "IPC Commands & Shortcuts"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                        StyledText {
                            text: "You can open, close, or toggle the Power Menu using the dms CLI:"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                CopyBox {
                    label: "Toggle Modal Command"
                    text: "dms ipc call fullscreenPowerMenu toggle"
                }

                CopyBox {
                    label: "Open Modal Command"
                    text: "dms ipc call fullscreenPowerMenu open"
                }

                CopyBox {
                    label: "Close Modal Command"
                    text: "dms ipc call fullscreenPowerMenu close"
                }

                StyledText {
                    width: parent.width
                    text: "To trigger the power menu using Mod+Escape, add this spawn command to your Niri configuration binds:"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.primary
                    font.italic: true
                    wrapMode: Text.WordWrap
                }

                CopyBox {
                    label: "Niri Bind Configuration"
                    text: "Mod+Delete { spawn \"dms\" \"ipc\" \"call\" \"fullscreenPowerMenu\" \"toggle\"; }"
                }
            }
        }
    }
}

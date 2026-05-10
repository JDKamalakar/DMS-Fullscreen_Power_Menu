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
                width: parent.width - 22 - 22 - Theme.spacingM * 2
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
            DankIcon {
                name: "restart_alt"
                size: 22
                anchors.verticalCenter: parent.verticalCenter
                opacity: slider.value !== sliderSection.defaultValue && sliderSection.sliderEnabled ? 0.8 : 0.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
                NumberAnimation {
                    id: resetAnim
                    target: slider
                    property: "value"
                    to: sliderSection.defaultValue
                    duration: 300
                    easing.type: Easing.OutCubic
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: slider.value !== sliderSection.defaultValue && sliderSection.sliderEnabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        resetAnim.restart();
                        root.saveValue(sliderSection.settingKey, sliderSection.defaultValue);
                    }
                }
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
                width: parent.width - 22 - Theme.spacingM
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
                        width: parent.width - 22 - Theme.spacingM
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

                DankToggle {
                    id: animToggle
                    width: parent.width
                    text: "Animations"
                    description: "Enable or disable all menu animations."
                    property string settingKey: "animationsEnabled"
                    property bool defaultValue: true
                    function loadValue() {
                        if (root) {
                            var loaded = root.loadValue(settingKey, defaultValue);
                            checked = loaded === true || loaded === "true";
                        }
                    }
                    Component.onCompleted: loadValue()
                    onToggled: function (checked) {
                        root.saveValue(settingKey, checked);
                    }
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
    }
}

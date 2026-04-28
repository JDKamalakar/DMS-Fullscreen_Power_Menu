import QtQuick
import Quickshell

import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "fullscreenPowerMenu"

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
                    if (item.loadValue) item.loadValue();
                    else if (item.children) {
                        for (var j = 0; j < item.children.length; j++) {
                            var subItem = item.children[j];
                            if (subItem.loadValue) subItem.loadValue();
                        }
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
        // ORIENTATION SETTINGS CONTAINER
        // ---------------------------------------------------------------------
        Rectangle {
            width: parent.width
            height: orientationGroup.implicitHeight + Theme.spacingM * 2
            color: Theme.surfaceContainer
            radius: Theme.cornerRadius
            border.color: Theme.outline
            border.width: 1
            opacity: 0.8

            Column {
                id: orientationGroup
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingM

                // -------------------------------------------------------------
                // Menu Orientation
                // -------------------------------------------------------------
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    Row {
                        width: parent.width
                        spacing: Theme.spacingM
                        DankIcon { name: "screen_rotation"; size: 22; anchors.verticalCenter: parent.verticalCenter; opacity: 0.8 }
                        Column {
                            width: parent.width - 22 - Theme.spacingM
                            StyledText { text: "Menu Orientation"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: "Change the button grid flow depending on device orientation."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                        }
                    }
                    DankDropdown {
                        id: orientationDropdown
                        width: parent.width

                        property string settingKey: "menuOrientation"
                        property string defaultValue: "dynamic"
                        property var optionList: [
                            { label: "Dynamic (Auto-detect)", value: "dynamic" },
                            { label: "Horizontal Flow", value: "horizontal" },
                            { label: "Vertical Flow", value: "vertical" }
                        ]

                        options: ["Dynamic (Auto-detect)", "Horizontal Flow", "Vertical Flow"]
                        
                        function loadValue() {
                            var settings = root;
                            if (settings) {
                                var loadedVal = settings.loadValue(settingKey, defaultValue);
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
        }

        // ---------------------------------------------------------------------
        // APPEARANCE SETTINGS CONTAINER
        // ---------------------------------------------------------------------
        Rectangle {
            width: parent.width
            height: generalGroup.implicitHeight + Theme.spacingM * 2
            color: Theme.surfaceContainer
            radius: Theme.cornerRadius
            border.color: Theme.outline
            border.width: 1
            opacity: 0.8

            Column {
                id: generalGroup
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingM

                // -------------------------------------------------------------
                // Menu Transparency
                // -------------------------------------------------------------
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    Row {
                        width: parent.width
                        spacing: Theme.spacingM
                        DankIcon { name: "visibility"; size: 22; anchors.verticalCenter: parent.verticalCenter; opacity: 0.8 }
                        Column {
                            width: parent.width - 22 - 22 - Theme.spacingM * 2
                            StyledText { text: "Menu Transparency"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: "Opacity of the power menu floating container."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                        }
                        DankIcon {
                            name: "restart_alt"
                            size: 22
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: menuOpacitySlider.value !== 20 ? 0.8 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            NumberAnimation {
                                id: menuOpacityAnim
                                target: menuOpacitySlider
                                property: "value"
                                to: menuOpacitySlider.defaultValue
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: menuOpacitySlider.value !== 20
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    menuOpacityAnim.restart();
                                    root.saveValue(menuOpacitySlider.settingKey, menuOpacitySlider.defaultValue);
                                }
                            }
                        }
                    }
                    DankSlider {
                        id: menuOpacitySlider
                        property int defaultValue: 20
                        property string settingKey: "menuOpacity"
                        width: parent.width
                        minimum: 0
                        maximum: 100
                        unit: "%"
                        function loadValue() {
                            var settings = root;
                            if (settings) {
                                value = settings.loadValue(settingKey, defaultValue);
                            }
                        }
                        Component.onCompleted: loadValue()
                        onSliderValueChanged: newValue => {
                            value = newValue;
                            root.saveValue(settingKey, newValue);
                        }
                    }
                }

                // -------------------------------------------------------------
                // Dim Intensity
                // -------------------------------------------------------------
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    Row {
                        width: parent.width
                        spacing: Theme.spacingM
                        DankIcon { name: "opacity"; size: 22; anchors.verticalCenter: parent.verticalCenter; opacity: 0.8 }
                        Column {
                            width: parent.width - 22 - 22 - Theme.spacingM * 2
                            StyledText { text: "Background Dim Intensity"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: "How dark the background dims when the menu is open."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                        }
                        DankIcon {
                            name: "restart_alt"
                            size: 22
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: dimOpacitySlider.value !== 60 ? 0.8 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            NumberAnimation {
                                id: dimOpacityAnim
                                target: dimOpacitySlider
                                property: "value"
                                to: dimOpacitySlider.defaultValue
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: dimOpacitySlider.value !== 60
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    dimOpacityAnim.restart();
                                    root.saveValue(dimOpacitySlider.settingKey, dimOpacitySlider.defaultValue);
                                }
                            }
                        }
                    }
                    DankSlider {
                        id: dimOpacitySlider
                        property int defaultValue: 60
                        property string settingKey: "dimOpacity"
                        width: parent.width
                        minimum: 0
                        maximum: 100
                        unit: "%"
                        function loadValue() {
                            var settings = root;
                            if (settings) {
                                value = settings.loadValue(settingKey, defaultValue);
                            }
                        }
                        Component.onCompleted: loadValue()
                        onSliderValueChanged: newValue => {
                            value = newValue;
                            root.saveValue(settingKey, newValue);
                        }
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
        // COMMAND EXECUTION SETTINGS CONTAINER
        // ---------------------------------------------------------------------
        Rectangle {
            width: parent.width
            height: cmdGroup.implicitHeight + Theme.spacingM * 2
            color: Theme.surfaceContainer
            radius: Theme.cornerRadius
            border.color: Theme.outline
            border.width: 1
            opacity: 0.8

            Column {
                id: cmdGroup
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingM

            // -----------------------------------------------------------------
            // Shutdown Cmd
            // -----------------------------------------------------------------
            Column {
                width: parent.width
                spacing: Theme.spacingM
                Row {
                    width: parent.width
                    spacing: Theme.spacingM
                    DankIcon { name: "power_settings_new"; size: 22; anchors.verticalCenter: parent.verticalCenter; opacity: 0.8 }
                    Column {
                        width: parent.width - 22 - Theme.spacingM
                        StyledText { text: "Shutdown Command"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                        StyledText { text: "Command executed to power off the machine."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                    }
                }
                DankTextField {
                    id: shutdownCmdField
                    property string settingKey: "shutdownCommand"
                    property string defaultValue: "systemctl poweroff"
                    width: parent.width
                    text: defaultValue
                    function loadValue() {
                        var settings = root;
                        if (settings) {
                            text = settings.loadValue(settingKey, defaultValue);
                        }
                    }
                    Component.onCompleted: loadValue()
                    onEditingFinished: {
                        root.saveValue(settingKey, text);
                    }
                }
            }

            // -----------------------------------------------------------------
            // Restart Cmd
            // -----------------------------------------------------------------
            Column {
                width: parent.width
                spacing: Theme.spacingM
                Row {
                    width: parent.width
                    spacing: Theme.spacingM
                    DankIcon { name: "restart_alt"; size: 22; anchors.verticalCenter: parent.verticalCenter; opacity: 0.8 }
                    Column {
                        width: parent.width - 22 - Theme.spacingM
                        StyledText { text: "Restart Command"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                        StyledText { text: "Command executed to reboot the machine."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                    }
                }
                DankTextField {
                    id: rebootCmdField
                    property string settingKey: "rebootCommand"
                    property string defaultValue: "systemctl reboot"
                    width: parent.width
                    text: defaultValue
                    function loadValue() {
                        var settings = root;
                        if (settings) {
                            text = settings.loadValue(settingKey, defaultValue);
                        }
                    }
                    Component.onCompleted: loadValue()
                    onEditingFinished: {
                        root.saveValue(settingKey, text);
                    }
                }
            }

            // -----------------------------------------------------------------
            // Suspend Cmd
            // -----------------------------------------------------------------
            Column {
                width: parent.width
                spacing: Theme.spacingM
                Row {
                    width: parent.width
                    spacing: Theme.spacingM
                    DankIcon { name: "bedtime"; size: 22; anchors.verticalCenter: parent.verticalCenter; opacity: 0.8 }
                    Column {
                        width: parent.width - 22 - Theme.spacingM
                        StyledText { text: "Suspend Command"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                        StyledText { text: "Command executed to sleep/suspend the machine."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                    }
                }
                DankTextField {
                    id: suspendCmdField
                    property string settingKey: "suspendCommand"
                    property string defaultValue: "systemctl suspend"
                    width: parent.width
                    text: defaultValue
                    function loadValue() {
                        var settings = root;
                        if (settings) {
                            text = settings.loadValue(settingKey, defaultValue);
                        }
                    }
                    Component.onCompleted: loadValue()
                    onEditingFinished: {
                        root.saveValue(settingKey, text);
                    }
                }
            }

            // -----------------------------------------------------------------
            // Logout Cmd
            // -----------------------------------------------------------------
            Column {
                width: parent.width
                spacing: Theme.spacingM
                Row {
                    width: parent.width
                    spacing: Theme.spacingM
                    DankIcon { name: "logout"; size: 22; anchors.verticalCenter: parent.verticalCenter; opacity: 0.8 }
                    Column {
                        width: parent.width - 22 - Theme.spacingM
                        StyledText { text: "Log Out Command"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                        StyledText { text: "Command to log out of the session."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                    }
                }
                DankTextField {
                    id: logoutCmdField
                    property string settingKey: "logoutCommand"
                    property string defaultValue: "loginctl terminate-session"
                    width: parent.width
                    text: defaultValue
                    function loadValue() {
                        var settings = root;
                        if (settings) {
                            text = settings.loadValue(settingKey, defaultValue);
                        }
                    }
                    Component.onCompleted: loadValue()
                    onEditingFinished: {
                        root.saveValue(settingKey, text);
                    }
                }
            }

            // -----------------------------------------------------------------
            // Lock Screen Cmd
            // -----------------------------------------------------------------
            Column {
                width: parent.width
                spacing: Theme.spacingM
                Row {
                    width: parent.width
                    spacing: Theme.spacingM
                    DankIcon { name: "lock"; size: 22; anchors.verticalCenter: parent.verticalCenter; opacity: 0.8 }
                    Column {
                        width: parent.width - 22 - Theme.spacingM
                        StyledText { text: "Lock Screen Command"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                        StyledText { text: "Command to lock the screen."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                    }
                }
                DankTextField {
                    id: lockCmdField
                    property string settingKey: "lockCommand"
                    property string defaultValue: "loginctl lock-session"
                    width: parent.width
                    text: defaultValue
                    function loadValue() {
                        var settings = root;
                        if (settings) {
                            text = settings.loadValue(settingKey, defaultValue);
                        }
                    }
                    Component.onCompleted: loadValue()
                    onEditingFinished: {
                        root.saveValue(settingKey, text);
                    }
                }
            }

            // -----------------------------------------------------------------
            // DMS Restart Cmd
            // -----------------------------------------------------------------
            Column {
                width: parent.width
                spacing: Theme.spacingM
                Row {
                    width: parent.width
                    spacing: Theme.spacingM
                    DankIcon { name: "terminal"; size: 22; anchors.verticalCenter: parent.verticalCenter; opacity: 0.8 }
                    Column {
                        width: parent.width - 22 - Theme.spacingM
                        StyledText { text: "Restart DMS Command"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                        StyledText { text: "Command to restart the shell."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                    }
                }
                DankTextField {
                    id: dmsRestartCmdField
                    property string settingKey: "dmsRestartCommand"
                    property string defaultValue: "dms restart"
                    width: parent.width
                    text: defaultValue
                    function loadValue() {
                        var settings = root;
                        if (settings) {
                            text = settings.loadValue(settingKey, defaultValue);
                        }
                    }
                    Component.onCompleted: loadValue()
                    onEditingFinished: {
                        root.saveValue(settingKey, text);
                    }
                }
            }
        }
    }
}
}

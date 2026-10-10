import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.Services

PluginSettings {
    id: root
    pluginId: "fullscreenPowerMenu"

    readonly property real outerR: Theme.cornerRadius || 12
    readonly property real innerR: 4

    function loadValue(key, def) {
        if (typeof PluginService !== "undefined" && PluginService && PluginService.loadPluginData) {
            return PluginService.loadPluginData(root.pluginId, key, def);
        }
        return def;
    }

    function saveValue(key, val) {
        if (typeof PluginService !== "undefined" && PluginService && PluginService.savePluginData) {
            PluginService.savePluginData(root.pluginId, key, val);
            if (PluginService.setGlobalVar) {
                PluginService.setGlobalVar(root.pluginId, key, val);
            }
        }
    }

    Connections {
        target: PluginService
        ignoreUnknownSignals: true
        function onPluginDataChanged(pId) {
            if (pId === root.pluginId) {
                rootWrapper.loadValue();
            }
        }
        function onGlobalVarChanged(pId, varName) {
            if (pId === root.pluginId) {
                rootWrapper.loadValue();
            }
        }
    }

    // -------------------------------------------------------------------------
    // REUSABLE COMPONENTS
    // -------------------------------------------------------------------------

    component SectionHeader: Row {
        property string title: ""
        property string iconName: ""

        spacing: Theme.spacingXS
        leftPadding: Theme.spacingM

        DankIcon {
            name: iconName
            size: 16
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: title
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.DemiBold
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    component SettingsSliderItem: Rectangle {
        id: sliderCard
        width: parent.width
        implicitHeight: sliderInnerCol.implicitHeight + Theme.spacingM * 2
        color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
        border.width: 1
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

        property string iconName: ""
        property string title: ""
        property string description: ""
        property string settingKey: ""
        property int defaultValue: 0
        property int minimumValue: 0
        property int maximumValue: 100
        property string unit: "%"
        property bool sliderEnabled: true

        property bool isFirst: false
        property bool isLast: false
        property bool isSingle: false

        topLeftRadius: (isFirst || isSingle) ? root.outerR : root.innerR
        topRightRadius: (isFirst || isSingle) ? root.outerR : root.innerR
        bottomLeftRadius: (isLast || isSingle) ? root.outerR : root.innerR
        bottomRightRadius: (isLast || isSingle) ? root.outerR : root.innerR

        function loadValue() {
            slider.loadValue();
        }

        Column {
            id: sliderInnerCol
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            RowLayout {
                width: parent.width
                spacing: Theme.spacingM

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                    Layout.alignment: Qt.AlignVCenter

                    DankIcon {
                        name: sliderCard.iconName
                        size: 18
                        color: Theme.primary
                        anchors.centerIn: parent
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2
                    StyledText {
                        text: sliderCard.title
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }
                    StyledText {
                        text: sliderCard.description
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    id: resetBtn
                    width: 32
                    height: 32
                    radius: 16
                    Layout.alignment: Qt.AlignVCenter
                    color: resetMa.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.04)
                    border.color: resetMa.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4) : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.15)
                    border.width: 1
                    opacity: (slider.value !== sliderCard.defaultValue && sliderCard.sliderEnabled) ? (resetMa.containsMouse ? 1.0 : 0.9) : 0.0
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
                        size: 16
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
                        enabled: slider.value !== sliderCard.defaultValue && sliderCard.sliderEnabled
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            resetAnim.restart();
                            root.saveValue(sliderCard.settingKey, sliderCard.defaultValue);
                        }
                        onPressed: (m) => resetRip.trigger(m.x, m.y)
                    }
                }

                NumberAnimation {
                    id: resetAnim
                    target: slider
                    property: "value"
                    to: sliderCard.defaultValue
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            RowLayout {
                width: parent.width
                spacing: Theme.spacingM

                DankSlider {
                    id: slider
                    property string settingKey: sliderCard.settingKey
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    minimum: sliderCard.minimumValue
                    maximum: sliderCard.maximumValue
                    unit: sliderCard.unit
                    enabled: sliderCard.sliderEnabled
                    function loadValue() {
                        if (root)
                            value = root.loadValue(settingKey, sliderCard.defaultValue);
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

                Rectangle {
                    id: smallBox
                    width: 64
                    height: 32
                    color: Theme.surfaceContainerHigh
                    radius: height / 2
                    border.color: textInput.activeFocus ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.20)
                    border.width: 1
                    Layout.alignment: Qt.AlignVCenter
                    opacity: sliderCard.sliderEnabled ? 1.0 : 0.4

                    TextInput {
                        id: textInput
                        anchors.fill: parent
                        anchors.margins: 4
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Theme.surfaceText
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                        enabled: sliderCard.sliderEnabled
                        text: activeFocus ? slider.value.toString() : (slider.value + (sliderCard.unit ? sliderCard.unit : ""))
                        selectByMouse: true

                        onEditingFinished: {
                            var cleanText = text.replace(/[^0-9.-]/g, "").trim();
                            var parsed = parseInt(cleanText, 10);
                            if (!isNaN(parsed)) {
                                var clamped = Math.max(sliderCard.minimumValue, Math.min(sliderCard.maximumValue, parsed));
                                slider.value = clamped;
                                root.saveValue(sliderCard.settingKey, clamped);
                            }
                            textInput.focus = false;
                        }

                        onAccepted: {
                            editingFinished();
                        }
                    }
                }
            }
        }
    }

    component SettingsToggleItem: Rectangle {
        id: toggleCard
        width: parent.width
        height: 56
        color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
        border.width: 1
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

        property string iconName: ""
        property string title: ""
        property string description: ""
        property string settingKey: ""
        property bool defaultValue: false

        property bool isFirst: false
        property bool isLast: false
        property bool isSingle: false

        property alias checked: toggle.checked

        topLeftRadius: (isFirst || isSingle) ? root.outerR : root.innerR
        topRightRadius: (isFirst || isSingle) ? root.outerR : root.innerR
        bottomLeftRadius: (isLast || isSingle) ? root.outerR : root.innerR
        bottomRightRadius: (isLast || isSingle) ? root.outerR : root.innerR

        function loadValue() {
            if (root) {
                var loaded = root.loadValue(settingKey, defaultValue);
                checked = loaded === true || loaded === "true";
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingM
            anchors.rightMargin: Theme.spacingM
            spacing: Theme.spacingM

            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: toggle.checked ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15) : Qt.rgba(Theme.surfaceContainerHighest.r, Theme.surfaceContainerHighest.g, Theme.surfaceContainerHighest.b, 0.5)
                Layout.alignment: Qt.AlignVCenter
                Behavior on color { ColorAnimation { duration: 150 } }

                DankIcon {
                    name: toggleCard.iconName
                    size: 18
                    color: toggle.checked ? Theme.primary : Theme.surfaceVariantText
                    anchors.centerIn: parent
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2
                StyledText {
                    text: toggleCard.title
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
                StyledText {
                    text: toggleCard.description
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            DankToggle {
                id: toggle
                Layout.alignment: Qt.AlignVCenter
                Component.onCompleted: toggleCard.loadValue()
                onToggled: function (newChecked) {
                    root.saveValue(toggleCard.settingKey, newChecked);
                }
            }
        }
    }

    component CommandFieldItem: Rectangle {
        id: cmdCard
        width: parent.width
        implicitHeight: cmdCol.implicitHeight + Theme.spacingM * 2
        color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
        border.width: 1
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

        property string iconName: ""
        property string title: ""
        property string description: ""
        property string settingKey: ""
        property string defaultValue: ""

        property bool isFirst: false
        property bool isLast: false
        property bool isSingle: false

        topLeftRadius: (isFirst || isSingle) ? root.outerR : root.innerR
        topRightRadius: (isFirst || isSingle) ? root.outerR : root.innerR
        bottomLeftRadius: (isLast || isSingle) ? root.outerR : root.innerR
        bottomRightRadius: (isLast || isSingle) ? root.outerR : root.innerR

        function loadValue() {
            textField.loadValue();
        }

        Column {
            id: cmdCol
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            RowLayout {
                width: parent.width
                spacing: Theme.spacingM

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                    Layout.alignment: Qt.AlignVCenter

                    DankIcon {
                        name: cmdCard.iconName
                        size: 18
                        color: Theme.primary
                        anchors.centerIn: parent
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2
                    StyledText {
                        text: cmdCard.title
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }
                    StyledText {
                        text: cmdCard.description
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }

            DankTextField {
                id: textField
                property string settingKey: cmdCard.settingKey
                width: parent.width
                text: cmdCard.defaultValue
                function loadValue() {
                    if (root)
                        text = root.loadValue(settingKey, cmdCard.defaultValue);
                }
                Component.onCompleted: loadValue()
                onEditingFinished: root.saveValue(settingKey, text)
            }
        }
    }

    // -------------------------------------------------------------------------
    // SETTINGS UI
    // -------------------------------------------------------------------------

    Column {
        id: rootWrapper
        width: parent.width
        spacing: Theme.spacingL

        function loadValue() {
            var groups = [appearanceGroup, orientationGroup, cmdGroup];
            for (var g = 0; g < groups.length; g++) {
                var group = groups[g];
                for (var i = 0; i < group.children.length; i++) {
                    var item = group.children[i];
                    if (item && item.loadValue)
                        item.loadValue();
                }
            }
        }

        // ---------------------------------------------------------------------
        // 1. APPEARANCE PREFERENCES
        // ---------------------------------------------------------------------
        Column {
            width: parent.width
            spacing: Theme.spacingS

            SectionHeader {
                title: "Appearance Preferences"
                iconName: "palette"
            }

            Column {
                id: appearanceGroup
                width: parent.width
                spacing: 2

                SettingsSliderItem {
                    iconName: "visibility"
                    title: "Menu Transparency"
                    description: "Opacity of the power menu floating container"
                    settingKey: "menuOpacity"
                    defaultValue: 20
                    maximumValue: 100
                    isFirst: true
                }

                SettingsSliderItem {
                    iconName: "opacity"
                    title: "Background Dim Intensity"
                    description: "How dark the background dims when the menu is open"
                    settingKey: "dimOpacity"
                    defaultValue: 60
                    maximumValue: 100
                }

                SettingsToggleItem {
                    id: animToggle
                    iconName: "auto_fix_high"
                    title: "Animations"
                    description: "Enable or disable all menu animations"
                    settingKey: "animationsEnabled"
                    defaultValue: true
                }

                SettingsSliderItem {
                    iconName: "speed"
                    title: "Animation Speed"
                    description: "Controls the speed of all menu animations (Higher = faster)"
                    settingKey: "animationSpeed"
                    defaultValue: 100
                    minimumValue: 25
                    maximumValue: 300
                    sliderEnabled: animToggle.checked
                    opacity: animToggle.checked ? 1.0 : 0.4
                }

                SettingsSliderItem {
                    iconName: "shapes"
                    title: "Shape Morphing Speed"
                    description: "Controls the speed of button shape morphing on hover (Higher = faster)"
                    settingKey: "shapeAnimationSpeed"
                    defaultValue: 100
                    minimumValue: 25
                    maximumValue: 300
                    sliderEnabled: animToggle.checked
                    opacity: animToggle.checked ? 1.0 : 0.4
                }

                SettingsToggleItem {
                    id: tintToggle
                    iconName: "palette"
                    title: "Primary Color Tint"
                    description: "Apply a subtle primary color tint to the menu background"
                    settingKey: "primaryTintEnabled"
                    defaultValue: false
                }

                SettingsSliderItem {
                    iconName: "format_color_fill"
                    title: "Tint Intensity"
                    description: "Adjust the intensity of the primary color tint"
                    settingKey: "tintIntensity"
                    defaultValue: 30
                    minimumValue: 5
                    maximumValue: 100
                    sliderEnabled: tintToggle.checked
                    opacity: tintToggle.checked ? 1.0 : 0.4
                    isLast: true
                }
            }
        }

        // ---------------------------------------------------------------------
        // 2. ORIENTATION PREFERENCES
        // ---------------------------------------------------------------------
        Column {
            width: parent.width
            spacing: Theme.spacingS

            SectionHeader {
                title: "Orientation Preferences"
                iconName: "screen_rotation"
            }

            Column {
                id: orientationGroup
                width: parent.width
                spacing: 2

                Rectangle {
                    width: parent.width
                    implicitHeight: orientCol.implicitHeight + Theme.spacingM * 2
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)
                    radius: root.outerR

                    function loadValue() {
                        orientationDropdown.loadValue();
                    }

                    Column {
                        id: orientCol
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingM

                        RowLayout {
                            width: parent.width
                            spacing: Theme.spacingM

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                Layout.alignment: Qt.AlignVCenter

                                DankIcon {
                                    name: "screen_rotation"
                                    size: 18
                                    color: Theme.primary
                                    anchors.centerIn: parent
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2
                                StyledText {
                                    text: "Menu Orientation"
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }
                                StyledText {
                                    text: "Change the button grid flow depending on device orientation"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
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
            }
        }

        // ---------------------------------------------------------------------
        // 3. ACTIONS & COMMANDS
        // ---------------------------------------------------------------------
        Column {
            width: parent.width
            spacing: Theme.spacingS

            SectionHeader {
                title: "Action Commands"
                iconName: "terminal"
            }

            Column {
                id: cmdGroup
                width: parent.width
                spacing: 2

                CommandFieldItem {
                    iconName: "power_settings_new"
                    title: "Shutdown Command"
                    description: "Command executed to power off the machine"
                    settingKey: "shutdownCommand"
                    defaultValue: "systemctl poweroff"
                    isFirst: true
                }

                CommandFieldItem {
                    iconName: "restart_alt"
                    title: "Restart Command"
                    description: "Command executed to reboot the machine"
                    settingKey: "rebootCommand"
                    defaultValue: "systemctl reboot"
                }

                CommandFieldItem {
                    iconName: "bedtime"
                    title: "Suspend Command"
                    description: "Command executed to sleep/suspend the machine"
                    settingKey: "suspendCommand"
                    defaultValue: "systemctl suspend"
                }

                CommandFieldItem {
                    iconName: "logout"
                    title: "Log Out Command"
                    description: "Command to log out of the session"
                    settingKey: "logoutCommand"
                    defaultValue: "loginctl terminate-session"
                }

                CommandFieldItem {
                    iconName: "lock"
                    title: "Lock Screen Command"
                    description: "Command to lock the screen"
                    settingKey: "lockCommand"
                    defaultValue: "loginctl lock-session"
                }

                CommandFieldItem {
                    iconName: "terminal"
                    title: "Restart DMS Command"
                    description: "Command to restart the shell"
                    settingKey: "dmsRestartCommand"
                    defaultValue: "dms restart"
                    isLast: true
                }
            }
        }

        // ---------------------------------------------------------------------
        // 4. IPC COMMANDS & SHORTCUTS
        // ---------------------------------------------------------------------
        Column {
            width: parent.width
            spacing: Theme.spacingS

            SectionHeader {
                title: "IPC Commands & Shortcuts"
                iconName: "keyboard_command_key"
            }

            Rectangle {
                width: parent.width
                implicitHeight: ipcInnerCol.implicitHeight + Theme.spacingM * 2
                radius: root.outerR
                color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                border.width: 1
                border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                Column {
                    id: ipcInnerCol
                    width: parent.width - Theme.spacingM * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacingM
                    spacing: Theme.spacingM

                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM

                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                text: "Control and trigger the Power Menu via IPC and keybinds"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: parent.width
                                wrapMode: Text.WordWrap
                            }
                        }

                        Rectangle {
                            id: openToolbarBtn
                            Layout.preferredHeight: 34
                            Layout.preferredWidth: openToolbarRow.implicitWidth + 24
                            Layout.alignment: Qt.AlignVCenter
                            property bool isHovered: openToolbarMa.containsMouse

                            radius: isHovered ? (height / 2) : (Theme.cornerRadius || 12)
                            Behavior on radius { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }

                            color: isHovered ? Theme.withAlpha(Theme.primary, 0.25) : Theme.withAlpha(Theme.primary, 0.15)
                            Behavior on color { ColorAnimation { duration: 150 } }
                            border.width: 1
                            border.color: isHovered ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            scale: openToolbarMa.pressed ? 0.94 : (isHovered ? 1.02 : 1.0)
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                            DankRipple {
                                id: openToolbarRip
                                anchors.fill: parent
                                cornerRadius: parent.radius
                                rippleColor: Theme.primary
                            }

                            RowLayout {
                                id: openToolbarRow
                                anchors.centerIn: parent
                                spacing: 6

                                DankIcon {
                                    name: "open_in_new"
                                    size: 16
                                    color: Theme.primary
                                }

                                StyledText {
                                    text: "Toggle Power Menu"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.primary
                                }
                            }

                            MouseArea {
                                id: openToolbarMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPressed: (m) => openToolbarRip.trigger(m.x, m.y)
                                onClicked: {
                                    Proc.runCommand("launch-powermenu", ["dms", "ipc", "call", "fullscreenPowerMenu", "toggle"], function() {
                                        if (typeof ToastService !== "undefined" && ToastService) {
                                            ToastService.showInfo("Toggled Power Menu");
                                        }
                                    });
                                }
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
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Widgets
import qs.DCommon.Widgets
import qs.Modules.Plugins
import QtQuick.Shapes
PluginComponent {
    id: root

    PluginGlobalVar { varName: "animationsEnabled"; onValueChanged: { root.animationsEnabled = value !== false } }
    PluginGlobalVar { varName: "animationSpeed"; onValueChanged: { root.animationSpeed = (value != null ? value : 100) } }
    PluginGlobalVar { varName: "shapeAnimationSpeed"; onValueChanged: { root.shapeAnimationSpeed = (value != null ? value : 100) } }
    PluginGlobalVar { varName: "primaryTintEnabled"; onValueChanged: { root.primaryTintEnabled = value === true } }
    PluginGlobalVar { varName: "tintIntensity"; onValueChanged: { root.tintIntensityVal = (value != null ? value : 30) } }
    PluginGlobalVar { varName: "dimOpacity"; onValueChanged: { root.dimOpacityVal = (value != null ? value : 60) } }
    PluginGlobalVar { varName: "menuOpacity"; onValueChanged: { root.menuOpacityVal = (value != null ? value : 20) } }
    PluginGlobalVar { varName: "menuOrientation"; onValueChanged: { root.menuOrientation = (value ? value : "dynamic") } }

    Connections {
        target: root.pluginService || (typeof PluginService !== "undefined" ? PluginService : null)
        ignoreUnknownSignals: true
        function onPluginDataChanged(pId) {
            if (pId === "fullscreenPowerMenu") root.syncFromPluginData();
        }
        function onGlobalVarChanged(pId, varName, value) {
            if (pId === "fullscreenPowerMenu") {
                const effectiveValue = value !== undefined ? value : (root.pluginService ? root.pluginService.getGlobalVar(pId, varName, undefined) : undefined);
                if (effectiveValue === undefined) return;

                if (varName === "animationsEnabled") root.animationsEnabled = effectiveValue !== false;
                else if (varName === "animationSpeed") root.animationSpeed = (effectiveValue != null ? effectiveValue : 100);
                else if (varName === "shapeAnimationSpeed") root.shapeAnimationSpeed = (effectiveValue != null ? effectiveValue : 100);
                else if (varName === "primaryTintEnabled") root.primaryTintEnabled = effectiveValue === true;
                else if (varName === "tintIntensity") root.tintIntensityVal = (effectiveValue != null ? effectiveValue : 30);
                else if (varName === "dimOpacity") root.dimOpacityVal = (effectiveValue != null ? effectiveValue : 60);
                else if (varName === "menuOpacity") root.menuOpacityVal = (effectiveValue != null ? effectiveValue : 20);
                else if (varName === "menuOrientation") root.menuOrientation = (effectiveValue ? effectiveValue : "dynamic");
            }
        }
    }

    property bool animationsEnabled: pluginData ? pluginData.animationsEnabled !== false : true
    property real animationSpeed: pluginData && pluginData.animationSpeed != null ? pluginData.animationSpeed : 100
    property real shapeAnimationSpeed: pluginData && pluginData.shapeAnimationSpeed != null ? pluginData.shapeAnimationSpeed : 100
    property bool primaryTintEnabled: pluginData ? pluginData.primaryTintEnabled === true : false
    property real tintIntensityVal: pluginData && pluginData.tintIntensity != null ? pluginData.tintIntensity : 30
    property real dimOpacityVal: pluginData && pluginData.dimOpacity != null ? pluginData.dimOpacity : 60
    property real menuOpacityVal: pluginData && pluginData.menuOpacity != null ? pluginData.menuOpacity : 20
    property string menuOrientation: pluginData && pluginData.menuOrientation ? pluginData.menuOrientation : "dynamic"

    property real speedMultiplier: !animationsEnabled ? 0 : (root.animationSpeed > 0 ? 100 / root.animationSpeed : 1.0)
    property real shapeSpeedMultiplier: !animationsEnabled ? 0 : (root.shapeAnimationSpeed > 0 ? 100 / root.shapeAnimationSpeed : 1.0)
    property real shapeRateMultiplier: !animationsEnabled ? 0 : (root.shapeAnimationSpeed > 0 ? root.shapeAnimationSpeed / 100 : 1.0)
    property real dimOpacity: root.dimOpacityVal / 100
    property real menuOpacity: root.menuOpacityVal / 100
    property real tintIntensity: root.tintIntensityVal / 100

    function syncFromPluginData() {
        if (!pluginData) return;
        if (pluginData.animationsEnabled !== undefined) root.animationsEnabled = pluginData.animationsEnabled !== false;
        if (pluginData.animationSpeed !== undefined) root.animationSpeed = pluginData.animationSpeed;
        if (pluginData.shapeAnimationSpeed !== undefined) root.shapeAnimationSpeed = pluginData.shapeAnimationSpeed;
        if (pluginData.primaryTintEnabled !== undefined) root.primaryTintEnabled = pluginData.primaryTintEnabled === true;
        if (pluginData.tintIntensity !== undefined) root.tintIntensityVal = pluginData.tintIntensity;
        if (pluginData.dimOpacity !== undefined) root.dimOpacityVal = pluginData.dimOpacity;
        if (pluginData.menuOpacity !== undefined) root.menuOpacityVal = pluginData.menuOpacity;
        if (pluginData.menuOrientation !== undefined) root.menuOrientation = pluginData.menuOrientation;
    }

    onPluginDataChanged: syncFromPluginData()

    function runCmd(proc, key, fallback) {
        root.closeMenu();
        proc.command = (pluginData && pluginData[key] ? pluginData[key] : fallback).split(" ");
        proc.running = true;
    }

    // -------------------------------------------------------------------------
    // IPC — trigger via: dms ipc fullscreenPowerMenu toggle
    // -------------------------------------------------------------------------

    IpcHandler {
        target: "fullscreenPowerMenu"

        function toggle(): string {
            root.toggleMenu();
            return overlay.visible ? "opened" : "closed";
        }

        function open(): string {
            if (!overlay.visible)
                root.openMenu();
            return "opened";
        }

        function close(): string {
            if (overlay.visible)
                root.closeMenu();
            return "closed";
        }
    }

    function openMenu() {
        overlay.visible = true;
    }
    function closeMenu() {
        overlay.visible = false;
    }
    function toggleMenu() {
        overlay.visible ? root.closeMenu() : root.openMenu();
    }

    // -------------------------------------------------------------------------
    // 1. FULLSCREEN DIM BACKGROUND OVERLAY
    // -------------------------------------------------------------------------

    PanelWindow {
        id: bgOverlay
        visible: overlay.visible
        color: "transparent"

        WlrLayershell.namespace: "dms:plugins:fullscreenPowerMenu:backdrop"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: bgOverlay.visible ? root.dimOpacity : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 400 * root.speedMultiplier
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.closeMenu()
            }
        }
    }

    // -------------------------------------------------------------------------
    // 2. FLOATING POWER MENU WINDOW (BLURRABLE BY NIRI)
    // -------------------------------------------------------------------------

    PanelWindow {
        id: overlay
        visible: false
        color: "transparent"

        WlrLayershell.namespace: "dms:plugins:fullscreenPowerMenu:menu"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: overlay.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        implicitWidth: mainRow.implicitWidth + 48
        implicitHeight: mainRow.implicitHeight + 48

        anchors {
            top: false
            left: false
            right: false
            bottom: false
        }

        Item {
            id: menuContainer
            anchors.fill: parent

            scale: overlay.visible ? 1.0 : 0.95
            opacity: overlay.visible ? 1.0 : 0.0

            transform: [
                Translate {
                    y: overlay.visible ? 0 : 30
                    Behavior on y {
                        NumberAnimation {
                            duration: 400 * root.speedMultiplier
                            easing.type: Easing.OutQuart
                        }
                    }
                }
            ]

            Behavior on scale {
                NumberAnimation {
                    duration: 400 * root.speedMultiplier
                    easing.type: Easing.OutQuart
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 250 * root.speedMultiplier
                }
            }

            MultiEffect {
                anchors.fill: menuCard
                source: menuCard
                shadowEnabled: true
                shadowVerticalOffset: 16
                shadowHorizontalOffset: 0
                shadowBlur: 1.0
                shadowColor: Qt.rgba(0, 0, 0, overlay.visible ? 0.55 : 0.0)
                Behavior on shadowColor {
                    ColorAnimation {
                        duration: 300 * root.speedMultiplier
                    }
                }
            }

            Rectangle {
                id: menuCard
                anchors.fill: parent
                radius: Theme.cornerRadiusLarge
                color: {
                    var surface = Theme.surface || Qt.rgba(0.15, 0.15, 0.15, 1);
                    if (root.primaryTintEnabled && Theme.primary) {
                        // Soft 15% tint blend
                        return Qt.rgba(
                            surface.r * (1.0 - root.tintIntensity) + Theme.primary.r * root.tintIntensity,
                            surface.g * (1.0 - root.tintIntensity) + Theme.primary.g * root.tintIntensity,
                            surface.b * (1.0 - root.tintIntensity) + Theme.primary.b * root.tintIntensity,
                            root.menuOpacity
                        );
                    }
                    return Qt.rgba(surface.r, surface.g, surface.b, root.menuOpacity);
                }
                border.color: {
                    var surface = Theme.surface || Qt.rgba(0.2, 0.2, 0.2, 1);
                    if (root.primaryTintEnabled && Theme.primary) {
                        // Subtle primary border
                        return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25);
                    }
                    return Qt.rgba(surface.r, surface.g, surface.b, 0.20);
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 300 * root.speedMultiplier
                    }
                }
                Behavior on border.color {
                    ColorAnimation {
                        duration: 300 * root.speedMultiplier
                    }
                }

                Keys.onEscapePressed: root.closeMenu()

                GridLayout {
                    id: mainRow
                    anchors.centerIn: parent
                    columnSpacing: Theme.spacingM
                    rowSpacing: Theme.spacingM

                    property string visualOrientation: root.menuOrientation
                    property bool isVerticalCalc: visualOrientation === "vertical" || (visualOrientation === "dynamic" && bgOverlay.height > bgOverlay.width)

                    columns: isVerticalCalc ? 1 : 6
                    rows: isVerticalCalc ? 6 : 1

                    PowerButton {
                        id: lockBtn
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "lock"
                        label: "Lock"
                        iconCode: "lock"
                        shortcutKey: "L"
                        isFirst: true
                        accentColor: "#93C5FD"
                        bgColor: Qt.rgba(0.23, 0.51, 0.96, 0.2)
                        onActivated: runCmd(lockProc, "lockCommand", "loginctl lock-session")
                    }

                    PowerButton {
                        id: sleepBtn
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "sleep"
                        label: "Sleep"
                        iconCode: "bedtime"
                        shortcutKey: "S"
                        accentColor: "#A5B4FC"
                        bgColor: Qt.rgba(0.39, 0.38, 0.96, 0.2)
                        onActivated: runCmd(suspendProc, "suspendCommand", "systemctl suspend")
                    }

                    PowerButton {
                        id: dmsBtn
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "dms"
                        label: "Restart DMS"
                        iconImageSource: "file:///usr/share/icons/hicolor/scalable/apps/com.danklinux.dms.svg"
                        shortcutKey: "D"
                        accentColor: "#FDE047"
                        bgColor: Qt.rgba(0.99, 0.88, 0.28, 0.2)
                        onActivated: runCmd(dmsRestartProc, "dmsRestartCommand", "dms restart")
                    }

                    PowerButton {
                        id: restartBtn
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "restart"
                        label: "Restart"
                        iconCode: "restart_alt"
                        shortcutKey: "R"
                        accentColor: "#86EFAC"
                        bgColor: Qt.rgba(0.13, 0.77, 0.36, 0.2)
                        onActivated: runCmd(rebootProc, "rebootCommand", "systemctl reboot")
                    }

                    PowerButton {
                        id: logoutBtn
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "logout"
                        label: "Log Out"
                        iconCode: "logout"
                        shortcutKey: "X"
                        accentColor: "#FDBA74"
                        bgColor: Qt.rgba(0.97, 0.58, 0.11, 0.2)
                        onActivated: {
                            if (pluginData && pluginData.logoutCommand && pluginData.logoutCommand.trim() !== "") {
                                runCmd(logoutProc, "logoutCommand", pluginData.logoutCommand);
                            } else {
                                root.closeMenu();
                                SessionService.logout();
                            }
                        }
                    }

                    PowerButton {
                        id: powerBtn
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "power"
                        label: "Power Off"
                        iconCode: "power_settings_new"
                        shortcutKey: "P"
                        isLast: true
                        isPrimary: true
                        accentColor: "#FCA5A5"
                        bgColor: Qt.rgba(0.94, 0.26, 0.26, 0.2)
                        onActivated: runCmd(shutdownProc, "shutdownCommand", "systemctl poweroff")
                    }
                }
            }
        }

        Item {
            anchors.fill: parent
            focus: overlay.visible
            Keys.onEscapePressed: root.closeMenu()
            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_L)
                    lockBtn.activated();
                else if (event.key === Qt.Key_S)
                    sleepBtn.activated();
                else if (event.key === Qt.Key_D)
                    dmsBtn.activated();
                else if (event.key === Qt.Key_R)
                    restartBtn.activated();
                else if (event.key === Qt.Key_X)
                    logoutBtn.activated();
                else if (event.key === Qt.Key_P)
                    powerBtn.activated();
            }
        }
    }

    // -------------------------------------------------------------------------
    // PROCESSES
    // -------------------------------------------------------------------------

    Process {
        id: shutdownProc
    }
    Process {
        id: rebootProc
    }
    Process {
        id: suspendProc
    }
    Process {
        id: logoutProc
    }
    Process {
        id: lockProc
    }
    Process {
        id: dmsRestartProc
    }

    // -------------------------------------------------------------------------
    // POWER BUTTON COMPONENT
    // -------------------------------------------------------------------------

    component PowerButton: Item {
        property bool isVerticalFlow: false
        property string buttonId: ""
        property string label: ""
        property string iconCode: ""
        property string iconImageSource: ""
        property string shortcutKey: ""
        property color accentColor: "#D0BCFF"
        property color bgColor: Qt.rgba(1, 1, 1, 0.1)
        property bool isPrimary: false
        property bool isFirst: false
        property bool isLast: false

        property bool applyLightModeFix: Theme.isLightMode && root.menuOpacity > 0.5

        signal activated

        implicitWidth: 140
        implicitHeight: 148

        transform: [
            Scale {
                origin.x: width / 2
                origin.y: height / 2
                xScale: ma.pressed ? 0.92 : 1.0
                yScale: xScale
                Behavior on xScale {
                    NumberAnimation {
                        duration: 150 * root.speedMultiplier
                        easing.type: Easing.OutBack
                    }
                }
            }
        ]

        Shape {
            id: btnBg
            anchors.fill: parent

            property real defaultRadius: Theme.cornerRadius
            property real cornerRadiusLargeVal: Theme.cornerRadiusLarge || (Theme.cornerRadius * 1.75)
            property real hoverRadius: Math.max(0, width - 2) / 2

            property real tlr: ma.containsMouse ? hoverRadius : (isFirst ? cornerRadiusLargeVal : defaultRadius)
            property real tlrAnim: tlr
            Behavior on tlrAnim {
                NumberAnimation {
                    duration: 600 * root.shapeSpeedMultiplier
                    easing.type: Easing.OutExpo
                }
            }

            property real trr: ma.containsMouse ? hoverRadius : (isVerticalFlow ? (isFirst ? cornerRadiusLargeVal : defaultRadius) : (isLast ? cornerRadiusLargeVal : defaultRadius))
            property real trrAnim: trr
            Behavior on trrAnim {
                NumberAnimation {
                    duration: 600 * root.shapeSpeedMultiplier
                    easing.type: Easing.OutExpo
                }
            }

            property real blr: ma.containsMouse ? hoverRadius : (isVerticalFlow ? (isLast ? cornerRadiusLargeVal : defaultRadius) : (isFirst ? cornerRadiusLargeVal : defaultRadius))
            property real blrAnim: blr
            Behavior on blrAnim {
                NumberAnimation {
                    duration: 600 * root.shapeSpeedMultiplier
                    easing.type: Easing.OutExpo
                }
            }

            property real brr: ma.containsMouse ? hoverRadius : (isLast ? cornerRadiusLargeVal : defaultRadius)
            property real brrAnim: brr
            Behavior on brrAnim {
                NumberAnimation {
                    duration: 600 * root.shapeSpeedMultiplier
                    easing.type: Easing.OutExpo
                }
            }

            property color paintColor: (isPrimary || applyLightModeFix) ? (ma.containsMouse ? Qt.rgba(bgColor.r, bgColor.g, bgColor.b, bgColor.a + 0.2) : bgColor) : (ma.containsMouse ? bgColor : Qt.rgba(1, 1, 1, 0.05))

            property color paintBorder: isPrimary ? Qt.rgba(0.94, 0.26, 0.26, 0.3) : ((ma.containsMouse || applyLightModeFix) ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3) : Qt.rgba(1, 1, 1, 0.1))

            Behavior on paintColor {
                ColorAnimation {
                    duration: 150 * root.speedMultiplier
                }
            }
            Behavior on paintBorder {
                ColorAnimation {
                    duration: 150 * root.speedMultiplier
                }
            }

            ShapePath {
                fillColor: btnBg.paintColor
                strokeColor: btnBg.paintBorder
                strokeWidth: 1
                startX: 1 + btnBg.tlrAnim
                startY: 1
                
                PathLine { x: Math.max(0, btnBg.width - 2) - btnBg.trrAnim + 1; y: 1 }
                PathArc {
                    x: Math.max(0, btnBg.width - 2) + 1; y: 1 + btnBg.trrAnim
                    radiusX: btnBg.trrAnim; radiusY: btnBg.trrAnim
                    direction: PathArc.Clockwise
                }
                PathLine { x: Math.max(0, btnBg.width - 2) + 1; y: Math.max(0, btnBg.height - 2) - btnBg.brrAnim + 1 }
                PathArc {
                    x: Math.max(0, btnBg.width - 2) - btnBg.brrAnim + 1; y: Math.max(0, btnBg.height - 2) + 1
                    radiusX: btnBg.brrAnim; radiusY: btnBg.brrAnim
                    direction: PathArc.Clockwise
                }
                PathLine { x: 1 + btnBg.blrAnim; y: Math.max(0, btnBg.height - 2) + 1 }
                PathArc {
                    x: 1; y: Math.max(0, btnBg.height - 2) - btnBg.blrAnim + 1
                    radiusX: btnBg.blrAnim; radiusY: btnBg.blrAnim
                    direction: PathArc.Clockwise
                }
                PathLine { x: 1; y: 1 + btnBg.tlrAnim }
                PathArc {
                    x: 1 + btnBg.tlrAnim; y: 1
                    radiusX: btnBg.tlrAnim; radiusY: btnBg.tlrAnim
                    direction: PathArc.Clockwise
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 6

                Item {
                    width: 74
                    height: 74
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        id: bgCircle
                        anchors.centerIn: parent
                        width: 56
                        height: 56
                        radius: width / 2
                        visible: !ma.containsMouse
                        color: isPrimary ? Qt.rgba(0.94, 0.26, 0.26, 0.3) : (applyLightModeFix ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3) : Qt.rgba(1, 1, 1, 0.1))
                    }

                    DLoadingIndicator {
                        id: shapeLoader
                        anchors.centerIn: parent
                        size: 94
                        visible: ma.containsMouse
                        running: ma.containsMouse
                        color: isPrimary ? Qt.rgba(0.94, 0.26, 0.26, 0.4) : (applyLightModeFix ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.4) : Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3))

                        // Adjust DLoadingIndicator internal elapsed rate dynamically based on shapeAnimationSpeed
                        FrameAnimation {
                            running: shapeLoader.running && root.shapeRateMultiplier !== 1.0
                            onTriggered: {
                                // Default advances by (1.0 * frameTime * 1000).
                                // (rate - 1.0) adjusts elapsed so total speed becomes rate * normal speed.
                                shapeLoader.elapsed += (frameTime * 1000) * (root.shapeRateMultiplier - 1.0);
                            }
                        }
                    }

                    Item {
                        anchors.centerIn: parent
                        width: 36
                        height: 36

                        transform: [
                            Rotation {
                                id: iconRotation
                                origin.x: 18
                                origin.y: 18
                                angle: 0
                            },
                            Scale {
                                origin.x: 18
                                origin.y: 18
                                xScale: ma.containsMouse ? 1.1 : 1.0
                                yScale: xScale
                                Behavior on xScale {
                                    NumberAnimation {
                                        duration: 150 * root.speedMultiplier
                                        easing.type: Easing.OutBack
                                    }
                                }
                            }
                        ]

                        DankIcon {
                            visible: iconCode !== ""
                            anchors.centerIn: parent
                            name: iconCode
                            size: 36
                            color: applyLightModeFix ? "black" : (ma.containsMouse ? accentColor : (isPrimary ? Qt.rgba(1, 0.7, 0.7, 1) : Qt.rgba(1, 1, 1, 0.9)))
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150 * root.speedMultiplier
                                }
                            }
                        }

                        Image {
                            id: urlIconSrc
                            visible: false
                            anchors.fill: parent
                            source: iconImageSource
                            sourceSize: Qt.size(36, 36)
                            fillMode: Image.PreserveAspectFit
                        }
                        MultiEffect {
                            visible: iconImageSource !== ""
                            anchors.fill: urlIconSrc
                            source: urlIconSrc
                            colorization: 1.0
                            colorizationColor: applyLightModeFix ? "black" : (ma.containsMouse ? accentColor : (isPrimary ? Qt.rgba(1, 0.7, 0.7, 1) : Qt.rgba(1, 1, 1, 0.9)))
                            Behavior on colorizationColor {
                                ColorAnimation {
                                    duration: 150 * root.speedMultiplier
                                }
                            }
                        }

                        SequentialAnimation {
                            running: ma.containsMouse
                            loops: Animation.Infinite
                            PauseAnimation {
                                duration: 2000 * root.speedMultiplier
                            }
                            NumberAnimation {
                                target: iconRotation
                                property: "angle"
                                to: -8
                                duration: 140 * root.speedMultiplier
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: iconRotation
                                property: "angle"
                                to: 8
                                duration: 140 * root.speedMultiplier
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: iconRotation
                                property: "angle"
                                to: -4
                                duration: 120 * root.speedMultiplier
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: iconRotation
                                property: "angle"
                                to: 4
                                duration: 120 * root.speedMultiplier
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: iconRotation
                                property: "angle"
                                to: 0
                                duration: 120 * root.speedMultiplier
                                easing.type: Easing.InOutQuad
                            }
                            onRunningChanged: {
                                if (!running)
                                    iconRotation.angle = 0;
                            }
                        }
                    }
                }

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: labelText.implicitWidth
                    implicitHeight: labelText.implicitHeight
                    StyledText {
                        id: labelText
                        anchors.centerIn: parent
                        text: label
                        color: applyLightModeFix ? "black" : (ma.containsMouse ? "white" : (isPrimary ? Qt.rgba(1, 0.8, 0.8, 1) : Qt.rgba(1, 1, 1, 0.7)))
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Medium
                        Behavior on color {
                            ColorAnimation {
                                duration: 150 * root.speedMultiplier
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 22
                    height: 22
                    radius: Theme.cornerRadiusSmall || (Theme.cornerRadius / 2)
                    color: (ma.containsMouse || applyLightModeFix) ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) : (isPrimary ? Qt.rgba(1, 0.8, 0.8, 0.1) : Qt.rgba(1, 1, 1, 0.05))
                    border.color: (ma.containsMouse || applyLightModeFix) ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.5) : (isPrimary ? Qt.rgba(1, 0.8, 0.8, 0.3) : Qt.rgba(1, 1, 1, 0.15))
                    border.width: 1
                    Behavior on color {
                        ColorAnimation {
                            duration: 150 * root.speedMultiplier
                        }
                    }
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150 * root.speedMultiplier
                        }
                    }
                    StyledText {
                        anchors.centerIn: parent
                        text: shortcutKey
                        color: applyLightModeFix ? "black" : (ma.containsMouse ? accentColor : (isPrimary ? Qt.rgba(1, 0.8, 0.8, 0.9) : Qt.rgba(1, 1, 1, 0.4)))
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Bold
                        Behavior on color {
                            ColorAnimation {
                                duration: 150 * root.speedMultiplier
                            }
                        }
                    }
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
        console.info("fullscreenPowerMenu: daemon loaded — use 'dms ipc call fullscreenPowerMenu toggle' to open");
    }
}

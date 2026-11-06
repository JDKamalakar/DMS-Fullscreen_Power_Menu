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
    PluginGlobalVar { varName: "holdToTriggerEnabled"; onValueChanged: { root.holdToTriggerEnabled = value === true } }
    PluginGlobalVar { varName: "holdDuration"; onValueChanged: { root.holdDurationMs = (value != null ? value : 500) } }
    PluginGlobalVar { varName: "showLock"; onValueChanged: { root.showLock = value !== false } }
    PluginGlobalVar { varName: "showSleep"; onValueChanged: { root.showSleep = value !== false } }
    PluginGlobalVar { varName: "showDms"; onValueChanged: { root.showDms = value !== false } }
    PluginGlobalVar { varName: "showRestart"; onValueChanged: { root.showRestart = value !== false } }
    PluginGlobalVar { varName: "showLogout"; onValueChanged: { root.showLogout = value !== false } }
    PluginGlobalVar { varName: "showPower"; onValueChanged: { root.showPower = value !== false } }
    PluginGlobalVar { varName: "showHibernate"; onValueChanged: { root.showHibernate = value === true } }
    PluginGlobalVar { varName: "showSoftReboot"; onValueChanged: { root.showSoftReboot = value === true } }
    PluginGlobalVar { varName: "showSwitchUser"; onValueChanged: { root.showSwitchUser = value === true } }
    PluginGlobalVar { varName: "showFirmware"; onValueChanged: { root.showFirmware = value === true } }

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
                else if (varName === "holdToTriggerEnabled") root.holdToTriggerEnabled = effectiveValue === true;
                else if (varName === "holdDuration") root.holdDurationMs = (effectiveValue != null ? effectiveValue : 500);
                else if (varName === "showLock") root.showLock = effectiveValue !== false;
                else if (varName === "showSleep") root.showSleep = effectiveValue !== false;
                else if (varName === "showDms") root.showDms = effectiveValue !== false;
                else if (varName === "showRestart") root.showRestart = effectiveValue !== false;
                else if (varName === "showLogout") root.showLogout = effectiveValue !== false;
                else if (varName === "showPower") root.showPower = effectiveValue !== false;
                else if (varName === "showHibernate") root.showHibernate = effectiveValue === true;
                else if (varName === "showSoftReboot") root.showSoftReboot = effectiveValue !== false && (effectiveValue === true || effectiveValue === "true");
                else if (varName === "showSwitchUser") root.showSwitchUser = effectiveValue === true;
                else if (varName === "showFirmware") root.showFirmware = effectiveValue === true;
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
    property bool holdToTriggerEnabled: pluginData ? pluginData.holdToTriggerEnabled === true : false
    property int holdDurationMs: pluginData && pluginData.holdDuration != null ? pluginData.holdDuration : 500
    property bool showLock: pluginData ? pluginData.showLock !== false : true
    property bool showSleep: pluginData ? pluginData.showSleep !== false : true
    property bool showDms: pluginData ? pluginData.showDms !== false : true
    property bool showRestart: pluginData ? pluginData.showRestart !== false : true
    property bool showLogout: pluginData ? pluginData.showLogout !== false : true
    property bool showPower: pluginData ? pluginData.showPower !== false : true
    property bool showHibernate: pluginData ? pluginData.showHibernate === true : false
    property bool showSoftReboot: pluginData ? pluginData.showSoftReboot === true : false
    property bool showSwitchUser: pluginData ? pluginData.showSwitchUser === true : false
    property bool showFirmware: pluginData ? pluginData.showFirmware === true : false

    property string activeHoldButtonId: ""
    property real holdProgress: 0.0

    Timer {
        id: holdProgressTimer
        interval: 16
        repeat: true
        onTriggered: {
            if (!root.holdToTriggerEnabled || root.activeHoldButtonId === "" || root.holdDurationMs <= 0) {
                stop();
                return;
            }
            root.holdProgress = Math.min(1.0, root.holdProgress + (16 / Math.max(50, root.holdDurationMs)));
            if (root.holdProgress >= 1.0) {
                stop();
                root.completeHold();
            }
        }
    }

    function startHold(btnId) {
        if (!root.holdToTriggerEnabled || root.holdDurationMs <= 0) {
            triggerButton(btnId);
            return;
        }
        root.activeHoldButtonId = btnId;
        root.holdProgress = 0.0;
        holdProgressTimer.restart();
    }

    function cancelHold() {
        if (root.activeHoldButtonId === "") return;
        holdProgressTimer.stop();
        root.activeHoldButtonId = "";
        root.holdProgress = 0.0;
    }

    function completeHold() {
        var btnId = root.activeHoldButtonId;
        root.cancelHold();
        if (btnId !== "") {
            triggerButton(btnId);
        }
    }

    function triggerButton(btnId) {
        if (btnId === "lock" && root.showLock) lockBtn.activated();
        else if (btnId === "sleep" && root.showSleep) sleepBtn.activated();
        else if (btnId === "dms" && root.showDms) dmsBtn.activated();
        else if (btnId === "restart" && root.showRestart) restartBtn.activated();
        else if (btnId === "logout" && root.showLogout) logoutBtn.activated();
        else if (btnId === "power" && root.showPower) powerBtn.activated();
        else if (btnId === "hibernate" && root.showHibernate) hibernateBtn.activated();
        else if (btnId === "softreboot" && root.showSoftReboot) softRebootBtn.activated();
        else if (btnId === "switchuser" && root.showSwitchUser) switchUserBtn.activated();
        else if (btnId === "firmware" && root.showFirmware) firmwareBtn.activated();
    }

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
        if (pluginData.holdToTriggerEnabled !== undefined) root.holdToTriggerEnabled = pluginData.holdToTriggerEnabled === true;
        if (pluginData.holdDuration !== undefined) root.holdDurationMs = pluginData.holdDuration;
        if (pluginData.showLock !== undefined) root.showLock = pluginData.showLock !== false;
        if (pluginData.showSleep !== undefined) root.showSleep = pluginData.showSleep !== false;
        if (pluginData.showDms !== undefined) root.showDms = pluginData.showDms !== false;
        if (pluginData.showRestart !== undefined) root.showRestart = pluginData.showRestart !== false;
        if (pluginData.showLogout !== undefined) root.showLogout = pluginData.showLogout !== false;
        if (pluginData.showPower !== undefined) root.showPower = pluginData.showPower !== false;
        if (pluginData.showHibernate !== undefined) root.showHibernate = pluginData.showHibernate === true;
        if (pluginData.showSoftReboot !== undefined) root.showSoftReboot = pluginData.showSoftReboot === true;
        if (pluginData.showSwitchUser !== undefined) root.showSwitchUser = pluginData.showSwitchUser === true;
        if (pluginData.showFirmware !== undefined) root.showFirmware = pluginData.showFirmware === true;
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

        BackgroundEffect.blurRegion: visible ? menuBlurRegion : null

        Region {
            id: menuBlurRegion
            x: menuCard.x
            y: menuCard.y
            width: menuCard.width
            height: menuCard.height
            radius: Theme.cornerRadiusLarge
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

                    readonly property var visibleButtonList: {
                        var list = [];
                        if (root.showLock) list.push(lockBtn);
                        if (root.showSleep) list.push(sleepBtn);
                        if (root.showDms) list.push(dmsBtn);
                        if (root.showRestart) list.push(restartBtn);
                        if (root.showLogout) list.push(logoutBtn);
                        if (root.showHibernate) list.push(hibernateBtn);
                        if (root.showSoftReboot) list.push(softRebootBtn);
                        if (root.showSwitchUser) list.push(switchUserBtn);
                        if (root.showFirmware) list.push(firmwareBtn);
                        if (root.showPower) list.push(powerBtn);
                        return list;
                    }
                    readonly property int visibleCount: visibleButtonList.length

                    columns: isVerticalCalc ? 1 : Math.max(1, visibleCount)
                    rows: isVerticalCalc ? Math.max(1, visibleCount) : 1

                    PowerButton {
                        id: lockBtn
                        visible: root.showLock
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "lock"
                        label: "Lock"
                        iconCode: "lock"
                        shortcutKey: "L"
                        isFirst: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[0] === lockBtn
                        isLast: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[mainRow.visibleButtonList.length - 1] === lockBtn
                        accentColor: "#93C5FD"
                        bgColor: Qt.rgba(0.23, 0.51, 0.96, 0.2)
                        onActivated: runCmd(lockProc, "lockCommand", "loginctl lock-session")
                    }

                    PowerButton {
                        id: sleepBtn
                        visible: root.showSleep
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "sleep"
                        label: "Sleep"
                        iconCode: "bedtime"
                        shortcutKey: "S"
                        isFirst: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[0] === sleepBtn
                        isLast: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[mainRow.visibleButtonList.length - 1] === sleepBtn
                        accentColor: "#A5B4FC"
                        bgColor: Qt.rgba(0.39, 0.38, 0.96, 0.2)
                        onActivated: runCmd(suspendProc, "suspendCommand", "systemctl suspend")
                    }

                    PowerButton {
                        id: dmsBtn
                        visible: root.showDms
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "dms"
                        label: "Restart DMS"
                        iconImageSource: Qt.resolvedUrl("assets/duxlogo.svg")
                        shortcutKey: "D"
                        isFirst: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[0] === dmsBtn
                        isLast: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[mainRow.visibleButtonList.length - 1] === dmsBtn
                        accentColor: "#FDE047"
                        bgColor: Qt.rgba(0.99, 0.88, 0.28, 0.2)
                        onActivated: runCmd(dmsRestartProc, "dmsRestartCommand", "dms restart")
                    }

                    PowerButton {
                        id: restartBtn
                        visible: root.showRestart
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "restart"
                        label: "Restart"
                        iconCode: "restart_alt"
                        shortcutKey: "R"
                        isFirst: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[0] === restartBtn
                        isLast: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[mainRow.visibleButtonList.length - 1] === restartBtn
                        accentColor: "#86EFAC"
                        bgColor: Qt.rgba(0.13, 0.77, 0.36, 0.2)
                        onActivated: runCmd(rebootProc, "rebootCommand", "systemctl reboot")
                    }

                    PowerButton {
                        id: logoutBtn
                        visible: root.showLogout
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "logout"
                        label: "Log Out"
                        iconCode: "logout"
                        shortcutKey: "X"
                        isFirst: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[0] === logoutBtn
                        isLast: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[mainRow.visibleButtonList.length - 1] === logoutBtn
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
                        id: hibernateBtn
                        visible: root.showHibernate
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "hibernate"
                        label: "Hibernate"
                        iconCode: "ac_unit"
                        shortcutKey: "H"
                        isFirst: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[0] === hibernateBtn
                        isLast: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[mainRow.visibleButtonList.length - 1] === hibernateBtn
                        accentColor: "#67E8F9"
                        bgColor: Qt.rgba(0.06, 0.71, 0.83, 0.2)
                        onActivated: runCmd(hibernateProc, "hibernateCommand", "systemctl hibernate")
                    }

                    PowerButton {
                        id: softRebootBtn
                        visible: root.showSoftReboot
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "softreboot"
                        label: "Soft Reboot"
                        iconCode: "autorenew"
                        shortcutKey: "B"
                        isFirst: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[0] === softRebootBtn
                        isLast: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[mainRow.visibleButtonList.length - 1] === softRebootBtn
                        accentColor: "#C084FC"
                        bgColor: Qt.rgba(0.75, 0.52, 0.99, 0.2)
                        onActivated: runCmd(softRebootProc, "softRebootCommand", "systemctl soft-reboot")
                    }

                    PowerButton {
                        id: switchUserBtn
                        visible: root.showSwitchUser
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "switchuser"
                        label: "Switch User"
                        iconCode: "switch_account"
                        shortcutKey: "U"
                        isFirst: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[0] === switchUserBtn
                        isLast: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[mainRow.visibleButtonList.length - 1] === switchUserBtn
                        accentColor: "#F472B6"
                        bgColor: Qt.rgba(0.96, 0.45, 0.71, 0.2)
                        onActivated: runCmd(switchUserProc, "switchUserCommand", "dm-tool switch-to-greeter")
                    }

                    PowerButton {
                        id: firmwareBtn
                        visible: root.showFirmware
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "firmware"
                        label: "UEFI / BIOS"
                        iconCode: "settings_suggest"
                        shortcutKey: "F"
                        isFirst: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[0] === firmwareBtn
                        isLast: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[mainRow.visibleButtonList.length - 1] === firmwareBtn
                        accentColor: "#F59E0B"
                        bgColor: Qt.rgba(0.96, 0.62, 0.04, 0.2)
                        onActivated: runCmd(firmwareProc, "firmwareCommand", "systemctl reboot --firmware-setup")
                    }

                    PowerButton {
                        id: powerBtn
                        visible: root.showPower
                        isVerticalFlow: mainRow.isVerticalCalc
                        buttonId: "power"
                        label: "Power Off"
                        iconCode: "power_settings_new"
                        shortcutKey: "P"
                        isFirst: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[0] === powerBtn
                        isLast: mainRow.visibleButtonList.length > 0 && mainRow.visibleButtonList[mainRow.visibleButtonList.length - 1] === powerBtn
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
            Keys.onEscapePressed: {
                root.cancelHold();
                root.closeMenu();
            }
            Keys.onPressed: function (event) {
                if (event.isAutoRepeat) {
                    event.accepted = true;
                    return;
                }
                if (event.key === Qt.Key_L && root.showLock) {
                    root.startHold("lock");
                    event.accepted = true;
                } else if (event.key === Qt.Key_S && root.showSleep) {
                    root.startHold("sleep");
                    event.accepted = true;
                } else if (event.key === Qt.Key_D && root.showDms) {
                    root.startHold("dms");
                    event.accepted = true;
                } else if (event.key === Qt.Key_R && root.showRestart) {
                    root.startHold("restart");
                    event.accepted = true;
                } else if (event.key === Qt.Key_X && root.showLogout) {
                    root.startHold("logout");
                    event.accepted = true;
                } else if (event.key === Qt.Key_H && root.showHibernate) {
                    root.startHold("hibernate");
                    event.accepted = true;
                } else if (event.key === Qt.Key_B && root.showSoftReboot) {
                    root.startHold("softreboot");
                    event.accepted = true;
                } else if (event.key === Qt.Key_U && root.showSwitchUser) {
                    root.startHold("switchuser");
                    event.accepted = true;
                } else if (event.key === Qt.Key_F && root.showFirmware) {
                    root.startHold("firmware");
                    event.accepted = true;
                } else if (event.key === Qt.Key_P && root.showPower) {
                    root.startHold("power");
                    event.accepted = true;
                }
            }
            Keys.onReleased: function (event) {
                if (event.isAutoRepeat) {
                    event.accepted = true;
                    return;
                }
                if (event.key === Qt.Key_L && root.activeHoldButtonId === "lock") {
                    root.cancelHold();
                    event.accepted = true;
                } else if (event.key === Qt.Key_S && root.activeHoldButtonId === "sleep") {
                    root.cancelHold();
                    event.accepted = true;
                } else if (event.key === Qt.Key_D && root.activeHoldButtonId === "dms") {
                    root.cancelHold();
                    event.accepted = true;
                } else if (event.key === Qt.Key_R && root.activeHoldButtonId === "restart") {
                    root.cancelHold();
                    event.accepted = true;
                } else if (event.key === Qt.Key_X && root.activeHoldButtonId === "logout") {
                    root.cancelHold();
                    event.accepted = true;
                } else if (event.key === Qt.Key_H && root.activeHoldButtonId === "hibernate") {
                    root.cancelHold();
                    event.accepted = true;
                } else if (event.key === Qt.Key_B && root.activeHoldButtonId === "softreboot") {
                    root.cancelHold();
                    event.accepted = true;
                } else if (event.key === Qt.Key_U && root.activeHoldButtonId === "switchuser") {
                    root.cancelHold();
                    event.accepted = true;
                } else if (event.key === Qt.Key_F && root.activeHoldButtonId === "firmware") {
                    root.cancelHold();
                    event.accepted = true;
                } else if (event.key === Qt.Key_P && root.activeHoldButtonId === "power") {
                    root.cancelHold();
                    event.accepted = true;
                }
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
    Process {
        id: hibernateProc
    }
    Process {
        id: softRebootProc
    }
    Process {
        id: switchUserProc
    }
    Process {
        id: firmwareProc
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
        readonly property bool isHoldingThis: root.activeHoldButtonId === buttonId && root.holdProgress > 0

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

            property color paintColor: {
                if (isHoldingThis) {
                    return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.35);
                }
                if (isPrimary || applyLightModeFix) {
                    return ma.containsMouse ? Qt.rgba(bgColor.r, bgColor.g, bgColor.b, bgColor.a + 0.2) : bgColor;
                }
                return ma.containsMouse ? bgColor : Qt.rgba(1, 1, 1, 0.05);
            }

            property color paintBorder: {
                if (isHoldingThis) {
                    return accentColor;
                }
                if (isPrimary) {
                    return Qt.rgba(0.94, 0.26, 0.26, 0.3);
                }
                if (ma.containsMouse || applyLightModeFix) {
                    return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3);
                }
                return Qt.rgba(1, 1, 1, 0.1);
            }

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

                    Canvas {
                        id: holdArcCanvas
                        anchors.centerIn: parent
                        width: 68
                        height: 68
                        visible: isHoldingThis
                        property real progress: isHoldingThis ? root.holdProgress : 0.0
                        onProgressChanged: requestPaint()
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            if (progress <= 0) return;
                            var centerX = width / 2;
                            var centerY = height / 2;
                            var radius = width / 2 - 4;
                            var startAngle = -Math.PI / 2;
                            var endAngle = startAngle + (Math.PI * 2 * Math.min(1.0, progress));
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
                            ctx.strokeStyle = accentColor;
                            ctx.lineWidth = 3.5;
                            ctx.lineCap = "round";
                            ctx.stroke();
                        }
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
                onPressed: {
                    if (root.holdToTriggerEnabled) {
                        root.startHold(buttonId);
                    }
                }
                onReleased: {
                    if (root.holdToTriggerEnabled && root.activeHoldButtonId === buttonId) {
                        root.cancelHold();
                    }
                }
                onCanceled: {
                    if (root.holdToTriggerEnabled && root.activeHoldButtonId === buttonId) {
                        root.cancelHold();
                    }
                }
                onClicked: {
                    if (!root.holdToTriggerEnabled) {
                        parent.parent.activated();
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.info("fullscreenPowerMenu: daemon loaded — use 'dms ipc call fullscreenPowerMenu toggle' to open");
    }
}

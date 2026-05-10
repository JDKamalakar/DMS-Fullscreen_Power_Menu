import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool animationsEnabled: pluginData ? pluginData.animationsEnabled !== false : true
    property real speedMultiplier: !animationsEnabled ? 0 : (pluginData && pluginData.animationSpeed != null ? 100 / pluginData.animationSpeed : 1.0)
    property real dimOpacity: pluginData && pluginData.dimOpacity != null ? pluginData.dimOpacity / 100 : 0.60
    property real menuOpacity: pluginData && pluginData.menuOpacity != null ? pluginData.menuOpacity / 100 : 0.20

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
    // FULLSCREEN OVERLAY WINDOW
    // -------------------------------------------------------------------------

    PanelWindow {
        id: overlay
        visible: false
        color: "transparent"

        WlrLayershell.namespace: "dms:plugins:fullscreenPowerMenu"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: overlay.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: overlay.visible ? root.dimOpacity : 0
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

        Item {
            id: menuContainer
            anchors.centerIn: parent
            width: mainRow.implicitWidth + 48
            height: mainRow.implicitHeight + 48

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

            DropShadow {
                anchors.fill: menuCard
                source: menuCard
                verticalOffset: 16
                horizontalOffset: 0
                radius: 48
                samples: 97
                spread: 0.05
                color: Qt.rgba(0, 0, 0, overlay.visible ? 0.55 : 0.0)
                transparentBorder: true
                Behavior on color {
                    ColorAnimation {
                        duration: 300 * root.speedMultiplier
                    }
                }
            }

            Rectangle {
                id: menuCard
                anchors.fill: parent
                radius: 32
                color: Theme.surface ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, root.menuOpacity) : Qt.rgba(0.2, 0.2, 0.2, 0.2)
                border.color: Theme.surface ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.20) : Qt.rgba(1, 1, 1, 0.2)
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
                    columnSpacing: 12
                    rowSpacing: 12

                    property string visualOrientation: pluginData && pluginData.menuOrientation ? pluginData.menuOrientation : "dynamic"
                    property bool isVerticalCalc: visualOrientation === "vertical" || (visualOrientation === "dynamic" && overlay.height > overlay.width)

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
                        shortcutKey: "D"
                        iconImageSource: "https://raw.githubusercontent.com/AvengeMedia/DankMaterialShell/f2df53afcd0870445e7f3cd45e91ac135a04442e/assets/danklogo.svg"
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
                        onActivated: runCmd(logoutProc, "logoutCommand", "loginctl terminate-session $XDG_SESSION_ID")
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

        signal activated

        implicitWidth: 140
        implicitHeight: 140

        transform: [
            Scale {
                origin.x: width / 2
                origin.y: height / 2
                xScale: ma.pressed ? 0.92 : 1.0
                yScale: xScale
                Behavior on xScale {
                    NumberAnimation {
                        duration: 80 * root.speedMultiplier
                        easing.type: Easing.OutCubic
                    }
                }
            }
        ]

        Canvas {
            id: btnBg
            anchors.fill: parent

            property real defaultRadius: 16
            property real hoverRadius: 70

            property real tlr: ma.containsMouse ? hoverRadius : (isFirst ? 28 : defaultRadius)
            property real tlrAnim: tlr
            Behavior on tlrAnim {
                NumberAnimation {
                    duration: 100 * root.speedMultiplier
                    easing.type: Easing.OutCubic
                }
            }

            property real trr: ma.containsMouse ? hoverRadius : (isVerticalFlow ? (isFirst ? 28 : defaultRadius) : (isLast ? 28 : defaultRadius))
            property real trrAnim: trr
            Behavior on trrAnim {
                NumberAnimation {
                    duration: 100 * root.speedMultiplier
                    easing.type: Easing.OutCubic
                }
            }

            property real blr: ma.containsMouse ? hoverRadius : (isVerticalFlow ? (isLast ? 28 : defaultRadius) : (isFirst ? 28 : defaultRadius))
            property real blrAnim: blr
            Behavior on blrAnim {
                NumberAnimation {
                    duration: 100 * root.speedMultiplier
                    easing.type: Easing.OutCubic
                }
            }

            property real brr: ma.containsMouse ? hoverRadius : (isLast ? 28 : defaultRadius)
            property real brrAnim: brr
            Behavior on brrAnim {
                NumberAnimation {
                    duration: 100 * root.speedMultiplier
                    easing.type: Easing.OutCubic
                }
            }

            property color paintColor: isPrimary ? (ma.containsMouse ? Qt.rgba(bgColor.r, bgColor.g, bgColor.b, bgColor.a + 0.2) : bgColor) : (ma.containsMouse ? bgColor : Qt.rgba(1, 1, 1, 0.05))

            property color paintBorder: isPrimary ? Qt.rgba(0.94, 0.26, 0.26, 0.3) : (ma.containsMouse ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3) : Qt.rgba(1, 1, 1, 0.1))

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

            onTlrAnimChanged: requestPaint()
            onTrrAnimChanged: requestPaint()
            onBrrAnimChanged: requestPaint()
            onBlrAnimChanged: requestPaint()
            onPaintColorChanged: requestPaint()
            onPaintBorderChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.shadowColor = Qt.rgba(0, 0, 0, 0.4);
                ctx.shadowBlur = 12;
                ctx.shadowOffsetY = 6;
                ctx.fillStyle = paintColor;
                ctx.strokeStyle = paintBorder;
                ctx.lineWidth = 1;
                ctx.beginPath();
                ctx.moveTo(tlrAnim, 0);
                ctx.lineTo(width - trrAnim, 0);
                ctx.arcTo(width, 0, width, trrAnim, trrAnim);
                ctx.lineTo(width, height - brrAnim);
                ctx.arcTo(width, height, width - brrAnim, height, brrAnim);
                ctx.lineTo(blrAnim, height);
                ctx.arcTo(0, height, 0, height - blrAnim, blrAnim);
                ctx.lineTo(0, tlrAnim);
                ctx.arcTo(0, 0, tlrAnim, 0, tlrAnim);
                ctx.closePath();
                ctx.fill();
                ctx.shadowColor = "transparent";
                ctx.stroke();
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                Item {
                    width: 64
                    height: 64
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.centerIn: parent
                        width: 56
                        height: 56
                        radius: ma.containsMouse ? width * 0.35 : width * 0.5
                        color: isPrimary ? Qt.rgba(0.94, 0.26, 0.26, 0.3) : Qt.rgba(1, 1, 1, 0.1)
                        RotationAnimation on rotation {
                            loops: Animation.Infinite
                            from: 0
                            to: 360
                            duration: 2000 * root.speedMultiplier
                            running: ma.containsMouse
                        }
                        Behavior on radius {
                            NumberAnimation {
                                duration: 200 * root.speedMultiplier
                                easing.type: Easing.OutCubic
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
                                        duration: 200 * root.speedMultiplier
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        ]

                        Text {
                            visible: iconCode !== ""
                            anchors.centerIn: parent
                            text: iconCode
                            font.family: "Material Symbols Rounded"
                            font.pixelSize: 36
                            color: ma.containsMouse ? accentColor : (isPrimary ? Qt.rgba(1, 0.7, 0.7, 1) : Qt.rgba(1, 1, 1, 0.9))
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
                        ColorOverlay {
                            visible: iconImageSource !== ""
                            anchors.fill: urlIconSrc
                            source: urlIconSrc
                            color: ma.containsMouse ? accentColor : (isPrimary ? Qt.rgba(1, 0.7, 0.7, 1) : Qt.rgba(1, 1, 1, 0.9))
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150 * root.speedMultiplier
                                }
                            }
                        }

                        SequentialAnimation {
                            running: ma.containsMouse
                            loops: Animation.Infinite
                            PauseAnimation {
                                duration: 1500 * root.speedMultiplier
                            }
                            NumberAnimation {
                                target: iconRotation
                                property: "angle"
                                to: -15
                                duration: 80 * root.speedMultiplier
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: iconRotation
                                property: "angle"
                                to: 15
                                duration: 80 * root.speedMultiplier
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: iconRotation
                                property: "angle"
                                to: -10
                                duration: 80 * root.speedMultiplier
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: iconRotation
                                property: "angle"
                                to: 10
                                duration: 80 * root.speedMultiplier
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: iconRotation
                                property: "angle"
                                to: 0
                                duration: 80 * root.speedMultiplier
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
                        color: ma.containsMouse ? "white" : (isPrimary ? Qt.rgba(1, 0.8, 0.8, 1) : Qt.rgba(1, 1, 1, 0.7))
                        font.pixelSize: 14
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
                    Layout.topMargin: -2
                    width: 24
                    height: 24
                    radius: 8
                    color: ma.containsMouse ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) : (isPrimary ? Qt.rgba(1, 0.8, 0.8, 0.1) : Qt.rgba(1, 1, 1, 0.05))
                    border.color: ma.containsMouse ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.5) : (isPrimary ? Qt.rgba(1, 0.8, 0.8, 0.3) : Qt.rgba(1, 1, 1, 0.15))
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
                        color: ma.containsMouse ? accentColor : (isPrimary ? Qt.rgba(1, 0.8, 0.8, 0.9) : Qt.rgba(1, 1, 1, 0.4))
                        font.pixelSize: 11
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

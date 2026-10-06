import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: btPanel
    visible: true
    anchors { top: true; right: true }
    margins { top: 46; right: root.btVisible ? 8 : -350 }
    implicitHeight: 460
    implicitWidth: 320
    color: "transparent"
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.btVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    Item {
        anchors.fill: parent
        focus: root.btVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.btVisible = false
                event.accepted = true
            }
        }

        Rectangle {
            anchors.fill: parent
            // Стекло рисует Hyprland (layerrules.lua размывает слой quickshell),
            // здесь только полупрозрачная заливка и кромка.
            color: root.glassBg
            radius: 22
            border.width: 1
            border.color: root.hairline

                // Liquid glass: блик верхней кромки. Панель не может размыть
                // то, что за ней — это делает Hyprland (layer_rule на
                // namespace quickshell). Здесь только то, что рисует сам
                // клиент: полупрозрачная заливка, кромка и вот этот блик,
                // который читается как источник света сверху.
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    gradient: Gradient {
                        GradientStop { position: 0.0;  color: Qt.rgba(1, 1, 1, 0.10) }
                        GradientStop { position: 0.30; color: Qt.rgba(1, 1, 1, 0.02) }
                        GradientStop { position: 1.0;  color: Qt.rgba(1, 1, 1, 0.0) }
                    }
                }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "󰂯"
                        color: root.labelSecondary
                        font.pixelSize: 22
                        font.family: root.glyphFont
                    }
                    Text {
                        text: "Bluetooth"
                        color: root.label
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        font.family: root.uiFont
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 44
                        height: 24
                        radius: 12
                        color: root.btEnabled ? root.accent : Qt.rgba(0.3, 0.3, 0.3, 0.5)
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            y: 2
                            x: root.btEnabled ? 22 : 2
                            color: root.glassTint
                            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.btEnabled)
                                    btToggleOffProc.running = true
                                else
                                    btToggleOnProc.running = true
                            }
                        }
                    }
                }

                Text {
                    text: "Paired Devices"
                    color: root.labelSecondary
                    font.pixelSize: 12
                    font.family: root.uiFont
                    visible: root.btEnabled
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    color: root.glassRaised
                    border.width: 1
                    border.color: root.islandLine
                    radius: 12
                    clip: true
                    visible: root.btEnabled
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4
                        boundsBehavior: Flickable.StopAtBounds
                        model: root.btPairedDevices
                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 48
                            radius: 10
                            color: {
                                if (modelData.connected)
                                    return Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.30)
                                if (btPairedMa.containsMouse)
                                    return Qt.rgba(1, 1, 1, 0.08)
                                return "transparent"
                            }
                            Behavior on color { ColorAnimation { duration: 120 } }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 10
                                spacing: 10
                                Text {
                                    text: modelData.connected ? "󰂱" : "󰂲"
                                    color: root.labelSecondary
                                    font.pixelSize: 18
                                    font.family: root.uiFont
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        text: modelData.name
                                        color: root.label
                                        font.pixelSize: 13
                                        font.bold: modelData.connected
                                        font.family: root.uiFont
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: {
                                            if (root.btConnectingMAC === modelData.mac) return "Connecting..."
                                            if (modelData.connected) return "Connected"
                                            return "Paired"
                                        }
                                        color: root.labelSecondary
                                        font.pixelSize: 10
                                        font.family: root.uiFont
                                    }
                                }
                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 8
                                    color: btConnBtnMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.connected ? "󰅖" : "󰐕"
                                        color: modelData.connected ? root.sysRed : root.accent
                                        font.pixelSize: 13
                                        font.family: root.uiFont
                                    }
                                    MouseArea {
                                        id: btConnBtnMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.connected)
                                                root.disconnectBt(modelData.mac)
                                            else
                                                root.connectBt(modelData.mac)
                                        }
                                    }
                                }
                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 8
                                    color: btForgetMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰆴"
                                        color: root.labelSecondary
                                        font.pixelSize: 12
                                        font.family: root.glyphFont
                                    }
                                    MouseArea {
                                        id: btForgetMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.forgetBt(modelData.mac)
                                    }
                                }
                            }
                            MouseArea {
                                id: btPairedMa
                                anchors.fill: parent
                                hoverEnabled: true
                                z: -1
                                onClicked: {
                                    if (modelData.connected)
                                        root.disconnectBt(modelData.mac)
                                    else
                                        root.connectBt(modelData.mac)
                                }
                            }
                        }
                        ScrollBar.vertical: ScrollBar { active: true; width: 4 }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: root.btPairedDevices.length === 0
                        text: "No paired devices"
                        color: root.labelSecondary
                        font.pixelSize: 13
                        font.family: root.uiFont
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.btEnabled
                    Text {
                        text: "Available Devices"
                        color: root.labelSecondary
                        font.pixelSize: 12
                        font.family: root.uiFont
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 60
                        height: 24
                        radius: 6
                        color: btScanBtnMa.containsMouse ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.26) : Qt.rgba(0, 0, 0, 0.3)
                        Text {
                            anchors.centerIn: parent
                            text: root.btScanning ? "Scanning" : "Scan"
                            color: root.accent
                            font.pixelSize: 11
                            font.family: root.uiFont
                        }
                        MouseArea {
                            id: btScanBtnMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!root.btScanning) {
                                    root.btScanning = true
                                    root.btAvailableDevices = []
                                    btScanProc.running = true
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: root.glassRaised
                    border.width: 1
                    border.color: root.islandLine
                    radius: 12
                    clip: true
                    visible: root.btEnabled
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4
                        boundsBehavior: Flickable.StopAtBounds
                        model: root.btAvailableDevices
                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 44
                            radius: 10
                            color: btAvailMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10
                                Text {
                                    text: "󰂲"
                                    color: root.labelSecondary
                                    font.pixelSize: 16
                                    font.family: root.glyphFont
                                }
                                Text {
                                    text: modelData.name
                                    color: root.label
                                    font.pixelSize: 12
                                    font.family: root.glyphFont
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    visible: root.btConnectingMAC === modelData.mac
                                    text: "..."
                                    color: root.labelSecondary
                                    font.pixelSize: 13
                                    font.family: root.uiFont
                                }
                            }
                            MouseArea {
                                id: btAvailMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.pairBt(modelData.mac)
                            }
                        }
                        ScrollBar.vertical: ScrollBar { active: true; width: 4 }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: root.btAvailableDevices.length === 0 && !root.btScanning
                        text: "Press Scan to find devices"
                        color: root.labelSecondary
                        font.pixelSize: 12
                        font.family: root.uiFont
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: root.btScanning
                        text: "Scanning..."
                        color: root.labelSecondary
                        font.pixelSize: 12
                        font.family: root.uiFont
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !root.btEnabled
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "Bluetooth is off"
                        color: root.labelSecondary
                        font.pixelSize: 13
                        font.family: root.uiFont
                    }
                }
            }
        }
    }

    Connections {
        target: root
        function onBtVisibleChanged() {
            if (root.btVisible) {
                focusTimer.start()
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            btPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            btPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }
}

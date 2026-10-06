import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: wifiPanel
    visible: true
    anchors { top: true; right: true }
    margins { top: 46; right: root.wifiVisible ? 8 : -350 }
    implicitHeight: 420
    implicitWidth: 320
    color: "transparent"
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.wifiVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    Item {
        anchors.fill: parent
        focus: root.wifiVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (root.wifiPasswordSSID !== "") {
                    root.wifiPasswordSSID = ""
                    wifiPassInput.text = ""
                } else {
                    root.wifiVisible = false
                }
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
                        text: "󰤨"
                        color: root.labelSecondary
                        font.pixelSize: 22
                        font.family: root.glyphFont
                    }
                    Text {
                        text: "Wi-Fi"
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
                        color: root.wifiEnabled ? root.accent : Qt.rgba(0.3, 0.3, 0.3, 0.5)
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            y: 2
                            x: root.wifiEnabled ? 22 : 2
                            color: root.glassTint
                            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wifiToggleProc.running = true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 10
                    color: root.glassRaised
                    border.width: 1
                    border.color: root.islandLine
                    visible: root.wifiPasswordSSID !== ""
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        Text {
                            text: "󰌾"
                            color: root.labelSecondary
                            font.pixelSize: 12
                            font.family: root.glyphFont
                        }
                        TextInput {
                            id: wifiPassInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: root.label
                            font.pixelSize: 13
                            font.family: root.uiFont
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            clip: true
                            Text {
                                text: "Password for " + root.wifiPasswordSSID
                                color: root.labelSecondary
                                visible: !parent.text
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                font: parent.font
                            }
                            Keys.onReturnPressed: {
                                if (wifiPassInput.text.length > 0) {
                                    root.wifiConnecting = true
                                    wifiConnectProc.ssid = root.wifiPasswordSSID
                                    wifiConnectProc.password = wifiPassInput.text
                                    wifiConnectProc.running = true
                                    wifiPassInput.text = ""
                                }
                            }
                            Keys.onEscapePressed: {
                                root.wifiPasswordSSID = ""
                                wifiPassInput.text = ""
                            }
                        }
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 6
                            color: root.accent
                            Text {
                                anchors.centerIn: parent
                                text: "→"
                                color: root.glassTint
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                font.family: root.uiFont
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (wifiPassInput.text.length > 0) {
                                        root.wifiConnecting = true
                                        wifiConnectProc.ssid = root.wifiPasswordSSID
                                        wifiConnectProc.password = wifiPassInput.text
                                        wifiConnectProc.running = true
                                        wifiPassInput.text = ""
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.wifiEnabled
                    Text {
                        text: "Available Networks"
                        color: root.labelSecondary
                        font.pixelSize: 12
                        font.family: root.uiFont
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 6
                        color: wifiRefreshMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: root.wifiScanning ? "󰑓" : "󰑐"
                            color: root.labelSecondary
                            font.pixelSize: 13
                            font.family: root.uiFont
                        }
                        MouseArea {
                            id: wifiRefreshMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!root.wifiScanning) root.refreshWifi()
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
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4
                        boundsBehavior: Flickable.StopAtBounds
                        model: root.wifiNetworks
                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: modelData.ssid === root.wifiCurrentSSID ? 48 : 44
                            radius: 10
                            color: {
                                if (modelData.ssid === root.wifiCurrentSSID)
                                    return Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.30)
                                if (wifiNetMa.containsMouse)
                                    return Qt.rgba(1, 1, 1, 0.08)
                                return "transparent"
                            }
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 10
                                spacing: 10
                                Text {
                                    text: modelData.ssid === root.wifiCurrentSSID ? "󰤨" : (modelData.signal > 66 ? "󰤨" : modelData.signal > 33 ? "󰤥" : "󰤟")
                                    color: root.labelSecondary
                                    font.pixelSize: 18
                                    font.family: root.uiFont
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        text: modelData.ssid
                                        color: root.label
                                        font.pixelSize: 13
                                        font.bold: modelData.ssid === root.wifiCurrentSSID
                                        font.family: root.uiFont
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: {
                                            if (root.wifiConnecting && root.wifiPasswordSSID === modelData.ssid)
                                                return "Connecting..."
                                            if (modelData.ssid === root.wifiCurrentSSID)
                                                return "Connected"
                                            return (modelData.security !== "" && modelData.security !== "--" ? "󰌾 " + modelData.security : "Open") + " · " + modelData.signal + "%"
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
                                    visible: modelData.ssid === root.wifiCurrentSSID
                                    color: wifiConnBtnMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰅖"
                                        color: root.sysRed
                                        font.pixelSize: 12
                                        font.family: root.glyphFont
                                    }
                                    MouseArea {
                                        id: wifiConnBtnMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: wifiDisconnectProc.running = true
                                    }
                                }
                            }
                            MouseArea {
                                id: wifiNetMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                z: -1
                                onClicked: {
                                    if (modelData.ssid === root.wifiCurrentSSID) return
                                    if (modelData.security !== "" && modelData.security !== "--") {
                                        root.wifiPasswordSSID = modelData.ssid
                                        wifiPassInput.forceActiveFocus()
                                    } else {
                                        root.wifiConnecting = true
                                        wifiConnectProc.ssid = modelData.ssid
                                        wifiConnectProc.password = ""
                                        wifiConnectProc.running = true
                                    }
                                }
                            }
                        }
                        ScrollBar.vertical: ScrollBar { active: true; width: 4 }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: root.wifiNetworks.length === 0 && !root.wifiScanning
                        text: root.wifiEnabled ? "No networks found" : "Wi-Fi is off"
                        color: root.labelSecondary
                        font.pixelSize: 13
                        font.family: root.uiFont
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: root.wifiScanning
                        text: "Scanning..."
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
        function onWifiVisibleChanged() {
            if (root.wifiVisible) {
                focusTimer.start()
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            wifiPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            wifiPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }
}

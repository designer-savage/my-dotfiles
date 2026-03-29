import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: wifiPanel
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: 40; right: root.wifiVisible ? 6 : -350 }
    implicitHeight: 420
    implicitWidth: 320
    color: "transparent"
    focusable: true
    WlrLayershell.keyboardFocus: root.wifiVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.7)
            radius: 20

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "󰤨"
                        color: root.walColor5
                        font.pixelSize: 22
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: "Wi-Fi"
                        color: root.walColor5
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 44
                        height: 24
                        radius: 12
                        color: root.wifiEnabled ? root.walColor5 : Qt.rgba(0.3, 0.3, 0.3, 0.5)
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            y: 2
                            x: root.wifiEnabled ? 22 : 2
                            color: root.walBackground
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
                    color: Qt.rgba(0, 0, 0, 0.3)
                    visible: root.wifiPasswordSSID !== ""
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        Text {
                            text: "󰌾"
                            color: root.walColor8
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        TextInput {
                            id: wifiPassInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: root.walForeground
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            clip: true
                            Text {
                                text: "Password for " + root.wifiPasswordSSID
                                color: root.walColor8
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
                            color: root.walColor5
                            Text {
                                anchors.centerIn: parent
                                text: "→"
                                color: root.walBackground
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
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
                        color: root.walColor8
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
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
                            color: root.walColor8
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
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
                    color: Qt.rgba(0, 0, 0, 0.3)
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
                                    return Qt.rgba(root.walColor2.r, root.walColor2.g, root.walColor2.b, 0.12)
                                if (wifiNetMa.containsMouse)
                                    return Qt.rgba(1, 1, 1, 0.08)
                                return "transparent"
                            }
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                            Rectangle {
                                visible: modelData.ssid === root.wifiCurrentSSID
                                width: 3
                                height: 24
                                radius: 2
                                color: root.walColor2
                                anchors.left: parent.left
                                anchors.leftMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 10
                                spacing: 10
                                Text {
                                    text: modelData.ssid === root.wifiCurrentSSID ? "󰤨" : (modelData.signal > 66 ? "󰤨" : modelData.signal > 33 ? "󰤥" : "󰤟")
                                    color: modelData.ssid === root.wifiCurrentSSID ? root.walColor2 : root.walColor8
                                    font.pixelSize: 18
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        text: modelData.ssid
                                        color: modelData.ssid === root.wifiCurrentSSID ? root.walColor2 : root.walForeground
                                        font.pixelSize: 12
                                        font.bold: modelData.ssid === root.wifiCurrentSSID
                                        font.family: "JetBrainsMono Nerd Font"
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
                                        color: root.walColor8
                                        font.pixelSize: 9
                                        font.family: "JetBrainsMono Nerd Font"
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
                                        color: root.walColor1
                                        font.pixelSize: 12
                                        font.family: "JetBrainsMono Nerd Font"
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
                        color: root.walColor8
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: root.wifiScanning
                        text: "Scanning..."
                        color: root.walColor8
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
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
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: powerPanel
    visible: true
    anchors { top: true; right: true }
    margins { top: 46; right: root.powerVisible ? 8 : -350 }
    // Четыре действия по 58px + заголовок и отступы.
    implicitHeight: 318
    implicitWidth: 340
    color: "transparent"
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.powerVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    // Порядок по возрастанию необратимости: блокировка ничего не теряет,
    // сон сохраняет сессию, перезагрузка и выключение закрывают всё. Первые
    // два идут акцентом, последние два — системным красным, чтобы разница
    // читалась до клика, а не после.
    property var actions: [
        { icon: "󰌾", title: "Заблокировать", subtitle: "Экран блокировки",               tint: root.accent,    act: "lock" },
        { icon: "󰤄", title: "Сон",           subtitle: "Приложения остаются открытыми",  tint: root.accentAlt, act: "suspend" },
        { icon: "󰜉", title: "Перезагрузить", subtitle: "Закрыть всё и загрузиться снова", tint: root.sysRed,    act: "reboot" },
        { icon: "󰐥", title: "Выключить",     subtitle: "Завершить работу",                tint: root.sysRed,    act: "poweroff" }
    ]
    property int selected: -1

    Item {
        anchors.fill: parent
        focus: root.powerVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.powerVisible = false
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                powerPanel.selected = (powerPanel.selected + 1) % powerPanel.actions.length
                event.accepted = true
            } else if (event.key === Qt.Key_Up) {
                powerPanel.selected = (powerPanel.selected + powerPanel.actions.length - 1) % powerPanel.actions.length
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (powerPanel.selected >= 0)
                    root.runPowerAction(powerPanel.actions[powerPanel.selected].act)
                event.accepted = true
            }
        }

        Rectangle {
            anchors.fill: parent
            // Стекло рисует не панель, а Hyprland: layerrules.lua размывает
            // слой quickshell, здесь только полупрозрачная заливка.
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
                    spacing: 9
                    Text {
                        text: "󰐥"
                        color: root.labelSecondary
                        font.pixelSize: 19
                        font.family: root.glyphFont
                    }
                    Text {
                        text: "Питание"
                        color: root.label
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        font.family: root.uiFont
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 6
                        color: powerCloseMa.containsMouse ? root.hoverBg : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: powerCloseMa.containsMouse ? root.label : root.labelTertiary
                            font.pixelSize: 12
                            font.family: root.glyphFont
                        }
                        MouseArea {
                            id: powerCloseMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.powerVisible = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: root.glassRaised
                    radius: 14
                    border.width: 1
                    border.color: root.islandLine
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4

                        Repeater {
                            model: powerPanel.actions
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 11
                                // Та же трактовка выделенной строки, что у
                                // лаунчера: заливка акцентом, без полоски сбоку.
                                color: {
                                    if (powerActionMa.containsMouse || powerPanel.selected === index)
                                        return Qt.rgba(modelData.tint.r, modelData.tint.g, modelData.tint.b, 0.32)
                                    return "transparent"
                                }
                                Behavior on color { ColorAnimation { duration: 140 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 12
                                    spacing: 13
                                    Text {
                                        text: modelData.icon
                                        color: (powerActionMa.containsMouse || powerPanel.selected === index)
                                               ? root.label : modelData.tint
                                        font.pixelSize: 19
                                        font.family: root.glyphFont
                                        Behavior on color { ColorAnimation { duration: 140 } }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: modelData.title
                                            color: root.label
                                            font.pixelSize: 13
                                            font.weight: Font.Medium
                                            font.family: root.uiFont
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: modelData.subtitle
                                            color: root.labelSecondary
                                            font.pixelSize: 11
                                            font.family: root.uiFont
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }
                                }

                                MouseArea {
                                    id: powerActionMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: powerPanel.selected = index
                                    onExited: if (powerPanel.selected === index) powerPanel.selected = -1
                                    onClicked: root.runPowerAction(modelData.act)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: root
        function onPowerVisibleChanged() {
            if (root.powerVisible) {
                powerPanel.selected = -1
                focusTimer.start()
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            powerPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            powerPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }
}

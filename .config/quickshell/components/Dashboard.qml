import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

PanelWindow {
    id: dashboard
    visible: true
    anchors { top: true; bottom: true; right: true }
    margins { top: 40; bottom: 10; right: root.dashboardVisible ? 6 : -450 }
    implicitWidth: 420
    color: "transparent"
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.dashboardVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    property int cpuVal: 0
    property int ramVal: 0
    property int diskVal: 0
    property int batVal: 100
    property int volVal: 50
    property int brightVal: 100
    property string configPath: Quickshell.env("HOME") + "/.config/quickshell"

    Item {
        anchors.fill: parent
        focus: root.dashboardVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (profileSection.pfpPickerOpen) {
                    profileSection.pfpPickerOpen = false
                } else {
                    root.dashboardVisible = false
                }
                event.accepted = true
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.7)
            radius: 20

            MouseArea {
                anchors.fill: parent
                visible: profileSection.pfpPickerOpen
                onClicked: profileSection.pfpPickerOpen = false
                z: 50
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                z: 100

                Rectangle {
                    id: profileSection
                    Layout.fillWidth: true
                    Layout.preferredHeight: pfpPickerOpen ? 280 : 100
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    clip: true
                    property bool pfpPickerOpen: false
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15
                            Item {
                                id: pfpContainer
                                width: 74
                                height: 74
                                Rectangle {
                                    id: pfpBorder
                                    anchors.fill: parent
                                    radius: 37
                                    color: "transparent"
                                    border.width: 3
                                    border.color: root.walColor5
                                }
                                Rectangle {
                                    id: pfpMask
                                    anchors.centerIn: parent
                                    width: 68
                                    height: 68
                                    radius: 34
                                    opacity: 0
                                    layer.enabled: true
                                }
                                Item {
                                    anchors.centerIn: parent
                                    width: 68
                                    height: 68
                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        maskEnabled: true
                                        maskSource: pfpMask
                                    }
                                    Image {
                                        id: pfpImage
                                        anchors.fill: parent
                                        source: "file://" + dashboard.configPath + "/assets/pfps/pfp.jpg"
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        cache: false
                                        sourceSize.width: 256
                                        sourceSize.height: 256
                                        property int reloadTrigger: 0
                                        function reload() {
                                            reloadTrigger++
                                            source = ""
                                            source = "file://" + dashboard.configPath + "/assets/pfps/pfp.jpg?" + reloadTrigger
                                        }
                                    }
                                }
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: root.walColor5
                                    border.width: 2
                                    border.color: root.walBackground
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰏫"
                                        color: root.walBackground
                                        font.pixelSize: 12
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        profileSection.pfpPickerOpen = !profileSection.pfpPickerOpen
                                        if (profileSection.pfpPickerOpen) {
                                            root.pfpFiles = []
                                            pfpListProc.running = true
                                        }
                                    }
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                Text {
                                    text: Quickshell.env("USER")
                                    color: root.walColor5
                                    font.pixelSize: 26
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                                Text {
                                    id: uptimeText
                                    text: "up ..."
                                    color: root.walForeground
                                    font.pixelSize: 12
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Qt.rgba(0, 0, 0, 0.3)
                            radius: 10
                            visible: profileSection.pfpPickerOpen
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8
                                Text {
                                    text: "Choose Avatar"
                                    color: root.walColor5
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Flickable {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    contentWidth: width
                                    contentHeight: pfpGrid.height
                                    clip: true
                                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                    GridLayout {
                                        id: pfpGrid
                                        width: parent.width
                                        columns: 6
                                        rowSpacing: 8
                                        columnSpacing: 8
                                        Repeater {
                                            model: root.pfpFiles
                                            Item {
                                                width: 48
                                                height: 48
                                                Layout.alignment: Qt.AlignHCenter
                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 24
                                                    color: "transparent"
                                                    border.width: 2
                                                    border.color: thumbMa.containsMouse ? root.walColor13 : root.walColor5
                                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                                }
                                                Rectangle {
                                                    id: thumbMask
                                                    anchors.centerIn: parent
                                                    width: 44
                                                    height: 44
                                                    radius: 22
                                                    opacity: 0
                                                    layer.enabled: true
                                                }
                                                Item {
                                                    anchors.centerIn: parent
                                                    width: 44
                                                    height: 44
                                                    layer.enabled: true
                                                    layer.effect: MultiEffect {
                                                        maskEnabled: true
                                                        maskSource: thumbMask
                                                    }
                                                    Image {
                                                        id: thumbImg
                                                        anchors.fill: parent
                                                        source: "file://" + modelData
                                                        fillMode: Image.PreserveAspectCrop
                                                        smooth: true
                                                        sourceSize.width: 128
                                                        sourceSize.height: 128
                                                    }
                                                }
                                                MouseArea {
                                                    id: thumbMa
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        setPfpProc.selFile = modelData
                                                        setPfpProc.running = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Process {
                        id: pfpListProc
                        command: ["bash", "-c", "find " + dashboard.configPath + "/assets/pfps -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.gif' \\) ! -name 'pfp.jpg' | sort"]
                        stdout: SplitParser {
                            onRead: data => {
                                var file = data.trim()
                                if (file.length > 0) {
                                    var current = root.pfpFiles.slice()
                                    current.push(file)
                                    root.pfpFiles = current
                                }
                            }
                        }
                    }
                    Process {
                        id: setPfpProc
                        property string selFile: ""
                        command: ["bash", "-c", "cp '" + selFile + "' " + dashboard.configPath + "/assets/pfps/pfp.jpg"]
                        onExited: {
                            pfpImage.reload()
                            profileSection.pfpPickerOpen = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    Row {
                        anchors.centerIn: parent
                        spacing: 25
                        PowerBtn { icon: "⏻"; iconColor: root.walColor2; cmd: "systemctl poweroff" }
                        PowerBtn { icon: "󰜉"; iconColor: root.walColor13; cmd: "systemctl reboot" }
                        PowerBtn { icon: "󰌾"; iconColor: root.walColor5; cmd: "hyprlock" }
                        PowerBtn { icon: "󰒲"; iconColor: root.walColor4; cmd: "systemctl suspend" }
                        PowerBtn { icon: "󰍃"; iconColor: root.walColor1; cmd: "hyprctl dispatch exit" }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        Text {
                            id: batIcon
                            text: "󰁹"
                            color: root.walColor2
                            font.pixelSize: 32
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3
                            Text {
                                text: "Battery " + dashboard.batVal + "%"
                                color: root.walForeground
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                id: batStatus
                                text: "Checking..."
                                color: root.walColor8
                                font.pixelSize: 12
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    Row {
                        anchors.centerIn: parent
                        spacing: 30
                        CircularStat { label: "CPU"; icon: ""; barColor: root.walColor1; value: dashboard.cpuVal }
                        CircularStat { label: "RAM"; icon: ""; barColor: root.walColor5; value: dashboard.ramVal }
                        CircularStat { label: "DISK"; icon: ""; barColor: root.walColor4; value: dashboard.diskVal }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        Row {
                            width: parent.width
                            spacing: 10
                            Text {
                                width: 25
                                text: dashboard.volVal == 0 ? "󰝟" : dashboard.volVal < 50 ? "󰖀" : "󰕾"
                                color: root.walColor4
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                                verticalAlignment: Text.AlignVCenter
                                height: 24
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: volMuteProc.running = true
                                }
                                Process {
                                    id: volMuteProc
                                    command: ["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"]
                                    onExited: volProc.running = true
                                }
                            }
                            Rectangle {
                                id: volSlider
                                width: parent.width - 75
                                height: 8
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 4
                                color: Qt.rgba(0,0,0,0.3)
                                Rectangle {
                                    width: parent.width * dashboard.volVal / 100
                                    height: parent.height
                                    radius: 4
                                    color: root.walColor4
                                    Behavior on width { NumberAnimation { duration: 100 } }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: function(mouse) {
                                        var percent = Math.round((mouse.x / parent.width) * 100)
                                        percent = Math.max(0, Math.min(100, percent))
                                        dashboard.volVal = percent
                                        volSetProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (percent / 100).toFixed(2)]
                                        volSetProc.running = true
                                    }
                                    onPositionChanged: function(mouse) {
                                        if (pressed) {
                                            var percent = Math.round((mouse.x / parent.width) * 100)
                                            percent = Math.max(0, Math.min(100, percent))
                                            dashboard.volVal = percent
                                            volSetProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (percent / 100).toFixed(2)]
                                            volSetProc.running = true
                                        }
                                    }
                                }
                                Process { id: volSetProc }
                            }
                            Text {
                                width: 40
                                text: dashboard.volVal + "%"
                                color: root.walColor8
                                font.pixelSize: 11
                                font.family: "JetBrainsMono Nerd Font"
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                height: 24
                            }
                        }
                        Row {
                            width: parent.width
                            spacing: 10
                            Text {
                                width: 25
                                text: dashboard.brightVal < 30 ? "󰃞" : dashboard.brightVal < 70 ? "󰃟" : "󰃠"
                                color: root.walColor13
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                                verticalAlignment: Text.AlignVCenter
                                height: 24
                            }
                            Rectangle {
                                id: brightSlider
                                width: parent.width - 75
                                height: 8
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 4
                                color: Qt.rgba(0,0,0,0.3)
                                Rectangle {
                                    width: parent.width * dashboard.brightVal / 100
                                    height: parent.height
                                    radius: 4
                                    color: root.walColor13
                                    Behavior on width { NumberAnimation { duration: 100 } }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: function(mouse) {
                                        var percent = Math.round((mouse.x / parent.width) * 100)
                                        percent = Math.max(1, Math.min(100, percent))
                                        dashboard.brightVal = percent
                                        brightSetProc.command = ["bash", "-c", "brightnessctl set " + percent + "%"]
                                        brightSetProc.running = true
                                    }
                                    onPositionChanged: function(mouse) {
                                        if (pressed) {
                                            var percent = Math.round((mouse.x / parent.width) * 100)
                                            percent = Math.max(1, Math.min(100, percent))
                                            dashboard.brightVal = percent
                                            brightSetProc.command = ["bash", "-c", "brightnessctl set " + percent + "%"]
                                            brightSetProc.running = true
                                        }
                                    }
                                }
                                Process { id: brightSetProc }
                            }
                            Text {
                                width: 40
                                text: dashboard.brightVal + "%"
                                color: root.walColor8
                                font.pixelSize: 11
                                font.family: "JetBrainsMono Nerd Font"
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                height: 24
                            }
                        }
                    }
                }

                Rectangle {
                    id: powerProfileBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15

                    property string currentProfile: "balanced"

                    Process {
                        id: profileGetProc
                        command: ["bash", "-c", "cat /sys/firmware/acpi/platform_profile"]
                        stdout: SplitParser {
                            onRead: data => powerProfileBox.currentProfile = data.trim()
                        }
                    }

                    Process {
                        id: profileSetProc
                        property string profile: ""
                        command: ["bash", "-c", "echo '" + profile + "' | sudo tee /sys/firmware/acpi/platform_profile"]
                        onExited: { if (!profileGetProc.running) profileGetProc.running = true }
                    }

                    Timer {
                        interval: 3000
                        running: root.dashboardVisible
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: { if (!profileGetProc.running) profileGetProc.running = true }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Repeater {
                            model: [
                                { profile: "low-power", icon: "󰌪", label: "Saver" },
                                { profile: "balanced",  icon: "󰾅", label: "Balanced" },
                                { profile: "performance", icon: "󱐋", label: "Perform" }
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 10
                                color: powerProfileBox.currentProfile === modelData.profile
                                    ? Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.3)
                                    : (profMa.containsMouse ? Qt.rgba(1,1,1,0.08) : Qt.rgba(0,0,0,0.2))
                                border.width: powerProfileBox.currentProfile === modelData.profile ? 1.5 : 0
                                border.color: root.walColor5

                                Behavior on color { ColorAnimation { duration: 200 } }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 3

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.icon
                                        color: powerProfileBox.currentProfile === modelData.profile
                                            ? root.walColor5 : root.walColor8
                                        font.pixelSize: 16
                                        font.family: "JetBrainsMono Nerd Font"
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.label
                                        color: powerProfileBox.currentProfile === modelData.profile
                                            ? root.walColor5 : root.walColor8
                                        font.pixelSize: 10
                                        font.family: "JetBrainsMono Nerd Font"
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                }

                                MouseArea {
                                    id: profMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        powerProfileBox.currentProfile = modelData.profile
                                        profileSetProc.profile = modelData.profile
                                        profileSetProc.running = true
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: calSection
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 15
                    clip: true

                    property int calYear: new Date().getFullYear()
                    property int calMonth: new Date().getMonth()
                    property var calDays: []
                    property int todayDay: new Date().getDate()
                    property int todayMonth: new Date().getMonth()
                    property int todayYear: new Date().getFullYear()
                    readonly property var monthNames: ["January","February","March","April","May","June","July","August","September","October","November","December"]

                    function buildCalendar() {
                        var first = new Date(calYear, calMonth, 1).getDay()
                        var offset = (first + 6) % 7
                        var total = new Date(calYear, calMonth + 1, 0).getDate()
                        var days = []
                        for (var i = 0; i < offset; i++) days.push(0)
                        for (var d = 1; d <= total; d++) days.push(d)
                        while (days.length % 7 !== 0) days.push(0)
                        calDays = days
                    }
                    function prevMonth() {
                        if (calMonth === 0) { calMonth = 11; calYear-- } else calMonth--
                        buildCalendar()
                    }
                    function nextMonth() {
                        if (calMonth === 11) { calMonth = 0; calYear++ } else calMonth++
                        buildCalendar()
                    }

                    Component.onCompleted: buildCalendar()

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 6

                        Text {
                            id: timeDisplay
                            Layout.alignment: Qt.AlignHCenter
                            text: "00:00"
                            color: root.walColor5
                            font.pixelSize: 36
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        Text {
                            id: dateDisplay
                            Layout.alignment: Qt.AlignHCenter
                            text: ""
                            color: root.walForeground
                            font.pixelSize: 11
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Qt.rgba(1, 1, 1, 0.08)
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                text: "󰅁"
                                color: prevCalMa.containsMouse ? root.walForeground : root.walColor8
                                font.pixelSize: 14
                                font.family: "JetBrainsMono Nerd Font"
                                Behavior on color { ColorAnimation { duration: 100 } }
                                MouseArea {
                                    id: prevCalMa
                                    anchors.fill: parent
                                    anchors.margins: -6
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: calSection.prevMonth()
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: calSection.monthNames[calSection.calMonth] + " " + calSection.calYear
                                color: root.walColor5
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text {
                                text: "󰅂"
                                color: nextCalMa.containsMouse ? root.walForeground : root.walColor8
                                font.pixelSize: 14
                                font.family: "JetBrainsMono Nerd Font"
                                Behavior on color { ColorAnimation { duration: 100 } }
                                MouseArea {
                                    id: nextCalMa
                                    anchors.fill: parent
                                    anchors.margins: -6
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: calSection.nextMonth()
                                }
                            }
                        }

                        Row {
                            Layout.fillWidth: true
                            Repeater {
                                model: ["Mo","Tu","We","Th","Fr","Sa","Su"]
                                Text {
                                    width: (calSection.width - 28) / 7
                                    text: modelData
                                    color: index >= 5 ? root.walColor13 : root.walColor8
                                    font.pixelSize: 9
                                    font.family: "JetBrainsMono Nerd Font"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        Grid {
                            Layout.fillWidth: true
                            columns: 7
                            Repeater {
                                model: calSection.calDays
                                Item {
                                    width: (calSection.width - 28) / 7
                                    height: 24
                                    property bool isToday: modelData === calSection.todayDay &&
                                        calSection.calMonth === calSection.todayMonth &&
                                        calSection.calYear === calSection.todayYear
                                    property bool isWeekend: (index % 7) >= 5
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 20; height: 20; radius: 10
                                        color: isToday ? root.walColor5 : "transparent"
                                        visible: modelData > 0
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData > 0 ? modelData.toString() : ""
                                        color: isToday ? root.walBackground : (isWeekend ? root.walColor13 : root.walForeground)
                                        font.pixelSize: 10
                                        font.bold: isToday
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }

    Connections {
        target: root
        function onDashboardVisibleChanged() {
            if (root.dashboardVisible) {
                focusTimer.start()
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            dashboard.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            dashboard.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }

    component CircularStat: Item {
        property string label
        property string icon
        property color barColor
        property int value
        width: 90
        height: 110
        Column {
            anchors.centerIn: parent
            spacing: 8
            Item {
                width: 70
                height: 70
                anchors.horizontalCenter: parent.horizontalCenter
                Canvas {
                    anchors.fill: parent
                    property int statValue: value
                    onStatValueChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.lineWidth = 5
                        ctx.lineCap = "round"
                        ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.3)
                        ctx.beginPath()
                        ctx.arc(35, 35, 32, 0, 2 * Math.PI)
                        ctx.stroke()
                        ctx.strokeStyle = barColor
                        ctx.beginPath()
                        ctx.arc(35, 35, 32, -Math.PI / 2, -Math.PI / 2 + (statValue / 100) * 2 * Math.PI)
                        ctx.stroke()
                    }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: icon
                        color: barColor
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: value + "%"
                        color: root.walForeground
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: label
                color: root.walColor8
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }

    component PowerBtn: Rectangle {
        property string icon
        property color iconColor
        property string cmd
        width: 40
        height: 40
        radius: 10
        color: powerMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
        Text {
            anchors.centerIn: parent
            text: icon
            color: iconColor
            font.pixelSize: 18
            font.family: "JetBrainsMono Nerd Font"
        }
        MouseArea {
            id: powerMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: cmdProc.running = true
        }
        Process {
            id: cmdProc
            command: ["bash", "-c", cmd]
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            var hours = now.getHours()
            var minutes = now.getMinutes()
            var seconds = now.getSeconds()
            var h = hours < 10 ? '0' + hours : hours
            var m = minutes < 10 ? '0' + minutes : minutes
            var s = seconds < 10 ? '0' + seconds : seconds
            timeDisplay.text = h + ':' + m + ':' + s
            dateDisplay.text = Qt.formatDate(now, "dd.MM.yyyy, dddd")
        }
    }

    Timer {
        interval: 2000
        running: root.dashboardVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!cpuProc.running) cpuProc.running = true
            if (!ramProc.running) ramProc.running = true
            if (!diskProc.running) diskProc.running = true
            if (!batProc.running) batProc.running = true
            if (!batStatusProc.running) batStatusProc.running = true
            if (!volProc.running) volProc.running = true
            if (!brightProc.running) brightProc.running = true
            if (!uptimeProc.running) uptimeProc.running = true
        }
    }

    Process {
        id: cpuProc
        command: ["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print int($2 + $4)}'"]
        stdout: SplitParser { onRead: data => dashboard.cpuVal = parseInt(data) || 0 }
    }
    Process {
        id: ramProc
        command: ["bash", "-c", "free | awk '/Mem:/ {printf \"%.0f\", $3/$2*100}'"]
        stdout: SplitParser { onRead: data => dashboard.ramVal = parseInt(data) || 0 }
    }
    Process {
        id: diskProc
        command: ["bash", "-c", "df / | awk 'NR==2 {gsub(/%/,\"\"); print $5}'"]
        stdout: SplitParser { onRead: data => dashboard.diskVal = parseInt(data) || 0 }
    }
    Process {
        id: batProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo 100"]
        stdout: SplitParser {
            onRead: data => {
                dashboard.batVal = parseInt(data) || 100
                var cap = dashboard.batVal
                if (cap >= 90) batIcon.text = "󰁹"
                else if (cap >= 80) batIcon.text = "󰂂"
                else if (cap >= 70) batIcon.text = "󰂁"
                else if (cap >= 60) batIcon.text = "󰂀"
                else if (cap >= 50) batIcon.text = "󰁿"
                else if (cap >= 40) batIcon.text = "󰁾"
                else if (cap >= 30) batIcon.text = "󰁽"
                else if (cap >= 20) batIcon.text = "󰁼"
                else if (cap >= 10) batIcon.text = "󰁻"
                else batIcon.text = "󰁺"
            }
        }
    }
    Process {
        id: batStatusProc
        command: ["bash", "-c", "status=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo Unknown); time=$(acpi -b 2>/dev/null | grep -oP '\\d+:\\d+' | head -1); echo \"$status|$time\""]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split("|")
                var status = parts[0]
                var time = parts.length > 1 && parts[1] ? parts[1] : ""
                if (status === "Charging") {
                    batStatus.text = time ? "Charging · " + time : "Charging"
                    batIcon.text = "󰂄"
                } else if (status === "Full") {
                    batStatus.text = "Fully charged"
                } else {
                    batStatus.text = time ? "Discharging · " + time : "Discharging"
                }
            }
        }
    }
    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%.0f\", $2*100}'"]
        stdout: SplitParser { onRead: data => dashboard.volVal = parseInt(data) || 0 }
    }
    Process {
        id: brightProc
        command: ["bash", "-c", "brightnessctl -m | awk -F, '{gsub(/%/,\"\"); print $4}'"]
        stdout: SplitParser { onRead: data => dashboard.brightVal = parseInt(data) || 100 }
    }
    Process {
        id: uptimeProc
        command: ["bash", "-c", "uptime -p"]
        stdout: SplitParser { onRead: data => uptimeText.text = data.trim() }
    }
}

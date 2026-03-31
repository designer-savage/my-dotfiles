import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

PanelWindow {
    id: musicPanel
    visible: true
    anchors { top: true; left: true; right: true }
    margins { top: root.musicVisible ? 50 : -250; left: 0; right: 0 }
    implicitWidth: 400
    implicitHeight: 188
    color: "transparent"
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.musicVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    Behavior on margins.top { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    property string playerStatus: "Stopped"
    property string trackTitle: ""
    property string trackArtist: ""
    property string artUrl: ""
    property string artLocalPath: ""
    property real position: 0
    property real lastPosition: 0
    property real length: 0
    property bool hasTrack: playerStatus === "Playing" || playerStatus === "Paused"

    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    Item {
        anchors.fill: parent
        focus: root.musicVisible

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.musicVisible = false
                event.accepted = true
            } else if (event.key === Qt.Key_Space) {
                if (!playPauseProc.running) playPauseProc.running = true
                event.accepted = true
            } else if (event.key === Qt.Key_N) {
                if (!nextProc.running) nextProc.running = true
                event.accepted = true
            } else if (event.key === Qt.Key_P) {
                if (!prevProc.running) prevProc.running = true
                event.accepted = true
            }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 400
            height: 180
            color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.7)
            radius: 15
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6

                    Text {
                        text: musicPanel.trackTitle || "Nothing is playing"
                        color: root.walColor5
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: musicPanel.trackArtist || ""
                        color: root.walForeground
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                        opacity: 0.7
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        visible: musicPanel.trackArtist !== ""
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: musicPanel.hasTrack

                        Text {
                            text: musicPanel.formatTime(musicPanel.position)
                            color: root.walColor8
                            font.pixelSize: 10
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 4
                            radius: 2
                            color: Qt.rgba(0, 0, 0, 0.3)

                            Rectangle {
                                width: musicPanel.length > 0 ? parent.width * (musicPanel.position / musicPanel.length) : 0
                                height: parent.height
                                radius: 2
                                color: root.walColor5
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: function(mouse) {
                                    if (musicPanel.length > 0 && !seekProc.running) {
                                        var seekPos = (mouse.x / parent.width) * musicPanel.length
                                        seekProc.command = ["playerctl", "position", seekPos.toString()]
                                        seekProc.running = true
                                    }
                                }
                            }
                        }

                        Text {
                            text: musicPanel.formatTime(musicPanel.length)
                            color: root.walColor8
                            font.pixelSize: 10
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12
                        opacity: musicPanel.hasTrack ? 1.0 : 0.5

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 8
                            color: prevMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "󰒮"
                                color: root.walForeground
                                font.pixelSize: 16
                                font.family: "JetBrainsMono Nerd Font"
                            }

                            MouseArea {
                                id: prevMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (!prevProc.running) prevProc.running = true
                            }
                        }

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: root.walColor5

                            Text {
                                anchors.centerIn: parent
                                text: musicPanel.playerStatus === "Playing" ? "󰏤" : "󰐊"
                                color: root.walBackground
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (!playPauseProc.running) playPauseProc.running = true
                            }
                        }

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 8
                            color: nextMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "󰒭"
                                color: root.walForeground
                                font.pixelSize: 16
                                font.family: "JetBrainsMono Nerd Font"
                            }

                            MouseArea {
                                id: nextMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (!nextProc.running) nextProc.running = true
                            }
                        }
                    }
                }

                Item {
                    Layout.preferredWidth: 150
                    Layout.fillHeight: true

                    Item {
                        anchors.centerIn: parent
                        width: 150
                        height: 150

                        Rectangle {
                            id: artMask
                            anchors.fill: parent
                            radius: 12
                            opacity: 0
                            layer.enabled: true
                        }

                        Item {
                            anchors.fill: parent
                            visible: musicPanel.artLocalPath !== ""
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskSource: artMask
                            }
                            Image {
                                id: artImage
                                anchors.fill: parent
                                source: musicPanel.artLocalPath !== "" ? "file://" + musicPanel.artLocalPath : ""
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                asynchronous: true
                                cache: false
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: Qt.rgba(0, 0, 0, 0.3)
                            visible: musicPanel.artLocalPath === ""

                            Text {
                                anchors.centerIn: parent
                                text: "󰎇"
                                color: root.walColor8
                                font.pixelSize: 48
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: root
        function onMusicVisibleChanged() {
            if (root.musicVisible) {
                focusTimer.start()
                if (!musicArtProc.running) musicArtProc.running = true
                if (!musicTitleProc.running) musicTitleProc.running = true
                if (!musicArtistProc.running) musicArtistProc.running = true
                if (!musicStatusProc.running) musicStatusProc.running = true
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: {
            musicPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: {
            musicPanel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }

    Timer {
        id: playerPollTimer
        interval: 1000
        running: root.musicVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!musicStatusProc.running) musicStatusProc.running = true
        }
    }

    Timer {
        id: artPrefetchTimer
        interval: 5000
        running: !root.musicVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!musicArtProc.running) musicArtProc.running = true
        }
    }

    Process {
        id: musicStatusProc
        command: ["playerctl", "status"]
        stdout: SplitParser {
            onRead: data => {
                var newStatus = data.trim()
                if (newStatus === "") newStatus = "Stopped"
                var wasPlaying = musicPanel.playerStatus === "Playing"
                var isNowPlaying = newStatus === "Playing"
                musicPanel.playerStatus = newStatus
                if (!musicTitleProc.running) musicTitleProc.running = true
                if (!musicArtistProc.running) musicArtistProc.running = true
                if (!musicLenProc.running) musicLenProc.running = true
                if (!musicArtProc.running) musicArtProc.running = true
                if (isNowPlaying) {
                    if (!musicPosProc.running) musicPosProc.running = true
                } else if (wasPlaying && !isNowPlaying) {
                    musicPanel.lastPosition = musicPanel.position
                } else if (!isNowPlaying) {
                    musicPanel.position = musicPanel.lastPosition
                }
            }
        }
        onExited: code => {
            if (code !== 0) {
                musicPanel.playerStatus = "Stopped"
                musicPanel.trackTitle = ""
                musicPanel.trackArtist = ""
                musicPanel.artUrl = ""
            }
        }
    }

    Process {
        id: musicTitleProc
        command: ["playerctl", "metadata", "title"]
        stdout: SplitParser { onRead: data => musicPanel.trackTitle = data.trim() }
        onExited: code => { if (code !== 0) musicPanel.trackTitle = "" }
    }

    Process {
        id: musicArtistProc
        command: ["playerctl", "metadata", "artist"]
        stdout: SplitParser { onRead: data => musicPanel.trackArtist = data.trim() }
        onExited: code => { if (code !== 0) musicPanel.trackArtist = "" }
    }

    Process {
        id: musicArtProc
        command: ["playerctl", "metadata", "mpris:artUrl"]
        stdout: SplitParser {
            onRead: data => {
                var url = data.trim()
                if (url === "") { musicPanel.artUrl = ""; musicPanel.artLocalPath = ""; return }
                musicPanel.artUrl = url
                if (url.startsWith("https://") || url.startsWith("http://")) {
                    artDownloadProc.command = ["bash", "-c", "curl -sL '" + url + "' -o /tmp/qs_art.jpg && echo '/tmp/qs_art.jpg'"]
                    artDownloadProc.running = true
                } else {
                    musicPanel.artLocalPath = url.replace("file://", "")
                }
            }
        }
        onExited: code => { if (code !== 0) { musicPanel.artUrl = ""; musicPanel.artLocalPath = "" } }
    }

    Process {
        id: artDownloadProc
        stdout: SplitParser { onRead: data => musicPanel.artLocalPath = data.trim() }
    }

    Process {
        id: musicPosProc
        command: ["playerctl", "position"]
        stdout: SplitParser {
            onRead: data => {
                var pos = parseFloat(data.trim()) || 0
                musicPanel.position = pos
                musicPanel.lastPosition = pos
            }
        }
    }

    Process {
        id: musicLenProc
        command: ["sh", "-c", "playerctl metadata mpris:length 2>/dev/null | awk '{print $1/1000000}'"]
        stdout: SplitParser { onRead: data => musicPanel.length = parseFloat(data.trim()) || 0 }
    }

    Process {
        id: playPauseProc
        command: ["playerctl", "play-pause"]
        onExited: { if (!musicStatusProc.running) musicStatusProc.running = true }
    }

    Process {
        id: nextProc
        command: ["playerctl", "next"]
        onExited: { if (!musicStatusProc.running) musicStatusProc.running = true }
    }

    Process {
        id: prevProc
        command: ["playerctl", "previous"]
        onExited: { if (!musicStatusProc.running) musicStatusProc.running = true }
    }

    Process {
        id: seekProc
        command: ["playerctl", "position", "0"]
    }
}

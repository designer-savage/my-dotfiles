import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "./components"

// Минимальный quickshell: только панели Wi-Fi и Bluetooth.
// Вызываются из waybar модулей network/bluetooth через
//   qs ipc --newest call wifi toggle
//   qs ipc --newest call bluetooth toggle
// Всё остальное (бар, лаунчер, обои, плеер) переехало на нативные утилиты
// (waybar, rofi, swww/awww, pywal).

ShellRoot {
    id: root

    property string homePath: Quickshell.env("HOME")
    property string cachePath: homePath + "/.cache"

    // Видимость панелей
    property bool wifiVisible: false
    property bool btVisible: false

    // Wi-Fi state
    property bool wifiEnabled: true
    property string wifiCurrentSSID: ""
    property int wifiSignal: 0
    property bool wifiConnected: wifiCurrentSSID !== ""
    property var wifiNetworks: []
    property bool wifiScanning: false
    property string wifiPasswordSSID: ""
    property bool wifiConnecting: false

    // Bluetooth state
    property bool btEnabled: true
    property bool btConnected: false
    property var btPairedDevices: []
    property var btAvailableDevices: []
    property bool btScanning: false
    property string btConnectingMAC: ""

    // Цвета из pywal (~/.cache/wal/colors.json)
    property color walBackground: "#1e1e2e"
    property color walForeground: "#cdd6f4"
    property color walColor1: "#f38ba8"
    property color walColor2: "#a6e3a1"
    property color walColor5: "#89b4fa"
    property color walColor8: "#6c7086"

    function toggleWifi() {
        wifiVisible = !wifiVisible
        if (wifiVisible) { btVisible = false; walColorsProc.running = true; refreshWifi() }
    }

    function toggleBluetooth() {
        btVisible = !btVisible
        if (btVisible) { wifiVisible = false; walColorsProc.running = true; refreshBluetooth() }
    }

    function refreshWifi() {
        root.wifiNetworks = []
        root.wifiScanning = true
        if (!wifiStatusProc.running) wifiStatusProc.running = true
        if (!wifiCurrentProc.running) wifiCurrentProc.running = true
    }

    function refreshBluetooth() {
        root.btPairedDevices = []
        root.btAvailableDevices = []
        root.btScanning = false
        root.btConnectingMAC = ""
        if (!btStatusProc.running) btStatusProc.running = true
    }

    function connectBt(mac) {
        root.btConnectingMAC = mac
        btActionProc.command = ["bash", "-c", "(echo 'trust " + mac + "'; echo 'connect " + mac + "'; sleep 2; echo 'quit') | bluetoothctl 2>/dev/null"]
        btActionProc.running = true
    }

    function disconnectBt(mac) {
        btActionProc.command = ["bash", "-c", "echo -e 'disconnect " + mac + "\\nquit' | bluetoothctl 2>/dev/null"]
        btActionProc.running = true
    }

    function pairBt(mac) {
        root.btConnectingMAC = mac
        btActionProc.command = ["bash", "-c", "echo -e 'pair " + mac + "\\nquit' | bluetoothctl 2>/dev/null; sleep 2; echo -e 'trust " + mac + "\\nquit' | bluetoothctl 2>/dev/null; sleep 1; echo -e 'connect " + mac + "\\nquit' | bluetoothctl 2>/dev/null"]
        btActionProc.running = true
    }

    function forgetBt(mac) {
        btActionProc.command = ["bash", "-c", "echo -e 'remove " + mac + "\\nquit' | bluetoothctl 2>/dev/null"]
        btActionProc.running = true
    }

    Component.onCompleted: {
        walColorsProc.running = true
    }

    // ---- pywal цвета ----
    Process {
        id: walColorsProc
        command: ["bash", "-c", "cat '" + root.cachePath + "/wal/colors.json' 2>/dev/null"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    var json = JSON.parse(data)
                    if (json.special) {
                        root.walBackground = json.special.background || root.walBackground
                        root.walForeground = json.special.foreground || root.walForeground
                    }
                    if (json.colors) {
                        root.walColor1 = json.colors.color1 || root.walColor1
                        root.walColor2 = json.colors.color2 || root.walColor2
                        root.walColor5 = json.colors.color5 || root.walColor5
                        root.walColor8 = json.colors.color8 || root.walColor8
                    }
                } catch(e) {}
            }
        }
    }

    // ---- Wi-Fi ----
    Process {
        id: nmcliMonitorProc
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim().length === 0) return
                if (!wifiStatusProc.running) wifiStatusProc.running = true
                if (!wifiCurrentProc.running) wifiCurrentProc.running = true
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!wifiStatusProc.running) wifiStatusProc.running = true
            if (!wifiCurrentProc.running) wifiCurrentProc.running = true
        }
    }

    Process {
        id: wifiStatusProc
        command: ["bash", "-c", "nmcli radio wifi 2>/dev/null || echo 'disabled'"]
        stdout: SplitParser { onRead: data => root.wifiEnabled = data.trim() === "enabled" }
    }

    Process {
        id: wifiCurrentProc
        command: ["bash", "-c", "nmcli -t -f IN-USE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^\\*' | head -1"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(":")
                if (parts.length >= 3) {
                    root.wifiCurrentSSID = parts[1]
                    root.wifiSignal = parseInt(parts[2]) || 0
                } else {
                    root.wifiCurrentSSID = ""
                    root.wifiSignal = 0
                }
            }
        }
        onExited: { if (root.wifiVisible && !wifiScanProc.running) wifiScanProc.running = true }
    }

    Process {
        id: wifiScanProc
        command: ["bash", "-c", "nmcli -t -f ssid,signal,security dev wifi list --rescan yes 2>/dev/null | head -20"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length === 0) return
                var parts = line.split(":")
                if (parts.length < 2) return
                var ssid = parts[0]
                if (ssid === "") return
                var signal = parseInt(parts[1]) || 0
                var security = parts.length >= 3 ? parts[2] : ""
                var current = root.wifiNetworks.slice()
                for (var i = 0; i < current.length; i++) {
                    if (current[i].ssid === ssid) return
                }
                if (ssid === root.wifiCurrentSSID)
                    current.unshift({ ssid: ssid, signal: signal, security: security })
                else
                    current.push({ ssid: ssid, signal: signal, security: security })
                root.wifiNetworks = current
            }
        }
        onExited: root.wifiScanning = false
    }

    Process {
        id: wifiToggleProc
        command: ["bash", "-c", root.wifiEnabled ? "nmcli radio wifi off" : "nmcli radio wifi on"]
        onExited: {
            if (!wifiStatusProc.running) wifiStatusProc.running = true
            if (!root.wifiEnabled) wifiScanDelayTimer.start()
        }
    }

    Timer {
        id: wifiScanDelayTimer
        interval: 2000
        repeat: false
        onTriggered: refreshWifi()
    }

    Process {
        id: wifiConnectProc
        property string ssid: ""
        property string password: ""
        command: {
            if (password !== "")
                return ["bash", "-c", "nmcli dev wifi connect '" + ssid + "' password '" + password + "' 2>&1"]
            else
                return ["bash", "-c", "nmcli dev wifi connect '" + ssid + "' 2>&1"]
        }
        onExited: {
            root.wifiConnecting = false
            root.wifiPasswordSSID = ""
            if (!wifiCurrentProc.running) wifiCurrentProc.running = true
        }
    }

    Process {
        id: wifiDisconnectProc
        command: ["bash", "-c", "nmcli dev disconnect $(nmcli -t -f device,type dev | grep ':wifi$' | cut -d: -f1 | head -1) 2>/dev/null"]
        onExited: {
            root.wifiCurrentSSID = ""
            root.wifiSignal = 0
            if (!wifiScanProc.running) wifiScanProc.running = true
        }
    }

    // ---- Bluetooth ----
    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!btStatusProc.running) btStatusProc.running = true
        }
    }

    Process {
        id: btStatusProc
        command: ["bash", "-c", "echo -e 'show\\nquit' | bluetoothctl 2>/dev/null | grep -q 'Powered: yes' && echo 'true' || echo 'false'"]
        stdout: SplitParser {
            onRead: data => root.btEnabled = data.trim() === "true"
        }
        onExited: {
            if (root.btEnabled && !btDevicesProc.running) btDevicesProc.running = true
        }
    }

    Process {
        id: btToggleOnProc
        command: ["bash", "-c", "echo -e 'power on\\nquit' | bluetoothctl 2>/dev/null"]
        onExited: btToggleDelayTimer.start()
    }

    Timer {
        id: btToggleDelayTimer
        interval: 1000
        repeat: false
        onTriggered: refreshBluetooth()
    }

    Process {
        id: btToggleOffProc
        command: ["bash", "-c", "echo -e 'power off\\nquit' | bluetoothctl 2>/dev/null"]
        onExited: {
            root.btEnabled = false
            root.btConnected = false
            root.btPairedDevices = []
            root.btAvailableDevices = []
        }
    }

    Process {
        id: btDevicesProc
        property var btBuffer: []
        command: ["bash", "-c",
            "paired=$(bluetoothctl devices Paired 2>/dev/null); " +
            "connected=$(bluetoothctl devices Connected 2>/dev/null); " +
            "echo \"$paired\" | grep '^Device' | while read -r line; do " +
            "  mac=$(echo \"$line\" | awk '{print $2}'); " +
            "  name=$(echo \"$line\" | cut -d' ' -f3-); " +
            "  is_conn=$(echo \"$connected\" | grep -c \"$mac\"); " +
            "  echo \"${mac}|${name}|$([ \"$is_conn\" -gt 0 ] && echo yes || echo no)\"; " +
            "done"
        ]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length === 0) return
                var parts = line.split("|")
                if (parts.length < 3) return
                btDevicesProc.btBuffer.push({ mac: parts[0], name: parts[1], connected: parts[2] === "yes" })
            }
        }
        onExited: {
            root.btPairedDevices = btDevicesProc.btBuffer
            root.btConnected = false
            for (var i = 0; i < btDevicesProc.btBuffer.length; i++) {
                if (btDevicesProc.btBuffer[i].connected) {
                    root.btConnected = true
                    break
                }
            }
            btDevicesProc.btBuffer = []
        }
    }

    Process {
        id: btScanProc
        property var btAvailBuffer: []
        command: ["bash", "-c",
            "bluetoothctl scan on 2>/dev/null & sleep 5; bluetoothctl scan off 2>/dev/null; sleep 1; " +
            "paired=$(bluetoothctl devices Paired 2>/dev/null); " +
            "bluetoothctl devices 2>/dev/null | grep '^Device' | while read -r line; do " +
            "  mac=$(echo \"$line\" | awk '{print $2}'); " +
            "  name=$(echo \"$line\" | cut -d' ' -f3-); " +
            "  [ ${#mac} -ne 17 ] && continue; " +
            "  { [ -z \"$name\" ] || [ \"$name\" = \"$mac\" ]; } && continue; " +
            "  echo \"$paired\" | grep -q \"$mac\" && continue; " +
            "  echo \"${mac}|${name}\"; " +
            "done"
        ]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length === 0) return
                var parts = line.split("|")
                if (parts.length < 2) return
                if (parts[0].length !== 17) return
                btScanProc.btAvailBuffer.push({ mac: parts[0], name: parts[1] })
            }
        }
        onExited: {
            root.btAvailableDevices = btScanProc.btAvailBuffer
            btScanProc.btAvailBuffer = []
            root.btScanning = false
        }
    }

    Process {
        id: btActionProc
        onExited: {
            root.btConnectingMAC = ""
            btActionDelayTimer.start()
        }
    }

    Timer {
        id: btActionDelayTimer
        interval: 1500
        repeat: false
        onTriggered: refreshBluetooth()
    }

    // ---- Панели ----
    Loader {
        active: true
        asynchronous: true
        sourceComponent: Component { WifiPanel {} }
    }
    Loader {
        active: true
        asynchronous: true
        sourceComponent: Component { BluetoothPanel {} }
    }

    // ---- IPC (вызывается из waybar) ----
    IpcHandler {
        target: "wifi"
        function toggle() { root.toggleWifi() }
    }
    IpcHandler {
        target: "bluetooth"
        function toggle() { root.toggleBluetooth() }
    }
}

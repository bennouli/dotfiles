import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    property bool actionInProgress: btConnect.running || btDisconnect.running

    function findDeviceIndex(mac) {
        for (let i = 0; i < pairedDeviceModel.count; i++) {
            if (pairedDeviceModel.get(i).mac === mac) return i
        }
        return -1
    }

    function setDeviceStatus(mac, status) {
        const idx = findDeviceIndex(mac)
        if (idx !== -1) {
            pairedDeviceModel.setProperty(idx, "status", status)
        }
    }

    function requestConnectedPoll() {
        if (!btConnected.running) {
            btConnected.running = true
        }
    }

    implicitWidth: 300
    implicitHeight: 400
    width: implicitWidth
    height: implicitHeight
    anchors.top: true
    anchors.right: true
    margins.top: 8
    margins.right: 8

    visible: true
    Component.onCompleted: requestConnectedPoll()

    ListModel { id: pairedDeviceModel }

    Process {
	id: btPaired
	command: ["bluetoothctl", "devices", "Paired"]
	running: true

	stdout: SplitParser {
	    onRead: line => {
		const parts = line.split(" ")
		if (parts.length >= 3){
		    const mac = parts[1]
		    const name = parts.slice(2).join(" ")

		    for (let i = 0; i < pairedDeviceModel.count; i++) {
			if (pairedDeviceModel.get(i).mac === mac) return
		    }

		    pairedDeviceModel.append({ mac: mac, name: name, status: "disconnected" })
		}
	    }
	}
    }

    Process {
	id: btConnected
	command: ["bluetoothctl", "devices", "Connected"]
	property var connectedSnapshot: ({})
	running: true

	onRunningChanged: {
	    if (running) {
		btConnected.connectedSnapshot = ({})
	    }
	}

	stdout: SplitParser {
	    onRead: line => {
		const parts = line.split(" ")
		if (parts.length >= 2) {
		    const mac = parts[1]
		    btConnected.connectedSnapshot[mac] = true
		    root.setDeviceStatus(mac, "connected")
		}
	    }
	}

	onExited: code => {
	    if (code !== 0) return

	    for (let i = 0; i < pairedDeviceModel.count; i++) {
		const device = pairedDeviceModel.get(i)
		if (device.status === "connecting" || device.status === "failed") continue
		const nextStatus = btConnected.connectedSnapshot[device.mac] ? "connected" : "disconnected"
		pairedDeviceModel.setProperty(i, "status", nextStatus)
	    }
	}
    }

    Rectangle {
	anchors.fill: parent
	color: "#1a1b26"
	radius: 12

	ColumnLayout {
	    anchors.fill: parent
	    anchors.margins: 16
	    spacing: 8

	    Text {
		text: "Bluetooth"
		color: "#bb9af7"
		font.pixelSize: 16
		font.bold: true
	    }

	    ListView {
		id: deviceList
		Layout.fillWidth: true
		Layout.fillHeight: true
		model: pairedDeviceModel
		clip: true

		delegate: Rectangle {
		    width: deviceList.width
		    height: 40
		    color: "transparent"

		    // check if this device is connected
		    property bool isConnected: model.status === "connected"
		    property bool isConnecting: model.status === "connecting"


		    RowLayout {
			anchors.fill: parent

			Rectangle {
			    width: 8
			    height: 8
			    radius: 4
			    color: isConnected ? "#9ece6a" : "#565f89"
			}
			
			Text {
			    text: model.name
			    color: "#c0caf5"
			    font.pixelSize: 13
			    Layout.fillWidth: true
			    Layout.alignment: Qt.AlignVCenter
			}

			Rectangle {
			    width: 90
			    height: 28
			    radius: 6
			    color: actionBtn.pressed ? "#bb9af7" : isConnected ? "#2d2f45" : "#24283b" 

			    Text {
				anchors.centerIn: parent
				text: isConnected ? "Disconnect" : isConnecting ? "..." : "Connect"
				color: isConnected ? "#f7768e" : "#bb9af7"
				font.pixelSize: 11
			    }

			    MouseArea {
				id: actionBtn
				anchors.fill: parent
				enabled: !root.actionInProgress
				onClicked: {
				    if (root.actionInProgress) return

				    if (isConnected) {
					btDisconnect.mac = model.mac
					btDisconnect.running = true

					return
				    }

				    btConnect.mac = model.mac
				    btConnect.running = true
				}
			    }
			}
		    }

		}
	    }

	    Rectangle {
		Layout.fillWidth: true
		height: 36
		radius: 8
		color: refreshBtn.pressed ? "#bb9af7" :"#24283b"
		opacity: root.actionInProgress ? 0.6 : 1.0

		Text {
		    anchors.centerIn: parent
		    text: "Refresh"
		    color: root.actionInProgress ? "#565f89" : "#bb9af7"
		    font.pixelSize: 13
		}

		MouseArea {
		    id: refreshBtn
		    anchors.fill: parent
		    enabled: !root.actionInProgress
		    onClicked: {
				if (root.actionInProgress) return
				
				pairedDeviceModel.clear()
				btPaired.running = true
				btConnected.running = true
		    }
		}
	    }
	}

	Process {
	    id: btConnect
	    property string mac: ""
	    command: ["bluetoothctl", "connect", mac]
	    running: false

	    onRunningChanged: {
			if (running) { 
		    root.setDeviceStatus(btConnect.mac, "connecting")
				connectTimeout.restart() 
			}
			else { 
				connectTimeout.stop() 
			}
	    }

	    onExited: (code) => {
		connectTimeout.stop()
		if (code === 0 ) {
		    root.setDeviceStatus(btConnect.mac, "connected")
		} else {
		    root.setDeviceStatus(btConnect.mac, "failed")
		}
	    }
	}

	Timer {
	    id: connectTimeout
	    interval: 8000
	    repeat: false
	    onTriggered: {
		if (btConnect.running) {
		    btConnect.running = false
		}
	    }
	}

	Process {
	    id: btDisconnect
	    property string mac: ""
	    command: ["bluetoothctl", "disconnect", mac]
	    running: false

	    onExited: (code) => {
		if (code === 0) {
		    root.setDeviceStatus(btDisconnect.mac, "disconnected")
		}
	    }
	}

	Timer {
	    id: pollConnected
	    interval: 3000
	    repeat: true
	    running: root.visible
	    onTriggered: {
		root.requestConnectedPoll()
	    }
	}
    }
}

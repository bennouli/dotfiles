import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    anchors.left: true
    anchors.top: true
    anchors.bottom: true

    implicitWidth: 200
    width: implicitWidth
    // exclusiveZone: 0

    color: "white"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
	radius: 13
	color: "#1c1e1f"

	RowLayout {
	    anchors.left: parent.left
	    anchors.right: parent.right
	    anchors.top: parent.top
	    anchors.margins: 8
	    spacing: 8

	    Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: 50
		radius: 10
		color: "#eeaacc"
	    }

	    Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: 50
		radius: 10
		color: "#aaccee"
	    }

	    Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: 50
		radius: 10
		color: "#cceeaa"
	    }
	}
    }
}

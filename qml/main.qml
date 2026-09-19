import QtQuick 2.6
import Eos.Window 0.1
import LunaNext.Common 0.1
import LuneOS.Service 1.0

WebOSWindow {
    id: root
    visible: true
    width: 600
    height: 800
    windowType: "_WEBOS_WINDOW_TYPE_CARD"
    title: "Torch"
    color: "black"

    property bool available: false
    property bool torchOn: false

    // Same service and calls the shell's Flashlight toggle uses
    // (luna-next-cardshell NewDeviceMenu.qml), so the app and the system menu
    // stay in sync: torchd owns the LED, we just drive and observe it.
    LunaService {
        id: torch
        name: "org.webosports.app.torch"
        usePrivateBus: true
    }

    ServiceStatus {
        id: torchStatus
        serviceName: "org.webosports.service.torch"
        onConnected: {
            torch.subscribe("luna://org.webosports.service.torch/getStatus",
                JSON.stringify({"subscribe": true}),
                function(msg) {
                    var r = JSON.parse(msg.payload);
                    if (r.hasOwnProperty("available")) root.available = r.available;
                    if (r.hasOwnProperty("on")) root.torchOn = r.on;
                },
                function(err) { root.available = false; });
        }
        onDisconnected: root.available = false
    }

    function toggle() {
        torch.call("luna://org.webosports.service.torch/toggle", "{}",
                   function(m) {}, function(e) { console.warn("torch toggle failed: " + JSON.stringify(e)); });
    }

    Column {
        anchors.centerIn: parent
        spacing: Units.gu(4)

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Units.gu(28); height: width; radius: width / 2
            color: root.torchOn ? "#efb810" : "#333333"
            border.color: "#efb810"; border.width: Units.gu(0.5)
            Behavior on color { ColorAnimation { duration: 150 } }
            Text {
                anchors.centerIn: parent
                text: root.torchOn ? "ON" : "OFF"
                color: root.torchOn ? "black" : "#efb810"
                font.pixelSize: Units.gu(6); font.bold: true
            }
            MouseArea { anchors.fill: parent; enabled: root.available; onClicked: root.toggle() }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            text: root.available ? "Tap to toggle the flash" : "Torch unavailable"
            color: "#888888"; font.pixelSize: Units.gu(2.2)
        }
    }
}

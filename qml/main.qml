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

    property bool available: false
    property bool torchOn: false

    // torchd owns the LED; we drive and observe it the same way the shell's
    // Flashlight quick-toggle does, so the two stay in sync.
    LunaService {
        id: torch
        name: "org.webosports.app.torch"
        usePrivateBus: true
        onInitialized: subscribe("luna://org.webosports.service.torch/getStatus",
            JSON.stringify({"subscribe": true}),
            function(m) { var r = JSON.parse(m.payload);
                if (r.hasOwnProperty("available")) root.available = r.available;
                if (r.hasOwnProperty("on")) root.torchOn = r.on; },
            function(e) { root.available = false; })
    }
    function toggle() {
        torch.call("luna://org.webosports.service.torch/toggle", "{}",
                   function(m){}, function(e){ console.warn("torch toggle failed: " + JSON.stringify(e)); })
    }

    // Dark, softly-lit backdrop that warms up when the torch is on.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.torchOn ? "#2a2620" : "#1a1c20" }
            GradientStop { position: 1.0; color: "#000000" }
        }
        Behavior on color {}
    }

    Item {
        anchors.fill: parent

        // The torch, upright, lower-centre. Off image always shown; on image
        // (glowing lens + beam) cross-fades in. Beam points up the screen.
        Image {
            id: torchOff
            source: "images/torch_off.png"
            fillMode: Image.PreserveAspectFit
            width: parent.width * 0.62
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.gu(10)
            smooth: true
        }
        Image {
            source: "images/torch_on.png"
            width: torchOff.width
            anchors.horizontalCenter: torchOff.horizontalCenter
            anchors.bottom: torchOff.bottom
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: root.torchOn ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.gu(4)
            text: root.available ? (root.torchOn ? "Tap to turn off" : "Tap to turn on")
                                 : "Torch unavailable"
            color: "#9a9a9a"
            font.pixelSize: Units.gu(2.4)
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.available
            onClicked: root.toggle()
        }
    }
}

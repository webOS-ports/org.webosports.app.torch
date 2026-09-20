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

    // torchd owns the LED; drive and observe it the same way the shell's
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
    function turnOff() {
        torch.call("luna://org.webosports.service.torch/set", JSON.stringify({"on": false}),
                   function(m){}, function(e){})
    }
    // Closing the card destroys the app; make sure we don't leave the LED on.
    // (Backgrounding keeps the app alive and does not fire this, so the torch
    //  stays lit if you pocket the device with the app still open.)
    Component.onDestruction: if (root.torchOn) turnOff()

    // Dark backdrop that warms up when the torch is on.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.torchOn ? "#332d24" : "#1a1c20" }
            GradientStop { position: 1.0; color: "#000000" }
        }
    }

    Image {
        id: torchOff
        source: "images/torch_off.png"
        height: parent.height * 0.86
        width: height * (sourceSize.width / sourceSize.height)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Units.gu(7)
        smooth: true
        mipmap: true
    }
    Image {
        source: "images/torch_on.png"
        height: torchOff.height
        width: torchOff.width
        anchors.horizontalCenter: torchOff.horizontalCenter
        anchors.bottom: torchOff.bottom
        smooth: true
        mipmap: true
        opacity: root.torchOn ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Units.gu(2.5)
        text: root.available ? (root.torchOn ? "Tap to turn off" : "Tap to turn on") : "Torch unavailable"
        color: "#9a9a9a"
        font.pixelSize: Units.gu(2.4)
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.available
        onClicked: root.toggle()
    }
}

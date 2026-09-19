import QtQuick 2.6
import Eos.Window 0.1
import LunaNext.Common 0.1
import TorchApp 1.0

WebOSWindow {
    id: root
    width: 600
    height: 800
    windowType: "_WEBOS_WINDOW_TYPE_CARD"
    title: "Torch"
    displayAffinity: params.displayAffinity

    color: "black"

    Column {
        anchors.centerIn: parent
        spacing: Units.gu(4)

        Rectangle {
            id: button
            anchors.horizontalCenter: parent.horizontalCenter
            width: Units.gu(28); height: width; radius: width / 2
            color: Torch.on ? "#efb810" : "#333333"
            border.color: "#efb810"; border.width: Units.gu(0.5)
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: Torch.on ? "ON" : "OFF"
                color: Torch.on ? "black" : "#efb810"
                font.pixelSize: Units.gu(6); font.bold: true
            }
            MouseArea {
                anchors.fill: parent
                enabled: Torch.available
                onClicked: Torch.toggle()
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            text: Torch.available ? "Tap to toggle the flash" : "No torch LED found"
            color: "#888888"; font.pixelSize: Units.gu(2.2)
        }
    }
}

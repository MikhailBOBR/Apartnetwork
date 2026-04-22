import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string title: ""
    property string value: ""
    property string caption: ""
    property color surfaceColor: "#FFF9F1"
    property color borderColor: "#E4D8C8"
    property color textColor: "#21313A"
    property color mutedColor: "#6B7280"
    property color accentColor: "#1B6B65"

    radius: 22
    color: surfaceColor
    border.color: borderColor
    implicitWidth: 240
    implicitHeight: 136

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 6
            radius: 3
            color: root.accentColor
        }

        Label {
            text: root.title
            color: root.mutedColor
            font.pixelSize: 14
        }

        Label {
            text: root.value
            color: root.textColor
            font.pixelSize: 24
            font.bold: true
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        Label {
            text: root.caption
            color: root.mutedColor
            font.pixelSize: 13
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }
}

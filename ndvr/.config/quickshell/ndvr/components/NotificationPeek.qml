import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services

// Shown for Config.peekDuration when a notification arrives, and again when
// a sender replaces one in place.
RowLayout {
    id: root

    readonly property var notif: Notifs.latest

    // The sender's live object where it still has one, so a notification
    // replaced while the peek is up says the new thing rather than leaving
    // the old one on screen for the rest of its four seconds.
    readonly property var view: Notifs.view(root.notif)

    spacing: 11

    ClippingRectangle {
        Layout.preferredWidth: 36
        Layout.preferredHeight: 36
        Layout.alignment: Qt.AlignVCenter
        radius: 9
        color: Config.hairline

        // Prefer the notification's own image (message avatars and so on),
        // fall back to the sending application's icon.
        IconImage {
            anchors.fill: parent
            anchors.margins: root.view && root.view.image ? 0 : 7
            source: {
                if (!root.view)
                    return "";
                if (root.view.image)
                    return root.view.image;
                return Notifs.appIconSource(root.view.appIcon);
            }
            asynchronous: true
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

        RowLayout {
            spacing: 6

            Text {
                text: root.notif ? root.notif.appName : ""
                color: Config.textDim
                font.family: Config.font
                font.pixelSize: 10
                font.weight: Font.Medium
            }

            Rectangle {
                visible: root.notif && root.notif.urgent
                Layout.alignment: Qt.AlignVCenter
                width: 5
                height: 5
                radius: 2.5
                color: Config.urgent
            }

            Item {
                Layout.fillWidth: true
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.view ? root.view.summary : ""
            color: Config.text
            elide: Text.ElideRight
            textFormat: Text.PlainText
            font.family: Config.font
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.view ? Notifs.bodyLine(root.view.body) : ""
            color: Config.textDim
            elide: Text.ElideRight
            maximumLineCount: 1
            textFormat: Text.PlainText
            font.family: Config.font
            font.pixelSize: 11
        }
    }
}

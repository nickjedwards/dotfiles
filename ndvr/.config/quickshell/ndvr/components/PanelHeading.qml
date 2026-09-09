pragma ComponentBehavior: Bound

import QtQuick
import qs.services

// The heading an open panel wears: what the panel is at the left of a line,
// whatever acts on it at the right of the same line, and a hairline under
// both.
//
// One component rather than a copy per panel, because three copies of a
// heading are three headings that drift apart — which is what had happened.
// The notification centre ruled its heading off and the other two didn't,
// and all three left a different gap under the title.
Item {
    id: root

    required property string title

    // The title's own line, so a panel can hang whatever acts on it off the
    // right of that rather than off the whole heading, which is taller by a
    // rule:
    //
    //     PanelHeading {
    //         title: "Notifications"
    //
    //         Text {
    //             anchors.right: parent.right
    //             anchors.rightMargin: Config.ccPadX
    //             anchors.verticalCenter: parent.line.verticalCenter
    //             text: "Clear"
    //         }
    //     }
    //
    // Anything declared inside becomes a child of the heading, which is what
    // makes that anchor legal — the two are siblings.
    readonly property alias line: label

    implicitHeight: Config.ccPadX + label.height + Config.panelRuleGap + rule.height

    Text {
        id: label

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: Config.ccPadX
        anchors.topMargin: Config.ccPadX
        text: root.title
        color: Config.text
        font.family: Config.font
        font.pixelSize: Config.panelHeadingSize
        font.weight: Font.DemiBold
    }

    Rectangle {
        id: rule

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: Config.ccPadX
        anchors.rightMargin: Config.ccPadX
        height: 1
        color: Config.hairline
    }
}

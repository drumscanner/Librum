import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import CustomComponents
import Librum.style
import Librum.icons
import Librum.controllers
import Librum.fonts

Popup {
    id: root
    property string translation
    property string text

    implicitWidth: 800
    implicitHeight: 700
    padding: 32
    bottomPadding: 28
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    background: Rectangle {
        color: Style.colorPopupBackground
        radius: 6
        border.width: 1
        border.color: Style.colorContainerBorder
    }

    onOpened: {
        internal.sendTranslationRequest()
    }

    onClosed: {
        root.translation = ""
        root.text = ""

        internal.dataChanged = false
        errorItem.visible = false
    }

    Connections {
        target: TranslationController

        function onWordReady(word) {
            root.translation += word
        }

        function onLimitReached() {
            errorItem.visible = true
            //: Make sure that the words make a valid sentence
            errorText.text = qsTr('You have reached your daily limit.') + ' '
                + ' <a href="update" style="color: ' + Style.colorBasePurple
                + '; text-decoration: none;">' + qsTr(
                    'Upgrade') + '</a> ' + qsTr('to continue.')
        }

        function onRequestTooLong() {
            errorItem.visible = true
            errorText.text = qsTr(
                'Oops! The text is too long. Please shorten your selection.')
        }
    }

    ColumnLayout {
        anchors.fill: parent

        MButton {
            id: closeButton
            Layout.preferredHeight: 32
            Layout.preferredWidth: 32
            Layout.alignment: Qt.AlignRight
            backgroundColor: "transparent"
            opacityOnPressed: 0.7
            borderColor: "transparent"
            radius: 6
            borderColorOnPressed: Style.colorButtonBorder
            imagePath: Icons.closePopup
            imageSize: 14

            onClicked: root.close()
        }

        MLabeledInputBox {
            id: request
            Layout.fillWidth: true
            Layout.topMargin: 24
            headerFontColor: Style.colorLightText
            headerFontSize: Fonts.size12
            borderColor: Style.colorContainerBorder
            borderWidth: 1
            text: root.text
            backgroundColor: Style.colorContainerBackground
            inputFontSize: Fonts.size13
            headerText: qsTr("Request")
            readOnly: true
        }

        Pane {
            id: translationContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 32
            rightPadding: 16
            clip: true
            background: Rectangle {
                color: Style.colorContainerBackground
                radius: 6
                border.width: 1
                border.color: Style.colorContainerBorder
            }

            Flickable {
                id: translationFlick
                anchors.fill: parent
                contentWidth: translationField.contentWidth
                contentHeight: translationField.contentHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                boundsMovement: Flickable.StopAtBounds

                onContentHeightChanged: contentY = contentHeight - height

                TextEdit {
                    id: translationField
                    width: translationFlick.width
                    focus: true
                    text: root.translation
                    font.pointSize: Fonts.size13
                    color: Style.colorText
                    readOnly: true
                    wrapMode: Text.WordWrap
                    selectionColor: Style.colorTextSelection
                }
            }

            Item {
                id: errorItem
                visible: false
                anchors.fill: parent

                ColumnLayout {
                    width: parent.width
                    anchors.centerIn: parent

                    Image {
                        id: errorIllustration
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: -30
                        source: Icons.attentionPurple
                        sourceSize.width: 270
                        fillMode: Image.PreserveAspectFit
                    }

                    Label {
                        id: errorText
                        Layout.alignment: Qt.AlignHCenter
                        textFormat: Text.RichText
                        text: ""
                        color: Style.colorTitle
                        font.weight: Font.Medium
                        font.pointSize: Fonts.size14
                        onLinkActivated: Qt.openUrlExternally(
                            AppInfoController.website + "/pricing")

                        // Switch to the proper cursor when hovering above the link
                        MouseArea {
                            id: mouseArea
                            acceptedButtons: Qt.NoButton // Don't eat the mouse clicks
                            anchors.fill: parent
                            cursorShape: errorText.hoveredLink
                                !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }
            }

            ScrollBar {
                id: verticalScrollbar
                width: pressed ? 14 : 12
                hoverEnabled: true
                active: true
                policy: ScrollBar.AlwaysOff
                visible: translationFlick.contentHeight > translationFlick.height
                orientation: Qt.Vertical
                size: translationFlick.height / translationFlick.contentHeight
                minimumSize: 0.04
                position: (translationFlick.contentY - translationFlick.originY) / translationFlick.contentHeight
                onPositionChanged: if (pressed)
                    translationFlick.contentY = position
                        * translationFlick.contentHeight + translationFlick.originY
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: -12
                anchors.bottom: parent.bottom
                horizontalPadding: 4

                contentItem: Rectangle {
                    color: Style.colorScrollBarHandle
                    opacity: verticalScrollbar.pressed ? 0.8 : 1
                    radius: 4
                }

                background: Rectangle {
                    implicitWidth: 26
                    implicitHeight: 200
                    color: "transparent"
                }
            }
        }

        Item {
            id: aiWarningItem
            Layout.preferredWidth: warningLayout.width
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignRight

            RowLayout {
                id: warningLayout
                height: parent.height
                spacing: 4

                Image {
                    id: actionImage
                    Layout.alignment: Qt.AlignVCenter
                    source: Icons.warningCircle
                    sourceSize.width: 16
                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    id: actionText
                    Layout.topMargin: -1
                    text: qsTr("Note: AI responses can be inaccurate")
                    font.pointSize: Fonts.size10
                    color: Style.colorBasePurple
                }
            }
        }

        MButton {
            id: askButton
            Layout.preferredHeight: 38
            Layout.topMargin: 4
            Layout.alignment: Qt.AlignLeft
            horizontalMargins: 46
            borderWidth: internal.dataChanged ? 0 : 1
            backgroundColor: internal.dataChanged ? Style.colorBasePurple : "transparent"
            opacityOnPressed: 0.7
            text: qsTr("Translate")
            textColor: internal.dataChanged ? Style.colorFocusedButtonText : Style.colorUnfocusedButtonText
            fontWeight: Font.Bold
            fontSize: Fonts.size12

            onClicked: {
                if (internal.dataChanged) {
                    root.translation = ""
                    internal.sendTranslationRequest()
                    internal.dataChanged = false
                }
            }
        }
    }

    QtObject {
        id: internal
        property bool dataChanged: false

        function sendTranslationRequest() {
            TranslationController.getTranslation(root.text)
        }
    }
}

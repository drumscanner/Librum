import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import CustomComponents
import Librum.elements
import Librum.style
import Librum.icons
import Librum.fonts
import Librum.controllers
import Librum.globals
import Librum.models
import Librum.globalSettings
import "toolbar"
import "manageTagsPopup"
import "folderSidebar"
import "../loginPage"

Page {
    id: root
    rightPadding: 70
    bottomPadding: 20
    background: Rectangle {
        anchors.fill: parent
        color: Style.colorPageBackground
    }

    Component.onCompleted: {
        // We don't want to show the feedback popup when coming from the login page
        // since that might be annoying to the user.
        if (!(pageManager.prevPage instanceof MLoginPage)) {
            feedbackTimer.start()
        }
    }

    Component.onDestruction: {
        toolbar.selectBooksCheckBoxActivated = false
    }

    // Add a slight delay to showing the feedback timer
    Timer {
        id: feedbackTimer
        interval: 500
        running: false
        repeat: false

        onTriggered: internal.showFeedbackPopupIfNeeded()
    }

    Shortcut {
        sequence: SettingsController.shortcuts.AddBook
        onActivated: importFilesDialog.open()
    }

    Connections {
        target: LibraryController

        function onStorageLimitExceeded() {
            uploadLimitReachedPopup.open()
        }
    }

    MFolderSidebar {
        id: folderSidebar
        height: parent.height + root.bottomPadding
    }

    // Left spacing for the content
    Item {
        id: contentLeftSpacing
        anchors.left: folderSidebar.right
        height: parent.height
        width: 64
    }

    Rectangle {
        id: foldersButton
        x: -16 + folderSidebar.width
        z: -1
        y: root.height / 2 + 36
        width: 52
        height: 42
        color: Style.colorControlBackground
        radius: width
        border.width: 1
        border.color: Style.colorButtonBorder
        opacity: foldersButtonMouseArea.pressed ? 0.8 : 1

        Image {
            id: folderImage
            x: parent.width / 2 - width / 2 + 5
            anchors.verticalCenter: parent.verticalCenter
            sourceSize.width: folderSidebar.opened ? 25 : 20
            sourceSize.height: folderSidebar.opened ? 25 : 20
            source: folderSidebar.opened ? Icons.arrowheadBackIcon : Icons.folder
        }

        MouseArea {
            id: foldersButtonMouseArea
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent

            onClicked: {
                folderSidebar.toggle()
            }
        }
    }

    DropArea {
        id: dropArea
        anchors.left: contentLeftSpacing.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        onDropped: drop => internal.addBooks(drop.urls)

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                id: updateBanner
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                Layout.leftMargin: -root.horizontalPadding - contentLeftSpacing.width
                Layout.rightMargin: -root.rightPadding
                visible: baseRoot.notifyAboutUpdates
                         && AppInfoController.newestVersion !== ""
                         && AppInfoController.currentVersion !== AppInfoController.newestVersion

                Rectangle {
                    anchors.fill: parent
                    color: Style.colorBannerBackground
                    opacity: 0.8
                }

                Label {
                    id: updateBannerText
                    anchors.centerIn: parent
                    text: qsTr('A new version is available!')
                          + ' <a href="update" style="color: #FFFFFF; text-decoration: underline;">'
                          + qsTr('Update Now') + '</a>'
                    onLinkActivated: baseRoot.loadSettingsUpdatesPage()
                    textFormat: Text.RichText
                    color: Style.colorBannerText
                    font.bold: true
                    font.pointSize: Fonts.size12

                    // Switch to the proper cursor when hovering above the link
                    MouseArea {
                        id: mouseArea
                        acceptedButtons: Qt.NoButton // Don't eat the mouse clicks
                        anchors.fill: parent
                        cursorShape: updateBannerText.hoveredLink
                                     !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

                MButton {
                    id: closeButton
                    width: 32
                    height: 32
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    backgroundColor: "transparent"
                    opacityOnPressed: 0.7
                    borderColor: "transparent"
                    radius: 6
                    borderColorOnPressed: Style.colorButtonBorder
                    imagePath: Icons.closePopupWhite
                    imageSize: 12

                    onClicked: {
                        baseRoot.notifyAboutUpdates = false
                        updateBanner.visible = false
                    }
                }
            }

            RowLayout {
                id: headerRow
                Layout.fillWidth: true
                spacing: 0

                MTitle {
                    id: pageTitle
                    Layout.topMargin: updateBanner.visible ? 24 : 44
                    //: As in 'Home Page', might be closer to 'Start' in other languages
                    titleText: qsTr("Home")
                    descriptionText: {
                        let folder = LibraryController.libraryModel.folder
                        if (folder === "all") {
                            return qsTr("You have %1 books").arg(
                                        LibraryController.bookCount)
                        }

                        let sentence = qsTr("In Folder") + ": "
                        if (folder === "unsorted") {
                            return sentence + qsTr("Unsorted")
                        }

                        let folderName = FolderController.getFolder(folder).name
                        return sentence + folderName
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                MButton {
                    id: addBooksButton
                    Layout.preferredHeight: 40
                    Layout.topMargin: 22
                    Layout.alignment: Qt.AlignBottom
                    horizontalMargins: 12
                    borderWidth: 0
                    backgroundColor: Style.colorBasePurple
                    text: qsTr("Add books")
                    textColor: Style.colorFocusedButtonText
                    fontWeight: Font.Bold
                    fontSize: Fonts.size13
                    imagePath: Icons.addWhite

                    onClicked: importFilesDialog.open()
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.maximumHeight: 45
                Layout.minimumHeight: 8
            }

            MToolbar {
                id: toolbar
                visible: !internal.libraryIsEmpty
                Layout.fillWidth: true
                z: 2

                onSearchRequested: query => LibraryController.libraryModel.sortString = query

                onCheckBoxActivated: activated => Globals.bookSelectionModeEnabled = activated
            }

            Pane {
                id: bookGridContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 100
                Layout.topMargin: 30
                visible: !internal.libraryIsEmpty && bookGrid.count !== 0
                padding: 0
                background: Rectangle {
                    color: "transparent"
                }

                GridView {
                    id: bookGrid
                    anchors.fill: parent
                    cellWidth: internal.bookWidth + internal.horizontalBookSpacing
                    cellHeight: internal.bookHeight + internal.verticalBookSpacing
                    rightMargin: -internal.horizontalBookSpacing
                    layoutDirection: Qt.LeftToRight
                    LayoutMirroring.enabled: false
                    LayoutMirroring.childrenInherit: true
                    interactive: true
                    boundsBehavior: Flickable.StopAtBounds
                    flickDeceleration: 15000
                    maximumFlickVelocity: 3500
                    clip: true
                    model: LibraryController.libraryModel
                    delegate: MBook {
                        id: bookDelegate

                        onLeftButtonClicked: {
                            // If book selection mode is enabled we just want to select / deselect the clicked book
                            if (Globals.bookSelectionModeEnabled) {
                                var index = Globals.selectedBooks.indexOf(model.uuid)
                                if (index !== -1) {
                                    bookDelegate.deselect()
                                    Globals.selectedBooks.splice(index, 1)
                                } else {
                                    bookDelegate.select()
                                    Globals.selectedBooks.push(model.uuid)
                                }
                                return
                            }

                            if (model.downloaded) {
                                Globals.selectedBook = LibraryController.getBook(model.uuid)
                                internal.openBook()
                            } // Don't start downloading if downloading is already in progress.
                            else if (!bookDelegate.downloading) {
                                bookDelegate.downloading = true
                                LibraryController.downloadBookMedia(model.uuid)
                            }
                        }


                        /*
                            When right-clicking a book, open the bookOptions popup.
                        */
                        onRightButtonClicked: (index, mouse) => {
                                                  // Calculate where to spawn the bookOptions popup and set its position
                                                  let currentMousePosition = mapToItem(
                                                      bookGridContainer,
                                                      mouse.x, mouse.y)
                                                  let absoluteMousePosition = mapToItem(
                                                      root, mouse.x, mouse.y)

                                                  if (Globals.bookSelectionModeEnabled) {
                                                      bookMultiSelectOptionsPopup.setSpawnPosition(
                                                          currentMousePosition,
                                                          absoluteMousePosition,
                                                          root)
                                                  } else {
                                                      bookOptionsPopup.setSpawnPosition(
                                                          currentMousePosition,
                                                          absoluteMousePosition,
                                                          root)
                                                  }

                                                  // Open the bookOptions
                                                  internal.openBookOptionsPopup(
                                                      model)
                                              }


                        /*
                            When clicking more options, open the bookOptions popup
                        */
                        onMoreOptionClicked: (index, point) => {
                             // Calculate where to spawn the bookOptions popup and set its position
                             let currentMousePosition = mapToItem(
                                 bookGridContainer, point)

                             bookOptionsPopup.x = currentMousePosition.x
                                    - bookOptionsPopup.implicitWidth / 2
                             bookOptionsPopup.y = currentMousePosition.y
                                    - bookOptionsPopup.implicitHeight - 6

                             // Open the bookOptions
                             internal.openBookOptionsPopup(model)
                         }
                    }


                    /*
                  The options menu when e.g. right-clicking a book
                  */
                    MBookRightClickPopup {
                        id: bookOptionsPopup

                        onDownloadClicked: {
                            close()
                        }

                        onReadBookClicked: {
                            internal.openBook()
                        }

                        onBookDetailsClicked: {
                            bookDetailsPopup.open()
                            close()
                        }

                        onSaveToFilesClicked: {
                            downloadFileDialog.open()
                            close()
                        }

                        onManageTagsClicked: {
                            manageTagsPopup.open()
                            close()
                        }

                        onAddToFolderClicked: {
                            moveBookToFolderPopup.bookUuid = Globals.selectedBook.uuid
                            moveBookToFolderPopup.open()
                            close()
                        }

                        onRemoveClicked: {
                            if (!internal.inFolderMode)
                                acceptDeletionPopup.open()
                            else
                                acceptRemoveFromFolderPopup.open()

                            close()
                        }
                    }


                    /*
                  The options menu when e.g. right-clicking a book while multi selection is enabled
                  */
                    MBookMultiSelectRightClickPopup {
                        id: bookMultiSelectOptionsPopup

                        onMarkAsReadClicked: {

                            toolbar.selectBooksCheckBoxActivated = false
                            close()
                        }

                        onRemoveClicked: {
                            if (!internal.inFolderMode) {
                                acceptMultiDeletionPopup.selectedBooks = Globals.selectedBooks
                                acceptMultiDeletionPopup.open()
                            } else {
                                acceptMultiRemoveFromFolderPopup.selectedBooks
                                        = Globals.selectedBooks
                                acceptMultiRemoveFromFolderPopup.open()
                            }

                            toolbar.selectBooksCheckBoxActivated = false
                            close()
                        }

                        onAddToFolderClicked: {
                            moveBookToFolderPopup.moveMultipleBooks = true
                            moveBookToFolderPopup.books = Globals.selectedBooks
                            moveBookToFolderPopup.open()

                            toolbar.selectBooksCheckBoxActivated = false
                            close()
                        }
                    }
                }

                ScrollBar {
                    id: verticalScrollbar
                    width: pressed ? 14 : 12
                    hoverEnabled: true
                    active: true
                    policy: ScrollBar.AlwaysOff
                    visible: bookGrid.contentHeight > bookGrid.height
                    orientation: Qt.Vertical
                    size: bookGrid.height / bookGrid.contentHeight
                    minimumSize: 0.04
                    position: (bookGrid.contentY - bookGrid.originY) / bookGrid.contentHeight
                    onPositionChanged: if (pressed)
                                           bookGrid.contentY = position
                                                   * bookGrid.contentHeight + bookGrid.originY
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: -20
                    anchors.bottomMargin: 16
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

            MEmptyScreenContent {
                id: emptyScreenContent
                visible: internal.libraryIsEmpty
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 32

                onClicked: importFilesDialog.open()
            }

            MNoBookSatisfiesFilterItem {
                id: noBookSatisfiesFilterItem
                Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: -sidebar.width
                Layout.topMargin: Math.round(root.height / 3) - implicitHeight
                visible: bookGrid.count === 0
                            && LibraryController.bookCount !== 0
                            && LibraryController.libraryModel.isFiltering

                onClearFilters: {
                    toolbar.resetFilters()
                    toolbar.resetTags()
                }
            }

            Item {
                id: bottomHeightFillter
                Layout.fillHeight: true
            }
        }
    }


    /*
     The popup opened when deleting a single book.
     */
    MWarningPopup {
        id: acceptDeletionPopup
        x: Math.round(
               root.width / 2 - implicitWidth / 2 - sidebar.width / 2 - root.horizontalPadding)
        y: Math.round(
               root.height / 2 - implicitHeight / 2 - root.topPadding - 50)
        visible: false
        title: qsTr("Remove Book?")
        message: qsTr("Deleting a book is a permanent action, no one will be\n able to restore it afterwards!")
        leftButtonText: qsTr("Remove from Device")
        rightButtonText: qsTr("Delete Everywhere")
        messageBottomSpacing: 10
        rightButtonRed: true

        onOpenedChanged: if (opened)
                             acceptDeletionPopup.giveFocus()
        onDecisionMade: close()

        onLeftButtonClicked: {
            // Only uninstall the book if it's downloaded
            if (!Globals.selectedBook.downloaded) {
                showAlert("error", qsTr("Uninstalling failed"), qsTr(
                              "Can't uninstall book since it is not downloaded."))
                return
            }

            let success = LibraryController.uninstallBook(
                    Globals.selectedBook.uuid)
            if (success === BookOperationStatus.Success) {
                showAlert("success", qsTr("Uninstalling succeeded"),
                          qsTr("The book was deleted from your device."))
            } else {
                showAlert("error", qsTr("Uninstalling failed"),
                          qsTr("Something went wrong."))
            }
        }

        onRightButtonClicked: {
            let success = internal.deleteBook(
                    Globals.selectedBook.uuid,
                    Globals.selectedBook.projectGutenbergId)

            if (success) {
                showAlert("success", qsTr("Deleting succeeded"),
                          qsTr("The book was successfully deleted."))
            } else {
                showAlert("error", qsTr("Deleting failed"),
                          qsTr("Something went wrong."))
            }
        }
    }


    /*
     The popup opened when deleting multiple books at the same time via e.g.
     the multi selection rightclick popup
     */
    MWarningPopup {
        id: acceptMultiDeletionPopup
        property var selectedBooks: []

        x: Math.round(
               root.width / 2 - implicitWidth / 2 - sidebar.width / 2 - root.horizontalPadding)
        y: Math.round(
               root.height / 2 - implicitHeight / 2 - root.topPadding - 50)
        visible: false
        title: qsTr("Remove Books?")
        message: qsTr("Deleting books is a permanent action, no one will be\n able to restore it afterwards!")
        leftButtonText: qsTr("Remove from Device")
        rightButtonText: qsTr("Delete Everywhere")
        messageBottomSpacing: 10
        rightButtonRed: true

        onOpenedChanged: if (opened)
                             acceptMultiDeletionPopup.giveFocus()
        onDecisionMade: close()

        onLeftButtonClicked: {
            for (var i = 0; i < selectedBooks.length; i++) {
                if (!LibraryController.getBook(selectedBooks[i]).downloaded) {
                    continue
                }

                LibraryController.uninstallBook(selectedBooks[i])
            }

            clearState()
        }

        onRightButtonClicked: {
            for (var i = 0; i < selectedBooks.length; i++) {
                let uuid = selectedBooks[i]
                let book = LibraryController.getBook(uuid)

                internal.deleteBook(uuid, book.projectGutenbergId)
            }

            clearState()
        }

        function clearState() {
            selectedBooks = []
        }
    }


    /*
     The popup opened when removing a single book from it's folder.
     */
    MWarningPopup {
        id: acceptRemoveFromFolderPopup
        x: Math.round(
               root.width / 2 - implicitWidth / 2 - sidebar.width / 2 - root.horizontalPadding)
        y: Math.round(
               root.height / 2 - implicitHeight / 2 - root.topPadding - 50)
        visible: false
        title: qsTr("Remove from Folder?")
        message: qsTr("This action will not delete the original book.")
        leftButtonText: qsTr("Cancel")
        rightButtonText: qsTr("Remove")
        messageBottomSpacing: 10
        rightButtonRed: true
        minButtonWidth: 180

        onOpenedChanged: if (opened)
                             acceptRemoveFromFolderPopup.giveFocus()
        onDecisionMade: close()

        onRightButtonClicked: internal.removeBookFromItsFolder(
                                  Globals.selectedBook.uuid)
    }


    /*
     The popup opened when removing multiple books from their folder at the
     same time via e.g. the multi selection rightclick popup
     */
    MWarningPopup {
        id: acceptMultiRemoveFromFolderPopup
        property var selectedBooks: []

        x: Math.round(
               root.width / 2 - implicitWidth / 2 - sidebar.width / 2 - root.horizontalPadding)
        y: Math.round(
               root.height / 2 - implicitHeight / 2 - root.topPadding - 50)
        visible: false
        title: qsTr("Remove from Folder?")
        message: qsTr("This action will not delete the original books.")
        leftButtonText: qsTr("Cancel")
        rightButtonText: qsTr("Remove")
        messageBottomSpacing: 10
        rightButtonRed: true
        minButtonWidth: 180

        onOpenedChanged: if (opened)
                             acceptMultiRemoveFromFolderPopup.giveFocus()
        onDecisionMade: close()

        onRightButtonClicked: {
            for (var i = 0; i < selectedBooks.length; i++) {
                internal.removeBookFromItsFolder(selectedBooks[i])
            }

            clearState()
        }

        function clearState() {
            selectedBooks = []
        }
    }

    MBookDetailsPopup {
        id: bookDetailsPopup
        x: Math.round(
               root.width / 2 - implicitWidth / 2 - sidebar.width / 2 - root.horizontalPadding)
        y: Math.round(
               root.height / 2 - implicitHeight / 2 - root.topPadding - 30)
    }

    MManageTagsPopup {
        id: manageTagsPopup
        x: Math.round(
               root.width / 2 - implicitWidth / 2 - sidebar.width / 2 - root.horizontalPadding)
        y: Math.round(
               root.height / 2 - implicitHeight / 2 - root.topPadding - 30)
    }

    MMoveToFolderPopup {
        id: moveBookToFolderPopup
        x: Math.round(
               root.width / 2 - implicitWidth / 2 - sidebar.width / 2 - root.horizontalPadding)
        y: Math.round(
               root.height / 2 - implicitHeight / 2 - root.topPadding - 30)
    }

    FolderDialog {
        id: downloadFileDialog
        acceptLabel: qsTr("Save")
        options: FolderDialog.ShowDirsOnly
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)

        onAccepted: LibraryController.saveBookToFile(Globals.selectedBook.uuid,
                                                     folder)
    }

    MWarningPopup {
        id: uploadLimitReachedPopup
        x: Math.round(
               root.width / 2 - implicitWidth / 2 - sidebar.width / 2 - root.horizontalPadding)
        y: Math.round(
               root.height / 2 - implicitHeight / 2 - root.topPadding - 50)
        visible: false
        title: qsTr("Limit Reached")
        message: qsTr("You have reached your upload limit.\nDelete unused books to free up space or upgrade.")
        leftButtonText: qsTr("Upgrade")
        rightButtonText: qsTr("Cancel")
        messageBottomSpacing: 16
        minButtonWidth: 180
        onOpenedChanged: if (opened)
                             uploadLimitReachedPopup.giveFocus()
        onDecisionMade: close()

        onLeftButtonClicked: Qt.openUrlExternally(
                                 AppInfoController.website + "/pricing")
    }

    MWarningPopup {
        id: bookAlreadyExistsPopup
        x: Math.round(
               root.width / 2 - implicitWidth / 2 - sidebar.width / 2 - root.horizontalPadding)
        y: Math.round(
               root.height / 2 - implicitHeight / 2 - root.topPadding - 50)
        visible: false
        title: qsTr("Book already exists")
        message: qsTr("It looks like this book already exists in your library:")
                 + "<br>" + "<font color='" + Style.colorBasePurple + "'>"
                 + internal.lastAddedBookPath.split("/").slice(
                     -1)[0] + "</font> <br>" + qsTr(
                     "Are you sure you that want to add it again?\n")
        richText: true
        leftButtonText: qsTr("Add")
        rightButtonText: qsTr("Don't add")
        messageBottomSpacing: 16
        minButtonWidth: 180
        onOpenedChanged: if (opened)
                             bookAlreadyExistsPopup.giveFocus()
        onDecisionMade: {
            close()
            internal.continueAddingBooks()
        }

        onLeftButtonClicked: LibraryController.addBook(
                                 internal.lastAddedBookPath, true)
    }

    MWarningPopup {
        id: unsupportedFilePopup
        x: Math.round(
               root.width / 2 - implicitWidth / 2 - sidebar.width / 2 - root.horizontalPadding)
        y: Math.round(
               root.height / 2 - implicitHeight / 2 - root.topPadding - 50)
        visible: false
        title: qsTr("Unsupported File")
        message: qsTr("Oops! This file is not supported by Librum.")
        leftButtonText: qsTr("Ok")
        messageBottomSpacing: 24
        singleButton: true

        onOpenedChanged: if (opened)
                             giveFocus()

        onDecisionMade: {
            close()
            internal.continueAddingBooks()
        }
    }

    MFeedbackPopup {
        id: feedbackPopup
        x: Math.round(
               root.width / 2 - implicitWidth / 2 - sidebar.width / 2 - root.horizontalPadding)
        y: Math.round(
               root.height / 2 - implicitHeight / 2 - root.topPadding - 50)
        visible: false
    }

    FileDialog {
        id: importFilesDialog
        acceptLabel: qsTr("Import")
        fileMode: FileDialog.FileMode.OpenFiles
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        nameFilters: [qsTr(
                "All files") + " (*)", "PDF " + qsTr("files") + " (*.pdf)", "EPUB " + qsTr(
                "files") + " (*.epub)", "MOBI " + qsTr("files") + " (*.mobi)", "HTML " + qsTr(
                "files") + " (*.html *.htm)", "Text " + qsTr("files") + " (*.txt)"]

        onAccepted: internal.addBooks(files)
    }

    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Control) {
                            toolbar.selectBooksCheckBoxActivated = true
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            toolbar.selectBooksCheckBoxActivated = false
                            event.accepted = true
                        }
                    }

    Keys.onReleased: event => {
                         if (event.key === Qt.Key_Control) {
                             toolbar.selectBooksCheckBoxActivated = false
                             event.accepted = true
                         }
                     }

    QtObject {
        id: internal
        property bool libraryIsEmpty: LibraryController.bookCount === 0
        property int bookWidth: 190
        property int bookHeight: 300
        property int horizontalBookSpacing: 64
        property int verticalBookSpacing: 48
        property var booksCurrentlyAdding: []
        property string lastAddedBookPath: ""
        property bool inFolderMode: LibraryController.libraryModel.folder !== "all"
                                    && LibraryController.libraryModel.folder !== "unsorted"

        function openBookOptionsPopup(item) {
            Globals.selectedBook = LibraryController.getBook(item.uuid)
            Globals.bookTags = Qt.binding(function () {
                return item.tags
            })

            if (Globals.bookSelectionModeEnabled)
                bookMultiSelectOptionsPopup.open()
            else
                bookOptionsPopup.open()
        }

        function openBook() {
            if (bookOptionsPopup.opened)
                bookOptionsPopup.close()
            else if (bookMultiSelectOptionsPopup.opened)
                bookMultiSelectOptionsPopup.close()

            BookController.setUp(Globals.selectedBook.uuid)

            LibraryController.refreshLastOpenedFlag(Globals.selectedBook.uuid)
            loadPage(readingPage)
        }

        // This function adds books to the library. When errors happen in the process,
        // it interrupts the adding and shows a popup. After the popup is closed, the
        // adding is resumed by calling continueAddingBooks().
        function addBooks(container) {
            internal.booksCurrentlyAdding = container
            for (var i = container.length - 1; i >= 0; i--) {
                internal.lastAddedBookPath = container[i]
                let result = LibraryController.addBook(
                        internal.lastAddedBookPath)

                // Remove the already added book
                container.splice(i, 1)

                if (result === BookOperationStatus.OpeningBookFailed) {
                    unsupportedFilePopup.open()
                    return
                }

                if (result === BookOperationStatus.BookAlreadyExists) {
                    bookAlreadyExistsPopup.open()
                    return
                }
            }
        }

        // When an error occurs while adding multiple books, this method is called
        // after the error was dealt with to continue adding the rest of the books.
        function continueAddingBooks() {
            internal.addBooks(internal.booksCurrentlyAdding)
        }

        function deleteBook(uuid, gutenbergId) {
            let status = LibraryController.deleteBook(uuid)
            let success = status === BookOperationStatus.Success
            if (success) {
                FreeBooksController.unmarkBookAsDownloaded(gutenbergId)
            }

            return success
        }

        function removeBookFromItsFolder(uuid) {
            var operationsMap = {}
            operationsMap[LibraryController.MetaProperty.ParentFolderId] = ""

            LibraryController.updateBook(uuid, operationsMap)
        }

        function showFeedbackPopupIfNeeded() {
            var last = new Date(GlobalSettings.lastFeedbackQuery)
            var now = new Date()

            if (internal.addDays(last, 7) <= now) {
                feedbackPopup.open()
                feedbackPopup.giveFocus()
                GlobalSettings.lastFeedbackQuery = now
            }
        }

        function addDays(date, days) {
            var result = new Date(date)
            result.setDate(result.getDate() + days)
            return result
        }

        function addSeconds(date, seconds) {
            const milliseconds = seconds * 1000
            return new Date(date.getTime() + milliseconds)
        }
    }
}

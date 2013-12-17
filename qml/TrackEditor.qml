import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.0

import TrackEditor 1.0

ApplicationWindow {
    id: rootWindow
    readonly property int lineWidth: 0.04 * gridOperator.tileSide
    property alias currentFile: fileDialog.fileUrl
    readonly property string defaultTitle: "Track Editor"

    width: 720
    height: 650
    visible: true
    color: palette.window
    title: {
        if (gridOperator.currentFileName.length == 0)
            return defaultTitle
        else
            return defaultTitle + " - " + gridOperator.currentFileName
    }

    menuBar: MenuBar {
        Menu {
            title: "File"
            MenuItem {
                text: "Open"
                onTriggered: fileDialog.open(false)
                shortcut: "Ctrl+O"
                iconName: "document-open"
            }
            MenuItem {
                text: "Save"
                onTriggered: gridOperator.saveGrid(currentFile)
                enabled: currentFile.toString().length != 0
                iconName: "document-save"
                shortcut: "Ctrl+S"
            }
            MenuItem {
                text: "Save As"
                onTriggered: fileDialog.open(true)
                iconName: "document-save"
                shortcut: "Ctrl+Shift+S"
            }
            MenuSeparator {}
            MenuItem {
                text: "Quit"
                onTriggered: Qt.quit()
                shortcut: "Ctrl+Q"
                iconName: "application-exit"
            }
        }
        Menu {
            title: "Resize Grid"
            MenuItem {
                text: "8x8"
                onTriggered: gridOperator.gridHeight
                             = gridOperator.gridWidth = 8
            }
            MenuItem {
                text: "16x16"
                onTriggered: gridOperator.gridHeight
                             = gridOperator.gridWidth = 16
            }
            MenuItem {
                text: "32x32"
                onTriggered: gridOperator.gridHeight
                             = gridOperator.gridWidth = 32
            }
        }
    }

    FileDialog {
        property bool save

        id: fileDialog
        title: "Please choose a file"
        onAccepted: {
            if (save)
                gridOperator.saveGrid(fileDialog.fileUrl)
            else
                gridOperator.loadGrid(fileDialog.fileUrl)
        }
        selectMultiple: false
        selectExisting: save ? false : true
        selectFolder: false
        nameFilters: "XML Files(*.xml)"

        function open(v) {
            save = v
            visible = true
        }
    }

    SystemPalette { id: palette }

    GridOperator {
        id: gridOperator
        grid: dropAreaLoader
        onGridDimensionChanged: reloadGrid()

        onPlaceTile: {
            var v = grid.childAt(x * tileSide, y * tileSide)
            var tile

            switch (type) {
            case "Tile_Line": tile = lineTile.createObject(v); break
            case "Tile_Start": tile = startTile.createObject(v); break
            case "Tile_Turn": tile = turnTile.createObject(v); break
            case "Tile_Saw": tile = sawTile.createObject(v); break
            case "Tile_Hill": tile = hillTile.createObject(v); break
            case "Tile_Teeth": tile = teethTile.createObject(v); break
            case "Tile_Crossing": tile = crossingTile.createObject(v); break
            }

            tile.rotation = rotation
            v.haveTile = true
        }

        function reloadGrid() {
            dropAreaLoader.active = false
            dropAreaLoader.active = true
        }
    }

    Component {
        id: lineTile
        Tile {
            width: gridOperator.tileSide
            height: gridOperator.tileSide
            onCreateCopy: lineTile.createObject(target)
            objectName: "Tile_Line"

            Rectangle {
                color: "black"
                width: lineWidth
                height: parent.height
                anchors.centerIn: parent
            }
        }
    }

    Component {
        id: startTile
        Tile {
            width: gridOperator.tileSide
            height: gridOperator.tileSide
            onCreateCopy: startTile.createObject(target)
            objectName: "Tile_Start"

            Rectangle {
                color: "black"
                width: lineWidth
                height: parent.height
                anchors.centerIn: parent
            }
            Rectangle {
                color: "black"
                width: 20
                height: lineWidth
                x: parent.width / 2 + 25
                y: parent.height / 2
            }
            Rectangle {
                color: "black"
                width: 20
                height: lineWidth
                x: parent.width / 2 - 45
                y: parent.height / 2
            }
        }
    }

    Component {
        id: turnTile
        Tile {
            width: gridOperator.tileSide
            height: gridOperator.tileSide
            onCreateCopy: turnTile.createObject(target)
            objectName: "Tile_Turn"

            Canvas {
                anchors.fill: parent
                antialiasing: true
                onPaint : {
                    var ctx = getContext('2d')
                    ctx.lineWidth = lineWidth
                    ctx.arc(width, height, width / 2, Math.PI / 2, 0)
                    ctx.stroke()
                }
            }
        }
    }

    Component {
        id: hillTile
        Tile {
            width: gridOperator.tileSide
            height: gridOperator.tileSide
            onCreateCopy: hillTile.createObject(target)
            objectName: "Tile_Hill"

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: palette.dark }
                    GradientStop { position: 0.5; color: palette.light }
                    GradientStop { position: 1.0; color: palette.dark }
                }
            }
            Rectangle {
                color: "black"
                width: lineWidth
                height: parent.height
                anchors.centerIn: parent
            }
        }
    }

    Component {
        id: teethTile
        Tile {
            width: gridOperator.tileSide
            height: gridOperator.tileSide
            onCreateCopy: teethTile.createObject(target)
            objectName: "Tile_Teeth"

            Repeater {
                model: Math.floor(gridOperator.tileSide / lineWidth)
                delegate: Rectangle {
                    y: index * height
                    anchors.margins: 5
                    color: (index % 2 == 0) ? palette.shadow : "white"
                    width: parent.width
                    height: lineWidth
                }
            }

            Rectangle {
                color: "black"
                width: lineWidth
                height: parent.height
                anchors.centerIn: parent
            }
        }
    }

    Component {
        id: sawTile
        Tile {
            width: gridOperator.tileSide
            height: gridOperator.tileSide
            onCreateCopy: sawTile.createObject(target)
            objectName: "Tile_Saw"

            Canvas {
                anchors.fill: parent
                antialiasing: true
                onPaint : {
                    var ctx = getContext('2d')
                    ctx.lineWidth = lineWidth
                    ctx.moveTo(width / 2, 0)
                    ctx.bezierCurveTo(width * 0.5, height * 0.2,
                                      width * 0.75, height * 0.25,
                                      width * 0.5, height * 0.5)
                    ctx.bezierCurveTo(width * 0.25, height * 0.75,
                                      width * 0.5, height * 0.8,
                                      width * 0.5, height)
                    ctx.stroke()
                }
            }
        }
    }

    Component {
        id: crossingTile
        Tile {
            width: gridOperator.tileSide
            height: gridOperator.tileSide
            onCreateCopy: crossingTile.createObject(target)
            objectName: "Tile_Crossing"

            Rectangle {
                color: "black"
                width: lineWidth
                height: parent.height
                anchors.centerIn: parent
            }

            Rectangle {
                color: "black"
                height: lineWidth
                width: parent.height
                anchors.centerIn: parent
            }
        }
    }

    GridLayout {
        id: tileDisplay
        objectName: "tileDisplay"
        z: 1
        y: anchors.margins
        columns: 2
        anchors {
            left: parent.left
            margins: 5
        }

        Loader { sourceComponent: lineTile }
        Loader { sourceComponent: startTile }
        Loader { sourceComponent: turnTile }
        Loader { sourceComponent: hillTile }
        Loader { sourceComponent: teethTile }
        Loader { sourceComponent: sawTile }
        Loader { sourceComponent: crossingTile }
    }

    ScrollView {
        width: 600
        height: 650
        anchors {
            right: parent.right
            left: tileDisplay.right
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }

        Rectangle {
            id: tileGrid
            width: gridOperator.gridWidth * gridOperator.tileSide
            height: gridOperator.gridHeight * gridOperator.tileSide
            color: palette.dark

            Component {
                id: dropArea

                DropArea {
                    property bool haveTile: false

                    x: (index % gridOperator.gridWidth) * gridOperator.tileSide
                    y: Math.floor(index / gridOperator.gridWidth)
                       * gridOperator.tileSide
                    width: gridOperator.tileSide
                    height: gridOperator.tileSide

                    onDropped: {
                        if (haveTile) {
                            drop.accept(Qt.IgnoreAction)
                            return
                        }
                        if (drop.source.parent.parent === tileDisplay)
                            drop.accept(Qt.CopyAction)
                        else
                            drop.accept(Qt.MoveAction)
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: palette.highlight
                        visible: parent.containsDrag
                    }
                }
            }

            Component {
                id: dropAreaRepeater
                Repeater {
                    model: (tileGrid.width * tileGrid.height)
                           / (gridOperator.tileSide * gridOperator.tileSide)
                    delegate: dropArea
                    // FIXME: childAt(0,0) for Loader returns this item
                    // unless made invisible
                    visible: false
                }
            }

            Loader {
                id: dropAreaLoader
                sourceComponent: dropAreaRepeater
                active: true
            }
        }
    }
}

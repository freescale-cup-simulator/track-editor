import QtQuick 2.1

Rectangle {
    id: base
    color: "white"
    z: 1

    Drag.active: mouseArea.drag.active
    Drag.hotSpot: Qt.point(width / 2, height / 2)

    signal createCopy(Item target)

    Text {
        x: 0
        y: 0
        z: 2
        text: "↑"
    }

    MouseArea {
        property point dragStartPoint

        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (base.parent.parent.objectName == "tileDisplay")
                return

            if (mouse.button === Qt.LeftButton)
                base.rotation += 90
            else
            {
                base.parent.haveTile = false
                base.destroy()
            }

        }

        drag.target: base
        drag.onActiveChanged: {
            if (drag.active) {
                base.Drag.start()
                dragStartPoint = Qt.point(base.x, base.y)
                return
            }

            if (!base.Drag.target) {
                restore()
                return
            }

            switch (base.Drag.drop()) {
            case Qt.CopyAction:
                createCopy(base.Drag.target)
                base.Drag.target.haveTile = true
                restore()
                break
            case Qt.MoveAction:
                base.parent.haveTile = false
                base.parent = base.Drag.target
                base.parent.haveTile = true
                base.x = 0
                base.y = 0
                break
            case Qt.IgnoreAction:
                restore()
                break
            }
        }

        function restore() {
            base.x = dragStartPoint.x
            base.y = dragStartPoint.y
        }
    }
}

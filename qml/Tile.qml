import QtQuick 2.1

Rectangle {
    id: base
    color: "white"
    z: 1
    border.color: mouseArea.containsMouse ? palette.highlight : "white"
    border.width: 2

    Drag.active: mouseArea.drag.active
    Drag.hotSpot: Qt.point(width / 2, height / 2)

    signal createCopy(Item target)

    Behavior on border.color {
        PropertyAnimation { duration: 300 }
    }

    // animate tile rotation
    Behavior on rotation {
        PropertyAnimation {
            id: rotationAnimation
            duration: 400
            easing.type: Easing.InOutBack
            easing.overshoot: 1
        }
    }

    Text { x: 0; y: 0; z: 2; text: "↑" }

    MouseArea {
        property point dragStartPoint

        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        onClicked: {
            if (base.parent.parent.objectName == "tileDisplay")
                return

            if (mouse.button === Qt.LeftButton && !rotationAnimation.running)
                base.rotation += 90
            else if (mouse.button === Qt.RightButton) {
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

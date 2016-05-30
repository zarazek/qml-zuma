import QtQuick 2.4
import "GameLogic.js" as GameLogic

Rectangle {
    id: scene
    color: "yellow"
    width: 360
    height: width
    property real sceneSize
    sceneSize: Math.min(width, height)
    property real ballSize
    ballSize: sceneSize / 36
    property int numOfBalls
    numOfBalls: 20
    property bool running
    running: true

    Component {
        id: projectileGenerator
        Projectile {}
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onPressed: {
            var projectile = projectileGenerator.createObject(scene,
                                                              { initialCenter: mapFromItem(frog, frog.mouthPositionX, frog.mouthPositionY) });
            GameLogic.projectiles.push(projectile);
        }

        onReleased: {
            var projectile = GameLogic.projectiles.last();
            projectile.shootingAngleInRadians = frog.rotationInRadians;
            projectile.released = true;
        }
    }

    Component {
        id: ballGenerator
        Ball {}
    }

    SequentialAnimation {
        running: scene.running


        PauseAnimation {
            duration: 2000
        }

        SequentialAnimation {
            loops: 3
            ScriptAction {
                script: {
                    var ball = ballGenerator.createObject(scene, { type: 4} );
                    GameLogic.balls.push(ball);
                }
            }
            PauseAnimation {
                duration: 300
            }
        }

        SequentialAnimation {
            loops: numOfBalls

            ScriptAction {
                script: {
                    var ball = ballGenerator.createObject(scene, { });
                    GameLogic.balls.push(ball);
                }
            }
            PauseAnimation {
                duration: 300
            }
        }

        SequentialAnimation {
            loops: 3
            ScriptAction {
                script: {
                    var ball = ballGenerator.createObject(scene, { type: 4} );
                    GameLogic.balls.push(ball);
                }
            }
            PauseAnimation {
                duration: 300
            }
        }
    }

    Canvas {
        anchors.fill: parent
        contextType: "2d"
        Path {
            id: ballsPath
            property real unitX
            unitX: parent.width / 8
            property real unitY
            unitY: parent.height / 8
            startX: unitX
            startY: unitY
            PathQuad {
                id: segment1
                relativeX: 6*ballsPath.unitX
                relativeY: ballsPath.unitY
                relativeControlX: relativeX
                relativeControlY: 0
            }
            PathCubic {
                id: segment2
                relativeX: -6*ballsPath.unitX
                relativeY: 2*ballsPath.unitY
                relativeControl1X: 0
                relativeControl1Y: relativeY
                relativeControl2X: relativeX
                relativeControl2Y: 0
            }
            PathCubic {
                id: segment3
                relativeX: 6*ballsPath.unitX
                relativeY: 2*ballsPath.unitY
                relativeControl1X: 0
                relativeControl1Y: relativeY
                relativeControl2X: relativeX
                relativeControl2Y: 0
            }
            PathQuad {
                id: segment4
                relativeX: -6*ballsPath.unitX
                relativeY: ballsPath.unitY
                relativeControlX: 0
                relativeControlY: relativeY
            }
        }

        onPaint: {
            context.strokeStyle = Qt.black;
            context.path = ballsPath
            context.stroke()
        }
    }

    Image {
        id: frog
        source: "qrc:/frog.png"
        width: scene.sceneSize / 10
        height: width
        property real rotationInRadians
        rotationInRadians: Math.atan2(mouseArea.mouseX - mouseArea.width/2, y + height/2 - mouseArea.mouseY)
        transformOrigin: Item.Center
        rotation: 180.0 * rotationInRadians / Math.PI
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        property real mouthPositionX
        mouthPositionX: 0.5*width
        property real mouthPositionY
        mouthPositionY: 0.2*height
        onRotationChanged: {
            var projectile = GameLogic.projectiles.last();
            if (projectile !== null && ! projectile.released) {
                projectile.initialCenter = projectile.mapFromItem(frog, frog.mouthPositionX, frog.mouthPositionY);
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        Text {
            id: endMsg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.family: "Arial"
            font.pixelSize: 0
        }
        SequentialAnimation {
            id: resultAnim
            running: false
            ParallelAnimation {
                NumberAnimation {
                    target: endMsg
                    property: "font.pixelSize"
                    from: 0
                    to: scene.sceneSize / 2
                    duration: 500
                }
                PropertyAnimation {
                    target: endMsg
                    property: "color"
                    from: "black"
                    to: Qt.rgba(from.r, from.g, from.b, 0)
                    duration: 500
                }
            }
//            ScriptAction {
//                script: Qt.quit();
//            }
        }
    }

    function loose() {
        scene.running = false;
        console.log("LOOSE!");
        endMsg.text = "LOOSE!";
        resultAnim.start()
    }

    function win() {
        scene.running = false;
        console.log("WIN!");
        endMsg.text = "WIN!"
        resultAnim.start();
    }
}

import QtQuick 2.0
import "GameLogic.js" as GameLogic

Item {
    id: projectile
    property int type
    type: Math.floor(Math.random() * 3)
    property bool released
    released: false
    property point initialCenter
    initialCenter: mapFromItem(frog, frog.mouthPositionX, frog.mouthPositionY)
    property real shootingAngleInRadians
    shootingAngleInRadians: 0

    Rectangle {
        id: projectileVisual
        width: scene.ballSize
        height: width
        radius: width/2
        property color initialColor
        initialColor: GameLogic.typeToColor(projectile.type)
        color: initialColor
        property real distance
        distance: 0
        property point centerPt
        centerPt: Qt.point(initialCenter.x + distance*Math.sin(projectile.shootingAngleInRadians),
                           initialCenter.y - distance*Math.cos(projectile.shootingAngleInRadians))
        x: centerPt.x - width/2
        y: centerPt.y - height/2

        onXChanged: GameLogic.balls.findColliding(projectile);
        onYChanged: GameLogic.balls.findColliding(projectile);
    }

    SequentialAnimation {
        id: moveAnimation
        running: released

        NumberAnimation {
            target: projectileVisual
            property: "distance"
            to: 2*Math.sqrt(scene.width*scene.width + scene.height*scene.height)
            duration: 3000
        }

        ScriptAction {
            script: GameLogic.projectiles.remove(projectile);
        }
    }

    SequentialAnimation {
        id: explosionAnimation
        running: false

        ParallelAnimation {
            NumberAnimation {
                target: projectileVisual
                property: "width"
                to: scene.sceneSize/2
                duration: 500
            }
            PropertyAnimation {
                target: projectileVisual
                property: "color"
                from: projectileVisual.initialColor
                to: Qt.rgba(from.r, from.g, from.b, 0.0);
                duration: 500
            }
        }
        ScriptAction {
            script: GameLogic.projectiles.remove(projectile);
        }
    }

    SequentialAnimation {
        id: implosionAnimation
        running: false

        NumberAnimation {
            target: projectileVisual
            property: "width"
            to: 0
            duration: 200
        }
        ScriptAction {
            script: GameLogic.projectiles.remove(projectile);
        }
    }

    function explode() {
        moveAnimation.stop();
        explosionAnimation.start();
    }

    function implode() {
        moveAnimation.stop();
        implosionAnimation.start();
    }
}

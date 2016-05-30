import QtQuick 2.0
import "GameLogic.js" as GameLogic


Item {
    id: ball
    property int type
    type: Math.floor(Math.random() * 3)

    Rectangle {
        id: ballVisual
        width: scene.ballSize
        height: width
        radius: width/2
        color: GameLogic.typeToColor(ball.type)
    }

    SequentialAnimation {
        running: scene.running

        PathAnimation {
            target: ballVisual
            anchorPoint: Qt.point(ballVisual.width/2, ballVisual.height/2)
            path: ballsPath
            easing.type: Easing.Linear // OutQuad
            duration: 60000
        }

        ScriptAction {
           script: {
               if (type !== 4) {
                   scene.loose();
               }
           }
        }
    }
}


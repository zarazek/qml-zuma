.pragma library

function typeToColor(t) {
    switch (t) {
        case 0:
            return "red";
        case 1:
            return "green";
        case 2:
            return "blue";
        default:
            return Qt.rgba(0.0, 0.0, 0.0, 0.0);
    }
}

function center(obj) {
    var child = obj.visibleChildren[0];
    return Qt.point(child.x + child.width/2, child.y + child.height/2);
}

function radius(obj) {
    var child = obj.visibleChildren[0];
    var w = child.width/2;
    var h = child.height/2;
    return Math.max(w, h);
}

function distance(pt1, pt2) {
    var diffX = pt1.x - pt2.x;
    var diffY = pt1.y - pt2.y;
    return Math.sqrt(diffX*diffX + diffY*diffY);
}

var balls = []

balls.findSameTypeRange = function(idx, type) {
    var startIdx = idx;
    while (startIdx > 0 && this[startIdx-1].type === type) {
        --startIdx;
    }
    var endIdx = idx;
    while (endIdx < this.length-1 && this[endIdx+1].type === type) {
        ++endIdx;
    }
    ++endIdx;
    return [startIdx, endIdx];
}

balls.allDestroyed = function() {
    var res = true;
    for (var i = 0; i < this.length; ++i) {
        if (this[i].type !== 4) {
            res = false;
            break;
        }
    }
    return res;
}

balls.findColliding = function(projectile) {
    if (! projectile.released) {
        return;
    }

    var colliding = null;
    var collidingIdx = -1;
    var minDistance = Infinity;
    var pt1 = center(projectile);
    var r1 = radius(projectile)
    for (var i = 0; i < this.length; ++i) {
        var ball = this[i];
        if (ball.type === 4) {
            continue;
        }
        var pt2 = center(ball);
        var r2 = radius(ball);
        var dist = distance(pt1, pt2);
        if (dist < r1 + r2) {
            if (dist < minDistance) {
                colliding = ball;
                collidingIdx = i;
                minDistance = dist;
            }
        }
    }
    if (colliding !== null) {
        var collisionHasEffect = false;
        if (projectile.type === colliding.type) {
            var range = this.findSameTypeRange(collidingIdx, colliding.type);
            var startIdx = range[0];
            var endIdx = range[1];
            console.log(startIdx, endIdx);
            if (endIdx - startIdx >= 3) {
                collisionHasEffect = true;
                for (i = startIdx; i < endIdx; ++i) {
                    this[i].type = 4;
                }
            }
            else if (collidingIdx < this.length - 1 && this[collidingIdx+1].type === 4) {
                this[collidingIdx+1].type = projectile.type;
            }
            else if (collidingIdx > 0 && this[collidingIdx-1].type === 4) {
                this[collidingIdx-1].type = projectile.type;
            }
        }

        if (collisionHasEffect) {
            projectile.explode();
        }
        else {
            projectile.implode();
        }

        if (this.allDestroyed()) {
            projectile.parent.win();
        }
    }
}

balls.remove = function(ball) {
    var idx = this.indexOf(ball);
    if (idx !== -1) {
        this.splice(idx, 1);
        ball.destroy();
    }
}

var projectiles = []

projectiles.last = function() {
    return this.length > 0 ? this[this.length-1] : null;
}

projectiles.remove = function(projectile) {
    var idx = this.indexOf(projectile);
    if (idx !== -1) {
        this.splice(idx, 1);
        projectile.destroy();
    }
}

import QtQuick 
import QtQuick.Controls
import MuseScore 
import Muse.UiComponents 
import Muse.Ui 

MuseScore {
    id: root
    title: "12-TET Geometry"
    description: "Description goes here"
    version: "1.0"
    pluginType: "dialog"
    thumbnailName: "12tet.jpg"
    width: 450
    height: 500

    onRun: {}
    
    property var chromatic: true

    Canvas {
        id: canvas
        width: 410
        height: 410
        anchors.horizontalCenter: parent.horizontalCenter
        y: 20
        property var outRadius: (width - 10) / 2 
        property var innRadius: outRadius - 60
        property var centerRadius: (outRadius + innRadius) / 2
        property var cx: width / 2 // center x 
        property var cy: height / 2 // center y         
        property var angle: 2 * Math.PI / 12  // angle of each slice, 12 total slices  
        property var phase: Math.PI / 12 // phase shift to center the slices

        function drawSlice(index, hovered, selectedNotes, down) {
            
            var ctx = canvas.getContext("2d")
            
            var startAngle = index * angle + phase
            var endAngle = (index + 1) * angle + phase    
            
            ctx.strokeStyle = ui.theme.backgroundPrimaryColor
            ctx.lineWidth = hovered ? 2 : 10
            ctx.fillStyle = !down ? (!selectedNotes ? ui.theme.buttonColor : ui.theme.accentColor) : ui.theme.strokeColor
            
            ctx.beginPath()         
            ctx.arc(cx, cy, outRadius, startAngle, endAngle)
            ctx.lineTo(cx + innRadius * Math.cos(endAngle), cy + innRadius * Math.sin(endAngle))
            ctx.arc(cx, cy, innRadius, endAngle, startAngle, true)   
            ctx.closePath()
            ctx.fill()
            ctx.stroke()
        }

        function drawPolygon(selectedNotes) {
            var ctx = canvas.getContext("2d")
            ctx.strokeStyle = ui.theme.accentColor
            ctx.lineWidth = 4
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            var i = selectedNotes.indexOf(1);
            var px = cx + innRadius * Math.cos(i*angle)
            var py = cy + innRadius * Math.sin(i*angle)
            ctx.moveTo(px, py)
            ctx.beginPath();

            for (var i = 0; i < 12; i++) {
                if (selectedNotes[i] == 1) {
                    px = cx + innRadius * Math.cos((i+1)*angle)
                    py = cy + innRadius * Math.sin((i+1)*angle)
                    ctx.lineTo(px, py)
                } else {}
            }
            var sum = selectedNotes.reduce(function (s, x) {
                return s + x
            }, 0)

            if (sum > 2) {
                ctx.closePath()
            }

            ctx.stroke()
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            property int hoveredIndex: -1 // store the index of the hovered slice
            property int index
            property var down: false
            property var selectedNotes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            property var sum: 0

            onPositionChanged: {
                var ctx = canvas.getContext("2d")                       

                // Get the mouse position relative to the center of the pizza
                var dx = mouseX - canvas.cx
                var dy = mouseY - canvas.cy

                // Get the distance and angle from the center of the pizza
                var distance = Math.sqrt(dx * dx + dy * dy)
                var mouseAngle = Math.atan2(dy, dx)

                // Normalize the mouse angle to [0, 2PI)
                if (mouseAngle < 0) {
                    mouseAngle += 2 * Math.PI
                }

                // Check if the mouse is inside the pizza circle
                if (distance < canvas.outRadius && distance > canvas.innRadius) {
                    // Find the index of the slice that contains the mouse position
                    index = Math.floor ((mouseAngle+canvas.phase) / canvas.angle +11)  %12
                } else {
                    index = -1
                }
                if (index != hoveredIndex) {
                    hoveredIndex = index
                    console.log("hovered index:", mouseArea.hoveredIndex)
                    canvas.requestPaint()
                }
            }
            onPressed: {
                down = true;
                canvas.requestPaint()
                console.log("clickes on", mouseArea.hoveredIndex)
            }
            onReleased: {
                selectedNotes[index] = (selectedNotes[index] + 1) % 2
                down = false
                canvas.requestPaint()          
            }
        }
        onPaint: {
            var ctx = canvas.getContext("2d")
            ctx.clearRect(0, 0, width, height)
            for (var i = 0; i < 12; i++) {
                drawSlice(i, false, mouseArea.selectedNotes[i], false)
            }
            if (mouseArea.hoveredIndex != -1) {
                // Draw only the current slice with hovered state
                drawSlice(mouseArea.hoveredIndex, true, mouseArea.selectedNotes[mouseArea.hoveredIndex], mouseArea.down)
            }
            drawPolygon(mouseArea.selectedNotes)
        }
    }
    Repeater {
        model: ["C", "G", "D", "A", "E", "B", "F#/Gb", "D♭", "A♭", "E♭", "B♭", "F"]

        delegate: Item {
            property var n: chromatic ? (index + 9) % 12 : (index + 3) * 7 % 12            
            x: canvas.x + canvas.width / 2 + Math.cos(n*canvas.angle) * canvas.centerRadius
            y: canvas.y + canvas.height / 2 + Math.sin(n*canvas.angle) * canvas.centerRadius
            StyledTextLabel {
                anchors.centerIn: parent
                text: modelData 
                font: ui.theme.largeBodyBoldFont    
            }
        }
    }    
    
    Row {
        anchors.top: canvas.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: root.horizontalCenter
        spacing: 10
        FlatButton {
            text: chromatic ? "Chromatic" : "Fifths"            
            onClicked: {                
                chromatic = !chromatic;                    
                mouseArea.selectedNotes = mouseArea.selectedNotes.map(function (x, i) {
                    return mouseArea.selectedNotes[i * 7 % 12];
                });
                canvas.requestPaint();
            }
            
        }
        FlatButton {                
            icon: IconCode.ARROW_LEFT
            onClicked: {                
                var lastElement = mouseArea.selectedNotes.shift(); // Remove the last element
                mouseArea.selectedNotes.push(lastElement); // Add it to the beginning
                canvas.requestPaint();
            }
        }
        FlatButton {
            icon: IconCode.ARROW_RIGHT
            onClicked: {
                var lastElement = mouseArea.selectedNotes.pop(); // Remove the last element
                mouseArea.selectedNotes.unshift(lastElement); // Add it to the beginning
                canvas.requestPaint();
            }
        }
        FlatButton {
            text: "Reset"
            onClicked: {
                mouseArea.selectedNotes = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
                canvas.requestPaint();
            }
        }
    }       
}

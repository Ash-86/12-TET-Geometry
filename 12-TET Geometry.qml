// 12-TET Geometry
// Copyright (C) 2025 Ashraf El Droubi [Ash-86]

import QtQuick 
import QtQuick.Controls
import MuseScore 3.0
import Muse.UiComponents 
import Muse.Ui 

MuseScore {
    id: root
    title: "12-TET Geometry"
    description: "Description goes here"
    version: "2.0"
    pluginType: "dialog"
    thumbnailName: "12tet.jpg"
    width: 450
    height: 500

    onRun: {}

    property var modelNotes: ["C", "G", "D", "A", "E", "B", "F#/Gb", "D♭", "A♭", "E♭", "B♭", "F"]
    property var modelPitches: [0, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10, 5]
    property var currentModel: modelNotes
    property var chromatic: true

    property var polygonColors: [ui.theme.accentColor, '#d1a7a7', '#c5c6a7', '#a3abd1', ui.theme.buttonColor] // Colors for each polygon
    property var selectedNotes: [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // Polygon 1
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // Polygon 2
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // Polygon 3
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],  // Polygon 4
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]  // none
    ]
    property var activePoly: 0 // Index of the currently active polygon

    
    //  property var polygons : [
    //     new polygon(ui.theme.accentColor),
    //     new polygon("red"),
    //     new polygon("green"),
    //     new polygon("yellow")
    // ]

    

    // function polygon(color) {        

    //     this.notes = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    //     this.color = color     
    //     this.active = false
        

    //     this.setActive = function() {
    //         // Deactivate the currently active polygon
    //         if (Polygon.active) {
    //             Polygon.active.active = false;
    //         }
    //         // Set this polygon as the active one
    //         Polygon.active = this;
    //         this.active = true;
    //     }

    //     this.toggleNote = function (index) {
    //         this.notes[index] = (this.notes[index] + 1) % 2;
    //     }

    //     this.reset = function() {
    //         this.notes = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    //     }

    //     this.invert = function() {
    //         var inverted = [];
    //         for (var i = 0; i < 12; i++) {
    //             inverted[i] = this.notes[(12 - i) % 12];
    //         }
    //         this.notes = inverted;
    //     }

    //     this.complement = function() {
    //         for (var i = 0; i < 12; i++) {
    //             this.notes[i] = (this.notes[i] + 1) % 2;
    //         }
    //     }

    //     this.transpose = function(steps)  {
    //         var transposed = [];
    //         for (var i = 0; i < 12; i++) {
    //             transposed[i] = this.notes[(i - steps + 12) % 12];
    //         }
    //         this.notes = transposed;
    //     }       


    //     this.draw = function(ctx, cx, cy, innRadius, angle, rotationAngle) {
    //         ctx.strokeStyle = color;
    //         ctx.lineWidth = 4;
    //         ctx.lineCap = "round";
    //         ctx.lineJoin = "round";

    //         var i = this.notes.indexOf(1);
    //         if (i === -1) return; // No points selected, skip drawing

    //         var px = cx + innRadius * Math.cos(i * angle + rotationAngle);
    //         var py = cy + innRadius * Math.sin(i * angle + rotationAngle);
    //         ctx.moveTo(px, py);
    //         ctx.beginPath();

    //         for (var i = 0; i < 12; i++) {
    //             if (this.notes[i] == 1) {
    //                 px = cx + innRadius * Math.cos((i + 1) * angle + rotationAngle);
    //                 py = cy + innRadius * Math.sin((i + 1) * angle + rotationAngle);
    //                 ctx.lineTo(px, py);
    //             }
    //         }
    //         var sum = this.notes.reduce(function (s, x) {
    //             return s + x;
    //         }, 0);

    //         if (sum > 2) {
    //             ctx.closePath();
    //         }

    //         ctx.stroke();
    //     }
    // }


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
        property var rotationAngle: 0.0 // rotation angle for animation

        

        function drawSlice(i) {

            var ctx = canvas.getContext("2d")            
               
            var startAngle = i * angle + phase
            var endAngle = (i + 1) * angle + phase    
            
            ctx.strokeStyle = ui.theme.backgroundPrimaryColor
            ctx.lineWidth = i == mouseArea.hoveredIndex && activePoly !=4 ? 2 : 10
            ctx.fillStyle =  mouseArea.hoveredIndex == i && mouseArea.down ? (activePoly !=4 ? ui.theme.backgroundSecondaryColor : ui.theme.buttonColor) : (selectedNotes[activePoly][i] ? polygonColors[activePoly] : ui.theme.buttonColor)
            
            ctx.beginPath()         
            ctx.arc(cx, cy, outRadius, startAngle, endAngle)
            ctx.lineTo(cx + innRadius * Math.cos(endAngle), cy + innRadius * Math.sin(endAngle))
            ctx.arc(cx, cy, innRadius, endAngle, startAngle, true)   
            ctx.closePath()
            ctx.fill()
            ctx.stroke()            
        }

        function drawPolygon(p) {
            var ctx = canvas.getContext("2d")
            ctx.strokeStyle = polygonColors[p]
            ctx.lineWidth = 4
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            var a = activePoly == 4 || p == activePoly ? 1 : 0// animation factor- fix inactive polygons

            var i = selectedNotes[p].indexOf(1);
            var px = cx + innRadius * Math.cos(i*angle + rotationAngle*a)
            var py = cy + innRadius * Math.sin(i*angle + rotationAngle*a)
            ctx.moveTo(px, py)
            ctx.beginPath();

            for (var i = 0; i < 12; i++) {
                if (selectedNotes[p][i] == 1) {
                    px = cx + innRadius * Math.cos((i + 1)*angle + rotationAngle*a)
                    py = cy + innRadius * Math.sin((i + 1)*angle + rotationAngle*a)
                    ctx.lineTo(px, py)
                }
            }
            var sum = selectedNotes[p].reduce(function (s, x) {
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
            // property var selectedNotes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
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
                if (hoveredIndex == -1) {
                    activePoly = 4
                }
                canvas.requestPaint()
                console.log("clickes on", mouseArea.hoveredIndex)
            }
            onReleased: {
                selectedNotes[activePoly][index] = (selectedNotes[activePoly][index] + 1) % 2
                down = false
                canvas.requestPaint()          
            }
        }
        onPaint: {
            var ctx = canvas.getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            for (var i = 0; i < 12; i++) {                
                drawSlice(i)                              
            }
                
            for (var p = 0; p < 4; p++) {  
                if (visiblePolygons[p] == true) {               
                    drawPolygon(p)
                }
            }
        }
    }

    Repeater {        
        model: currentModel
        delegate: Item {
            property var n: chromatic ? (index + 9) % 12 : (index + 3) * 7 % 12  //+3 compensates for index not starting as C          
            x: canvas.x + canvas.width / 2 + Math.cos(n*canvas.angle) * canvas.centerRadius
            y: canvas.y + canvas.height / 2 + Math.sin(n*canvas.angle) * canvas.centerRadius
            StyledTextLabel {
                anchors.centerIn: parent
                text: modelData 
                font: ui.theme.largeBodyBoldFont    
            }
        }
    } 

    Column{
        spacing: 5
    
        FlatButton {
            id: spelling
            text: "Pitch class"
            isNarrow: true
            onClicked: {
                spelling.text = spelling.text == "Notes" ? "Pitch class" : "Notes"
                currentModel =  currentModel == modelNotes ? modelPitches : modelNotes
            }
        }
        FlatButton {
            text: chromatic ? "Chromatic" : "Fifths"  
            isNarrow: true          
            onClicked: {                
                chromatic = !chromatic; 
                for (var p = 0; p < 4; p++) {                  
                    selectedNotes[p] = selectedNotes[p].map(function (x, i) {
                        return selectedNotes[p][i * 7 % 12];
                    });
                }
                canvas.requestPaint();
            }
        }
    }       

    Column {
        spacing: 5
        anchors.right: root.right
        anchors.top: root.top
        anchors.bottomMargin: 10

        Repeater {
            model: 4
            ButtonGroup { id: polygonBtnGroup; exclusive: true }
            delegate: FlatRadioButton {
                
                ButtonGroup.group: polygonBtnGroup
                text: "G " + (index + 1)                
                width: 40                 
                checked: activePoly == index
                
                checkedColor: polygonColors[index] 
                hoverHitColor: polygonColors[index]

                onClicked: {
                    activePoly = index; 
                    canvas.requestPaint()                                     
                }      
                onDoubleClicked: {
                    visiblePolygons[activePoly] = !visiblePolygons[activePoly]                    
                    canvas.requestPaint()
                }         
            }
        }
    }       

    property var visiblePolygons: [true, true, true, true]
    FlatButton {
        anchors.left: buttonRow.left
        anchors.bottom: buttonRow.top
        anchors.bottomMargin: 10
        isNarrow: true
        text: "Invert"
        accentButton: true
        accentColor: polygonColors[activePoly]
        onClicked: {
            if (activePoly !=4 ) {
                selectedNotes[activePoly] = selectedNotes[activePoly].map(function (x, i) {
                    return selectedNotes[activePoly][(12 - i + 4) % 12] //+2 compensates for index not starting as C
                });
            }
            else {
                for (var p = 0; p < 4; p++) {                  
                    selectedNotes[p] = selectedNotes[p].map(function (x, i) {
                        return selectedNotes[p][(12 - i + 4) % 12] //+2 compensates for index not starting as C
                    });
                }     
            }       
            canvas.requestPaint();
        }        
    }
        
    Row {
        id: buttonRow
        anchors.top: canvas.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: root.horizontalCenter
        spacing: 10
        
        FlatButton{
            text: "Complement"
            accentButton: true
            accentColor: polygonColors[activePoly]
            onClicked: {
                if (activePoly !=4 ) {
                    selectedNotes[activePoly] = selectedNotes[activePoly].map(function (x) {
                        return (x + 1) % 2
                    });

                }
                else {
                    for (var p = 0; p < 4; p++) {                  
                        selectedNotes[p] = selectedNotes[p].map(function (x) {
                            return (x + 1) % 2
                        });
                    }  
                }              
                canvas.requestPaint();
            }            
        }              

        FlatButton {                
            icon: IconCode.ARROW_LEFT
            accentButton: true
            accentColor: polygonColors[activePoly]
            onClicked: {                
                rotationTimerLeft.start()                
            }
            Timer {
                id: rotationTimerLeft
                interval: 10    // Delay in milliseconds 
                repeat: true
                running: false  // Start the timer
                onTriggered: {
                    if (canvas.rotationAngle > 0.1 -canvas.angle) {
                        canvas.rotationAngle -= 0.1;
                        canvas.requestPaint();
                    } 
                    else {
                        rotationTimerLeft.stop();
                        canvas.rotationAngle = 0 
                        if (activePoly !=4 ) {
                            var firstElement = selectedNotes[activePoly].shift(); // Remove the first element
                            selectedNotes[activePoly].push(firstElement); // Add it to the end

                        }
                        else {
                            for (var p = 0; p < 4; p++) {   
                                var firstElement = selectedNotes[p].shift(); // Remove the first element
                                selectedNotes[p].push(firstElement); // Add it to the end
                            }
                        }
                        canvas.requestPaint();
                    }         
                }
            }                
        }
        
        FlatButton {
            icon: IconCode.ARROW_RIGHT
            accentButton: true
            accentColor: polygonColors[activePoly]
            onClicked: {                
                rotationTimerRight.start()                
            }
            Timer {
                id: rotationTimerRight
                interval: 10    // Delay in milliseconds 
                repeat: true
                running: false  // Start the timer
                onTriggered: {
                    if (canvas.rotationAngle < canvas.angle - 0.1) {
                        canvas.rotationAngle += 0.1;
                        canvas.requestPaint();
                    } 
                    else {
                        rotationTimerRight.stop();
                        canvas.rotationAngle = 0 
                        if (activePoly !=4 ) {
                            var lastElement = selectedNotes[activePoly].pop(); // Remove the last element
                            selectedNotes[activePoly].unshift(lastElement); // Add it to the beginning
                        }
                        else {  
                            for (var p = 0; p < 4; p++) {                  
                                var lastElement = selectedNotes[p].pop(); // Remove the last element
                                selectedNotes[p].unshift(lastElement); // Add it to the beginning
                            }
                        }
                        
                        canvas.requestPaint();
                    }         
                }
            }  
        }        

        FlatButton {
            text: "Reset"
            accentButton: true
            accentColor: polygonColors[activePoly]
            onClicked: {
                if (activePoly !=4 ) {
                    selectedNotes[activePoly] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                }
                else {
                    selectedNotes = [
                        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // Polygon 1
                        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // Polygon 2
                        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // Polygon 3
                        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],  // Polygon 4
                        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]  // none
                    ]
                    activePoly = 0
                }
                canvas.requestPaint();
            }
        }        
    }     

    FlatButton {
        icon: IconCode.INFO
        anchors.left: buttonRow.right 
        anchors.bottom: buttonRow.bottom
        anchors.leftMargin: 10        
        onClicked: dialog.open()
        StyledDialogView {
            id: dialog
            width: 400
            height: 400
            margins : 20
            contentWidth: 300
            
            StyledTextLabel {
                anchors.fill : parent
                anchors.centerIn: parent
                
                text:  qsTr("<h2>12-TET Geometry</h2><br><br>This plugin visualizes the twelve-tone equal temperament (12-TET) system using a circular geometry. Users can interactively select pitch classes to form polygons representing various musical structures. The plugin supports operations such as inversion and complementation of selected pitch classes, as well as transposition through rotation. Users can toggle between chromatic and circle of fifths arrangements, enhancing their understanding of pitch relationships in 12-TET.<br><br> © 2025 Ashraf EL Droubi <br><br> This software is licensed under the <a href=\"%2\">GNU General Public License v3.0</a>   <br><br><a href=\"%1\">GitHub repository</a>").arg("https://github.com/Ash-86/12-TET-Geometry").arg("https://www.gnu.org/licenses/gpl-3.0.html") // qsTr("12-TET Geometry\n\n\n This plugin visualizes the twelve-tone equal temperament (12-TET) system using a circular geometry. Users can interactively select pitch classes to form polygons representing various musical structures. The plugin supports operations such as inversion and complementation of selected pitch classes, as well as transposition through rotation. Users can toggle between chromatic and circle of fifths arrangements, enhancing their understanding of pitch relationships in 12-TET.\n\n © 2025 Ashraf EL Droubi \n\n This software is licensed under the GNU General Public License v3.0. See the LICENSE file or visit https://www.gnu.org/licenses/gpl-3.0.html for details.\n\n   <a href=\"%1\">GitHub repository</a>").arg("https://github.com/Ash-86/12-TET-Geometry")
                
                wrapMode: Text.WordWrap
            }
        }

    } 

    

    // FlatButton { ///MenuButton
    //     anchors.right: buttonRow.left
    //     anchors.bottom: buttonRow.bottom
    //     anchors.rightMargin: 10   
            
        
    //     onClicked: menu.open()
    //     icon: IconCode.MENU_THREE_DOTS
    //     //text: "Triadic Tone-clock steering"
        // StyledMenu {
        //     anchors.right: buttonRow.left
        //     anchors.bottom: buttonRow.bottom
        //     anchors.rightMargin: 10   
                
            
        //     // onClicked: menu.open()
        //     icon: IconCode.MENU_THREE_DOTS
        //     id: menu                
        //     //title: "Triadic Tone-clock steering"
        //     // StyledMenuItem {
        //     //     modelData: ["I: 1-1", "II: 1-2", "III: 1-3", "IV: 1-4", "V: 1-5", "VI: 2-2", "VII: 2-3", "VIII: 2-4", "IX: 2-5", "X: 3-3", "XI: 3-4", "XII: 4-4"]
                
        //     // }
        //     // Repeater{
        //     //     model: ["I: 1-1", "II: 1-2", "III: 1-3", "IV: 1-4", "V: 1-5", "VI: 2-2", "VII: 2-3", "VIII: 2-4", "IX: 2-5", "X: 3-3", "XI: 3-4", "XII: 4-4"]
                
        //     //     delegate: MenuItem{
        //     //         text: modelData
        //     //         property var ipf: [
        //     //             [1, 1], [1,2], [1,3], [1,4], [1,5], [2,2], [2,3], [2,4], [2,5], [3,3], [3,4], [4,4]
        //     //         ] 
        //     //         onTriggered: {
        //     //             var ipfx = Array(12).fill(0)
        //     //             ipfx[0] = 1
        //     //             ipfx[ipf[index][0]] = 1
        //     //             ipfx[ipf[index][0] + ipf[index][1]] = 1                            
        //     //             ipfx = ipfx.slice(4).concat(ipfx.slice(0, 4)) // C starts at 4
        //     //             ipfSteering(ipfx, -6)
        //     //             canvas.requestPaint()
        //     //         }
        //     //     }
        //     // }                    
        // }
    // }

    
        
        Row {
            spacing: 12
            anchors.right: buttonRow.left
            anchors.bottom: buttonRow.bottom
            anchors.rightMargin: 10   

            component SampleMenuButton : FlatButton {
                    
                onClicked: {                    

                    var items = [
                        {id: 0, icon: null, title: "Triadic Tone-clock steering", enabled: false},
                        {id: 1, icon: null, title: "I: 1-1", enabled: true},
                        {id: 2, icon: null, title: "II: 1-2", enabled: true},
                        {id: 3, icon: null, title: "III: 1-3", enabled: true},
                        {id: 4, icon: null, title: "IV: 1-4", enabled: true},
                        {id: 5, icon: null, title: "V: 1-5", enabled: true},
                        {id: 6, icon: null, title: "VI: 2-2", enabled: true},
                        {id: 7, icon: null, title: "VII: 2-3", enabled: true},
                        {id: 8, icon: null, title: "VIII: 2-4", enabled: true},
                        {id: 9, icon: null, title: "IX: 2-5", enabled: true},
                        {id: 10, icon: null, title: "X: 3-3", enabled: true},
                        {id: 11, icon: null, title: "XI: 3-4", enabled: true},
                        {id: 12, icon: null, title: "XII: 4-4", enabled: true}
                    ]
                        //["I: 1-1", "II: 1-2", "III: 1-3", "IV: 1-4", "V: 1-5", "VI: 2-2", "VII: 2-3", "VIII: 2-4", "IX: 2-5", "X: 3-3", "XI: 3-4", "XII: 4-4"]
                       
                    menuLoader.toggleOpened(items)
                }

                StyledMenuLoader {
                    id: menuLoader

                    onHandleMenuItem: function(itemId) {
                        console.log("selected " + itemId)
                        var ipf =[[1, 1], [1,2], [1,3], [1,4], [1,5], [2,2], [2,3], [2,4], [2,5], [3,3], [3,4], [4,4] ] 
                        var ipfx = Array(12).fill(0)
                        ipfx[0] = 1
                        ipfx[ipf[itemId-1][0]] = 1
                        ipfx[ipf[itemId-1][0] + ipf[itemId-1][1]] = 1      
                        if (itemId == 10) {
                            ipfx[9] = 1
                        }                     
                        ipfx = ipfx.slice(4).concat(ipfx.slice(0, 4)) // C starts at 4
                        var rotations = [-6, -6, -2, -2, -3, 6, 6, -1, -6, 1, -6, -6]
                        var invComp = [1, 1, 1, 1, 1, -1, -3, 1, 1, -1, 1, 1]
                        ipfSteering(ipfx, rotations[itemId-1], invComp[itemId-1])
                        activePoly = 4
                        canvas.requestPaint()
                    }                    
                }
            }           

            SampleMenuButton {
                icon: IconCode.MENU_THREE_DOTS
                mouseArea.acceptedButtons: Qt.LeftButton | Qt.RightButton
            }
        }
    

    

    function ipfSteering(ipf, rotation, invComp) {
        var transpose = ipf.slice(rotation).concat(ipf.slice(0, rotation))
        var inverse = ipf.map(function (x, i) {return ipf[(12 - i + 4) % 12]}) //+2 compensates for index not starting as C
        var invTranspose = transpose.map(function (x, i) {return transpose[(12 - i + 4) % 12]}) //+2 compensates for index not starting as C
        selectedNotes = [
            ipf,  
            transpose,
            inverse.slice(invComp).concat(inverse.slice(0, invComp)),    
            invTranspose.slice(invComp).concat(invTranspose.slice(0, invComp)),
            Array(12).fill(0)    
        ]
    }

    
    
        
}

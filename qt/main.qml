/* GStreamer
 *
 * Copyright (C) 2015 Alexandre Moreno <alexmorenocano@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1
import Player 1.0
import org.freedesktop.gstreamer.GLVideoItem 1.0

import "fontawesome.js" as FontAwesome

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    x: 30
    y: 30
    color: "black"
//    title : player.mediaInfo.title

    Player {
        id: player
        objectName: "player"
        volume: 0.5
        onStateChanged: {
            if (state === Player.STOPPED) {
                playbutton.text = FontAwesome.Icon.Play
            }
        }
        onResolutionChanged: {
            if (player.videoAvailable) {
                window.width = resolution.width
                window.height = resolution.height
            }
        }
    }

    GstGLVideoItem {
        id: video
        objectName: "videoItem"
        anchors.centerIn: parent
        width: 640
        height: 480
    }

    FileDialog {
        id: fileDialog
        //nameFilters: [TODO globs from mime types]
        onAccepted: player.source = fileUrl
    }

    Action {
        id: fileOpenAction
        text: "Open"
        onTriggered: fileDialog.open()
    }

    menuBar: MenuBar {
        Menu {
            title: "&File"
            MenuItem { action: fileOpenAction }
            MenuItem { text: "Quit"; onTriggered: Qt.quit() }
        }
    }

    Item {
        anchors.fill: parent
        FontLoader {
            source: "fonts/fontawesome-webfont.ttf"
        }

        Rectangle {
            id : playbar
            color: Qt.rgba(1, 1, 1, 0.7)
            border.width: 1
            border.color: "white"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            width : grid.width + 20
            height: 40//childrenRect.height + 20
            radius: 5

            MouseArea {
                id: mousearea
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    parent.opacity = 1.0
                    hidetimer.start()
                }
            }

            Timer {
                id: hidetimer
                interval: 10000
                onTriggered: {
                    parent.opacity = 0.0
                    stop()
                }
            }

            Grid {
                id: grid
                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.top: parent.top
//                anchors.topMargin: 5

                spacing: 7
                rows: 1
                verticalItemAlignment: Qt.AlignVCenter

                Text {
                    id : openmedia
                    font.pointSize: 17
                    font.family: "FontAwesome"
                    text: FontAwesome.Icon.FolderOpen

                    MouseArea {
                       anchors.fill: parent
                       onPressed: fileDialog.open()
                    }
                }

                Item {
                    width: 17
                    height: 17

                    Text {
                        anchors.centerIn: parent
                        font.pointSize: 17
                        font.family: "FontAwesome"
                        text: FontAwesome.Icon.StepBackward
                    }
                }

                Item {
                    width: 25
                    height: 25

                    Text {
                        anchors.centerIn: parent
                        id : playbutton
                        font.pointSize: 25
                        font.family: "FontAwesome"
                        //font.weight: Font.Light
                        text: FontAwesome.Icon.PlayCircle
                    }

                    MouseArea {
                       id: playArea
                       anchors.fill: parent
                       onPressed: {
                           if (player.state !== Player.PLAYING) {
                               player.play()
                               playbutton.text = FontAwesome.Icon.Pause
                               playbutton.font.pointSize = 17
                           } else {
                               player.pause()
                               playbutton.text = FontAwesome.Icon.PlayCircle
                               playbutton.font.pointSize = 25
                           }
                       }
                    }
                }

                Item {
                    width: 17
                    height: 17

                    Text {
                        anchors.centerIn: parent
                        font.pointSize: 17
                        font.family: "FontAwesome"
                        text: FontAwesome.Icon.StepForward
                    }
                }

                Item {
                    width: 40
                    height: 17
                    Text {
                        id: timelabel
                        anchors.centerIn: parent
                        font.pointSize: 13
                        color: "black"
                        text: {
                            var current = new Date(Math.floor(slider.value / 1e6));
                            current.getMinutes() + ":" + ('0'+current.getSeconds()).slice(-2)
                        }
                    }
                }

                Item {
                    width: 200
                    height: 38
                    Text {
                        anchors.centerIn: parent
                        text: player.mediaInfo.title
                        font.pointSize: 15
                    }
                }



                Item {
                    width: 40
                    height: 17
                    Text {
                        id: durationlabel
                        anchors.centerIn: parent
                        font.pointSize: 13
                        color: "black"
                        text: {
                            var duration = new Date(Math.floor(player.duration / 1e6));
                            duration.getMinutes() + ":" + ('0'+duration.getSeconds()).slice(-2)
                        }
                    }
                }

                Item {
                    width: 17
                    height: 17


                    Text {
                        id : volume
                        anchors.centerIn: parent
                        font.pointSize: 17
                        font.family: "FontAwesome"
                        text: {
                            if (volumeslider.value > volumeslider.maximumValue / 2) {
                                FontAwesome.Icon.VolumeUp
                            } else if (volumeslider.value === 0) {
                                FontAwesome.Icon.VolumeOff
                            } else {
                                FontAwesome.Icon.VolumeDown
                            }
                        }
                    }

                    Rectangle {
                        id : volumebar
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.top
                        //anchors.bottomMargin:3
                        color: "lightgray"
                        width: 17
                        height: 66
                        visible: false
                        radius: 5

                        Slider {
                            id: volumeslider
                            value: player.volume
                            minimumValue: 0.0
                            maximumValue: 1.0
                            stepSize: 0.001
                            anchors.centerIn: parent
                            orientation: Qt.Vertical
                            onPressedChanged: player.volume = value

                            style: SliderStyle {
                                groove: Item {
                                    implicitWidth: 47
                                    implicitHeight: 3
                                    anchors.centerIn: parent                                    

                                    Rectangle {
                                        antialiasing: true
                                        height: parent.height
                                        width: parent.width
                                        color: "gray"
                                        opacity: 0.8
                                        radius: 5

                                        Rectangle {
                                            antialiasing: true
                                            height: parent.height
                                            width: parent.width * control.value / control.maximumValue
                                            color: "red"
                                            radius: 5
                                        }
                                    }
                                }
                                handle: Rectangle {
                                    anchors.centerIn: parent
                                    color: control.pressed ? "white" : "lightgray"
                                    border.color: "gray"
                                    border.width: 1
                                    implicitWidth: 11
                                    implicitHeight: 11
                                    radius: 90
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            volumebar.visible = !volumebar.visible
                        }
                    }

                    MouseArea {
                        anchors.fill: volumebar
                        hoverEnabled: true
                        propagateComposedEvents: true

                        onClicked: mouse.accepted = false;
                        onPressed: mouse.accepted = false;
                        onReleased: mouse.accepted = false;
                        onDoubleClicked: mouse.accepted = false;
                        onPositionChanged: mouse.accepted = false;
                        onPressAndHold: mouse.accepted = false;

                        onExited: {
                            volumebar.visible = false
                        }
                    }

                }

                Text {
                    id: sub
                    font.pointSize: 17
                    font.family: "FontAwesome"
                    text: FontAwesome.Icon.ClosedCaptions
                }

                Text {
                    id : fullscreen
                    font.pointSize: 17
                    font.family: "FontAwesome"
                    text: FontAwesome.Icon.ResizeFull

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (window.visibility === Window.FullScreen) {
                                window.showNormal()
                                fullscreen.text = FontAwesome.Icon.ResizeFull
                            } else {
                                window.showFullScreen()
                                fullscreen.text = FontAwesome.Icon.ResizeSmall
                            }
                        }
                    }
                }
            }

            Item {
                width: playbar.width
                height: 5
                anchors.bottom: playbar.bottom

                Slider {
                    id: slider
                    maximumValue: player.duration
                    value: player.position
                    onPressedChanged: player.seek(value)
                    enabled: player.mediaInfo.isSeekable
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter

                    MouseArea {
                        id: sliderMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true

                        onClicked: mouse.accepted = false;
                        onPressed: mouse.accepted = false;
                        onReleased: mouse.accepted = false;
                        onDoubleClicked: mouse.accepted = false;
                        onPositionChanged: mouse.accepted = false;
                        onPressAndHold: mouse.accepted = false;
                    }

                    Rectangle {
                        id: hoveredcliptime
                        width: 40
                        height: 17
                        color: "lightgray"
                        anchors.verticalCenter: parent.verticalCenter
                        visible: sliderMouseArea.containsMouse
                        x: sliderMouseArea.mouseX

                        Text {
                            font.pointSize: 13
                            color: "black"
                            anchors.centerIn: parent
                            text: {
                                var value = (sliderMouseArea.mouseX - slider.x) * player.duration / (slider.width - slider.x)
                                var date = new Date(Math.floor(value / 1e6));
                                date.getMinutes() + ":" + ('0' + date.getSeconds()).slice(-2)
                            }
                        }
                    }

                    style: SliderStyle {
                        groove: Item {
                            implicitWidth: playbar.width
                            implicitHeight: 5

                            Rectangle {
                                height: parent.height
                                width: parent.width
                                anchors.verticalCenter: parent.verticalCenter
                                color: "gray"
                                opacity: 0.8

                                Rectangle {
                                    antialiasing: true
                                    color: "red"
                                    height: parent.height
                                    width: parent.width * control.value / control.maximumValue
                                }

                                Rectangle {
                                    antialiasing: true
                                    color: "yellow"
                                    height: parent.height
                                    width: parent.width * player.buffering / 100
                                }
                            }
                        }
                        handle: Rectangle {
                            anchors.centerIn: parent
                            color: control.pressed ? "white" : "lightgray"
                            implicitWidth: 4
                            implicitHeight: 5
                        }
                    }
                }
            }

        }
    }
}
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Window {
    id: window
    visible: true
    width: 900
    height: 600
    minimumWidth: 480
    minimumHeight: 400
    title: qsTr("Calculator")
    color: "#1e222b" // Deep dark slate background matching the image

    // State variables for calculator operations
    property string currentInput: "0"
    property double operand1: 0
    property string activeOperator: ""
    property bool startNewNumber: true

    // Math Functions
    function handlePress(op) {
        if (op === "0" || op === "1" || op === "2" || op === "3" || op === "4" ||
            op === "5" || op === "6" || op === "7" || op === "8" || op === "9") {
            if (startNewNumber) {
                currentInput = op
                startNewNumber = false
            } else {
                if (currentInput === "0") {
                    currentInput = op
                } else {
                    currentInput += op
                }
            }
        } else if (op === "dot") {
            if (startNewNumber) {
                currentInput = "0."
                startNewNumber = false
            } else if (currentInput.indexOf(".") === -1) {
                currentInput += "."
            }
        } else if (op === "back") {
            if (startNewNumber) {
                currentInput = "0"
            } else {
                currentInput = currentInput.slice(0, -1)
                if (currentInput === "" || currentInput === "-") {
                    currentInput = "0"
                    startNewNumber = true
                }
            }
        } else if (op === "clear") {
            currentInput = "0"
            operand1 = 0
            activeOperator = ""
            startNewNumber = true
        } else if (op === "recip") {
            var val = parseFloat(currentInput)
            if (val !== 0) {
                var result = 1.0 / val
                currentInput = formatResult(result)
            } else {
                currentInput = "Error"
            }
            startNewNumber = true
        } else if (op === "sqr") {
            var val = parseFloat(currentInput)
            var result = val * val
            currentInput = formatResult(result)
            startNewNumber = true
        } else if (op === "add" || op === "sub" || op === "mul" || op === "div") {
            if (activeOperator !== "" && !startNewNumber) {
                calculate()
            }
            operand1 = parseFloat(currentInput)
            activeOperator = op
            startNewNumber = true
        } else if (op === "eq") {
            calculate()
            activeOperator = ""
            startNewNumber = true
        }
    }

    function calculate() {
        if (activeOperator === "") return
        var val2 = parseFloat(currentInput)
        var result = 0
        if (activeOperator === "add") {
            result = operand1 + val2
        } else if (activeOperator === "sub") {
            result = operand1 - val2
        } else if (activeOperator === "mul") {
            result = operand1 * val2
        } else if (activeOperator === "div") {
            if (val2 !== 0) {
                result = operand1 / val2
            } else {
                currentInput = "Error"
                return
            }
        }
        currentInput = formatResult(result)
    }

    function formatResult(num) {
        if (isNaN(num)) return "Error"
        if (!isFinite(num)) return "Error"
        var str = String(num)
        // Check if length is too long and truncate decimals safely
        if (str.indexOf(".") !== -1 && str.length > 14) {
            return String(Number(num.toFixed(10)))
        }
        return str
    }

    // Main layout
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Display Area
        Rectangle {
            id: displayBox
            Layout.fillWidth: true
            Layout.preferredHeight: window.height * 0.22
            color: "#14171e" // Darker interior background for display
            border.color: "#ffffff"
            border.width: 1
            radius: 4

            Text {
                id: displayText
                anchors.fill: parent
                anchors.rightMargin: 24
                anchors.leftMargin: 24
                text: currentInput
                color: "#ffffff"
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                font.family: "Segoe UI"
                font.bold: false

                // Dynamic font size adjustment based on text length to prevent overflow
                font.pixelSize: {
                    if (text.length > 15) return 32
                    if (text.length > 10) return 48
                    return 64
                }
            }
        }

        // Button Grid Area
        GridLayout {
            id: buttonGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 4
            columnSpacing: 10
            rowSpacing: 10

            // Grid model containing all button configurations
            Repeater {
                model: ListModel {
                    id: buttonsModel
                    // Row 1
                    ListElement { label: "¹/ₓ"; btnType: "func"; opCode: "recip" }
                    ListElement { label: "x²"; btnType: "func"; opCode: "sqr" }
                    ListElement { label: "C"; btnType: "clear"; opCode: "clear" }
                    ListElement { label: "÷"; btnType: "op"; opCode: "div" }

                    // Row 2
                    ListElement { label: "7"; btnType: "num"; opCode: "7" }
                    ListElement { label: "8"; btnType: "num"; opCode: "8" }
                    ListElement { label: "9"; btnType: "num"; opCode: "9" }
                    ListElement { label: "×"; btnType: "op"; opCode: "mul" }

                    // Row 3
                    ListElement { label: "4"; btnType: "num"; opCode: "4" }
                    ListElement { label: "5"; btnType: "num"; opCode: "5" }
                    ListElement { label: "6"; btnType: "num"; opCode: "6" }
                    ListElement { label: "—"; btnType: "op"; opCode: "sub" }

                    // Row 4
                    ListElement { label: "1"; btnType: "num"; opCode: "1" }
                    ListElement { label: "2"; btnType: "num"; opCode: "2" }
                    ListElement { label: "3"; btnType: "num"; opCode: "3" }
                    ListElement { label: "+"; btnType: "op"; opCode: "add" }

                    // Row 5
                    ListElement { label: "0"; btnType: "num"; opCode: "0" }
                    ListElement { label: "."; btnType: "num"; opCode: "dot" }
                    ListElement { label: "⌫"; btnType: "back"; opCode: "back" }
                    ListElement { label: "="; btnType: "eq"; opCode: "eq" }
                }

                delegate: Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        id: btnRect
                        anchors.fill: parent
                        radius: 6

                        // Select color based on button type
                        color: {
                            if (btnType === "eq") {
                                return "#4fc3f7" // Sky blue button
                            } else if (btnType === "clear") {
                                return "#2c343c" // Dark slate-green button
                            } else {
                                return "#2c313d" // Slate grey button
                            }
                        }

                        // Button Label Text
                        Text {
                            text: model.label
                            anchors.centerIn: parent
                            color: btnType === "eq" ? "#1e222b" : "#ffffff"
                            font.pixelSize: 22
                            font.family: "Segoe UI"
                            font.bold: btnType === "eq"
                        }

                        // Interactive Hover & Press Overlay for feedback
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "#ffffff"
                            opacity: btnMouseArea.pressed ? 0.15 : (btnMouseArea.containsMouse ? 0.05 : 0.0)

                            Behavior on opacity {
                               NumberAnimation { duration: 100 }
                            }
                        }

                        MouseArea {
                            id: btnMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                handlePress(model.opCode)
                            }
                        }
                    }
                }
            }
        }
    }
}

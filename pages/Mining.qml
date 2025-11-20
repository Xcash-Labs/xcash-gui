// Copyright (c) 2014-2024, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQml.Models 2.2
import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.3 as Controls
import "../components" as MoneroComponents
import moneroComponents.Wallet 1.0

Rectangle {
    id: root
    color: "transparent"
    property alias miningHeight: mainLayout.height
    property double currentHashRate: 0
    property int threads: idealThreadCount / 2
    property string args: ""
    property string stakingStatus: qsTr("Loading staking status…") + translationManager.emptyString
    property var delegatesList: []    // holds shared delegates for the ListView
    property bool revoteInProgress: false
    property bool sweepInProgress: false

    ColumnLayout {
        id: mainLayout
        Layout.fillWidth: true
        anchors.margins: 20
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 20

        MoneroComponents.WarningBox {
            Layout.bottomMargin: 8
            id: localDaemonWarning

            text: stakingStatus

            visible: persistentSettings.useRemoteNode && !persistentSettings.allowRemoteNodeMining

            onVisibleChanged: {
                if (visible)
                    refreshStakingStatus();
            }
        }

        MoneroComponents.StandardButton {
            id: revoteButton
            text: qsTr("Revote") + translationManager.emptyString

            visible: stakingStatus.length > 0
                    && stakingStatus.indexOf("Vote found:") === 0

            enabled: !revoteInProgress

            onClicked: {
                if (!appWindow.currentWallet) {
                    appWindow.showStatusMessage(
                        qsTr("No wallet is currently open.") + translationManager.emptyString,
                        5
                    );
                    return;
                }

                revoteInProgress = true;
                appWindow.showStatusMessage(
                    qsTr("Submitting revote…") + translationManager.emptyString,
                    5
                );

                // Start short timer so UI can render spinner
                revoteTimer.start();
            }

        }

        MoneroComponents.StandardButton {
            id: sweepButton
            text: qsTr("Sweep") + translationManager.emptyString

            // Only show when a wallet is open (and you can decide if you also want to require a vote)
            visible: appWindow.currentWallet !== null

            // Disable while any operation is in progress
            enabled: !revoteInProgress && !sweepInProgress

            onClicked: {
                if (!appWindow.currentWallet) {
                    appWindow.showStatusMessage(
                        qsTr("No wallet is currently open.") + translationManager.emptyString,
                        5
                    );
                    return;
                }

                // Optional: confirm with the user before sweeping everything
                appWindow.showStatusMessage(
                    qsTr("Sweeping all unlocked funds to your primary address…") + translationManager.emptyString,
                    5
                );

                sweepInProgress = true;
                sweepTimer.start();
            }
        }

        MoneroComponents.WarningBox {
            Layout.bottomMargin: 8
            text: qsTr("Your daemon must be synchronized before you can start staking") + translationManager.emptyString
            visible: !persistentSettings.useRemoteNode && !appWindow.daemonSynced
        }

        MoneroComponents.TextPlain {
            id: soloMainLabel
            text: qsTr("Pick a delegate for your stake:") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
        }

        GridLayout {
            columns: 1
            Layout.fillWidth: true
            rowSpacing: 8

            // Title
            MoneroComponents.Label {
                id: delegatesTitleLabel
                color: MoneroComponents.Style.defaultFontColor
                text: qsTr("Available Delegates") + translationManager.emptyString
                fontSize: 16
            }

            // Delegate list
            ListView {
                id: delegatesView
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                clip: true

                model: delegatesList    // array of non-seed, shared delegates

                delegate: Rectangle {
                    width: delegatesView.width
                    height: 40
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 10

                        // Online status bullet
                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: modelData.online ? "#00c853" : "#b0bec5"   // green if online, grey if not
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Delegate name
                        MoneroComponents.Label {
                            text: modelData.delegateName
                            fontSize: 14
                            color: MoneroComponents.Style.defaultFontColor
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        // Fee %
                        MoneroComponents.Label {
                            text: modelData.fee + "%"
                            fontSize: 12
                            color: MoneroComponents.Style.defaultFontColor
                        }

                        // Votes (XCASH formatted)
                        MoneroComponents.Label {
                            text: formatVotesAtomicToXcash(modelData.votes) + " XCA"
                            fontSize: 12
                            color: MoneroComponents.Style.defaultFontColor
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("Selected delegate:", modelData.delegateName);
                            // later:
                            // root.selectedDelegateName = modelData.delegateName;
                            // root.selectedDelegateVotes = modelData.votes;
                        }
                    }
                }
            }
        }
    }

    // Centered overlay spinner for revote
    Controls.BusyIndicator {
        id: revoteSpinner
        anchors.centerIn: parent
        running: revoteInProgress || sweepInProgress
        visible: revoteInProgress || sweepInProgress
        width: 32
        height: 32
    }

    function refreshStakingStatus() {
        if (!appWindow.currentWallet) {
            // No wallet yet – do nothing, let Connections handler set the text
            return;
        }

        var status = "";

        try {
            // Calls libwalletqt: QString Wallet::voteStatus()
            status = appWindow.currentWallet.voteStatus();
            console.log("DPOPS voteStatus() returned:", status);
        } catch (e) {
            console.log("Error calling voteStatus():", e);
            stakingStatus = qsTr("Failed to load staking status.") + translationManager.emptyString;
            return;
        }

        if (!status || status.length === 0) {
            stakingStatus = qsTr("No staking information available.") + translationManager.emptyString;
        } else {
            stakingStatus = status;
        }
    }

    Connections {
        target: appWindow

        function onCurrentWalletChanged() {
            if (appWindow.currentWallet) {
                stakingStatusTimer.start();
            } else {
                stakingStatus = qsTr("No wallet is currently open.") + translationManager.emptyString;
            }
        }
    }

    Timer {
        id: stakingStatusTimer
        interval: 250      // 0.5 sec delay after wallet change
        repeat: false
        onTriggered: refreshStakingStatus()
    }

    Timer {
        id: revoteTimer
        interval: 50    // 50 ms – just enough to let UI update
        repeat: false
        onTriggered: {
            var result = "";
            try {
                result = appWindow.currentWallet.revote();
                console.log("revote() result:", result);
            } catch (e) {
                console.log("revote() error:", e);
                appWindow.showStatusMessage(
                    qsTr("Revote failed.") + translationManager.emptyString,
                    5
                );
            }

            revoteInProgress = false;

            if (result && result.length > 0) {
                appWindow.showStatusMessage(result, 8);
            } else {
                appWindow.showStatusMessage(
                    qsTr("Revote request sent.") + translationManager.emptyString,
                    5
                );
            }

            refreshStakingStatus();
        }
    }

    Timer {
        id: sweepTimer
        interval: 50    // give UI a frame to show spinner
        repeat: false
        onTriggered: {
            var result = "";

            try {
                result = appWindow.currentWallet.sweepAllToSelf();
            } catch (e) {
                console.log("sweepAllToSelf() error:", e);
                sweepInProgress = false;
                appWindow.showStatusMessage(
                    qsTr("Sweep failed.") + translationManager.emptyString,
                    5
                );
                return; // don't fall through to the code below
            }

            sweepInProgress = false;

            if (result && result.length > 0) {
                appWindow.showStatusMessage(result, 8);
            } else {
                appWindow.showStatusMessage(
                    qsTr("Sweep request sent.") + translationManager.emptyString,
                    5
                );
            }

            // Optional: refresh balances / staking status afterwards
            refreshStakingStatus();
        }
    }

    function fetchDelegates() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://api.xcashseeds.us/v2/xcash/dpops/unauthorized/delegates/registered/");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);

                        // Keep ONLY shared delegates
                        var sharedDelegates = data.filter(function(d) {
                            return d.DelegateType && d.DelegateType.toLowerCase() === "shared";
                        });

                        delegatesList = sharedDelegates;

                        console.log("Loaded", delegatesList.length, "shared delegates");
                    } catch (e) {
                        console.log("Failed to parse delegates JSON:", e);
                    }
                } else {
                    console.log("Delegates API error:", xhr.status);
                }
            }
        };
        xhr.send();
    }

    function formatVotesAtomicToXcash(v) {
        // Adjust ATOMIC_UNITS if XCASH uses a different precision
        var ATOMIC_UNITS = 1000000; // e.g. 10^6 = 6 decimals
        var amount = v / ATOMIC_UNITS;
        return amount.toLocaleString(Qt.locale(), "f", 2); // 2 decimal places
    }

    Component.onCompleted: {
        fetchDelegates();
    }

}
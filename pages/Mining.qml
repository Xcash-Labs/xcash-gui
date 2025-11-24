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
import QtGraphicalEffects 1.0
import FontAwesome 1.0
import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects
import moneroComponents.Wallet 1.0

Rectangle {
    id: root
    color: "transparent"
    property alias miningHeight: mainLayout.height
    property double currentHashRate: 0
    property int threads: idealThreadCount / 2
    property string args: ""
    property string stakingStatus: qsTr("Loading staking status…") + translationManager.emptyString
    property var selectedDelegate: null
    property bool revoteInProgress: false
    property bool sweepInProgress: false
    property bool loadingStakingData: false
    property bool voteInProgress: false
    
    ListModel {
        id: delegatesModel
    }

    function resetDelegatesModelToPlaceholder() {
        delegatesModel.clear();
    }

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

        RowLayout {
            id: revoteRow
            Layout.fillWidth: true
            spacing: 10

            MoneroComponents.StandardButton {
                id: revoteButton
                text: qsTr("Revote") + translationManager.emptyString

                visible: stakingStatus.length > 0
                        && stakingStatus.indexOf("Vote found:") === 0

                enabled: !revoteInProgress

                Layout.alignment: Qt.AlignVCenter

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

                    revoteTimer.start();
                }
            }

            MoneroComponents.TextPlain {
                text: qsTr("Revote all funds for current delegate") + translationManager.emptyString
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MoneroComponents.Style.defaultFontColor
                visible: revoteButton.visible  
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MoneroComponents.StandardButton {
                id: sweepButton
                text: qsTr("Sweep") + translationManager.emptyString

                // Only show when a wallet is open
                visible: appWindow.currentWallet !== null

                // Disable while any operation is in progress
                enabled: !revoteInProgress && !sweepInProgress

                Layout.alignment: Qt.AlignVCenter

                onClicked: {
                    if (!appWindow.currentWallet) {
                        appWindow.showStatusMessage(
                            qsTr("No wallet is currently open.") + translationManager.emptyString,
                            5
                        );
                        return;
                    }

                    appWindow.showStatusMessage(
                        qsTr("Sweeping all unlocked funds to your primary address") + translationManager.emptyString,
                        5
                    );

                    sweepInProgress = true;
                    sweepTimer.start();
                }
            }

            MoneroComponents.TextPlain {
                text: qsTr("Send all unlocked funds back to this wallet. Swept funds will unlock after about 20 blocks (~20 minutes).") + translationManager.emptyString
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MoneroComponents.Style.defaultFontColor
            }
        }

        MoneroComponents.WarningBox {
            Layout.bottomMargin: 8
            text: qsTr("Your daemon must be synchronized before you can start staking") + translationManager.emptyString
            visible: !persistentSettings.useRemoteNode && !appWindow.daemonSynced
        }

        GridLayout {
            columns: 1
            Layout.fillWidth: true
            rowSpacing: 8
            // Delegate selector (drop-down)
            RowLayout {
                Layout.topMargin: 1
                spacing: 10
                MoneroComponents.StandardDropdown {
                    id: delegateDropdown
                    Layout.fillWidth: true
                    Layout.maximumWidth: 420

                    // hook up the model from your JSON parsing
                    dataModel: delegatesModel

                    // label above the box
                    labelText: qsTr("Select the delegate for your vote") + translationManager.emptyString
                    labelFontSize: 14
                    labelFontBold: true

                    // sizing / styling (these map to your StandardDropdown properties)
                    dropdownHeight: 39
                    fontSize: 14        // header text
                    fontItemSize: 14    // items in the popup
                    headerFontBold: false

                    onChanged: {
                        // currentIndex is the alias to columnid.currentIndex inside StandardDropdown
                        if (!dataModel || dataModel.count === 0)
                        {
                            selectedDelegate = null;
                            return;
                        }

                        if (currentIndex < 0 || currentIndex >= dataModel.count)
                        {
                            selectedDelegate = null;
                            return;
                        }

                        var row = dataModel.get(currentIndex);
                        selectedDelegate = row.column1;
                    }

                }
            }
        }

        RowLayout {
            id: voteRow
            Layout.fillWidth: true
            spacing: 10

            MoneroComponents.StandardButton {
                id: voteButton
                text: qsTr("Vote") + translationManager.emptyString

                // Only show when a wallet is open
                visible: appWindow.currentWallet !== null && selectedDelegate !== null

                // Enable only if not busy and a delegate is selected
                enabled: !voteInProgress && selectedDelegate !== null

                Layout.alignment: Qt.AlignVCenter

                onClicked: {
                    if (!appWindow.currentWallet) {
                        appWindow.showStatusMessage(
                            qsTr("No wallet is currently open.") + translationManager.emptyString,
                            5
                        );
                        return;
                    }

                    if (!selectedDelegate) {
                        appWindow.showStatusMessage(
                            qsTr("Please select a delegate before voting.") + translationManager.emptyString,
                            5
                        );
                        return;
                    }

                    voteInProgress = true;
                    appWindow.showStatusMessage(
                        qsTr("Submitting vote…") + translationManager.emptyString,
                        5
                    );

                    voteTimer.start();
                }
            }

            MoneroComponents.TextPlain {
                text: qsTr("Vote all funds for the selected delegate") + translationManager.emptyString
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 13
                color: MoneroComponents.Style.defaultFontColor
                visible: voteButton.visible
            }
        }
    }

    onVisibleChanged: {
        // When user switches to this page and a wallet is open, load + show spinner
        if (visible && appWindow.currentWallet) {
            loadingStakingData = true;
            stakingStatusTimer.start();
        }
    }

    Controls.BusyIndicator {
        id: revoteSpinner
        anchors.centerIn: parent
        width: 32
        height: 32

        running: revoteInProgress || sweepInProgress || loadingStakingData || voteInProgress
        visible: running
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
        } catch (e) {
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
                // Wallet just opened
                if (root.visible) {
                    loadingStakingData = true;
                    stakingStatusTimer.start();
                }
            } else {
                // Wallet closed
                stakingStatus = qsTr("No wallet is currently open.") + translationManager.emptyString;
                resetDelegatesModelToPlaceholder();
                selectedDelegate = null;     // optional, but nice to reset
                loadingStakingData = false;
            }
        }
    }

    Timer {
        id: stakingStatusTimer
        interval: 400      // 0.4 sec delay after wallet change
        repeat: false
        onTriggered: {
            refreshStakingStatus();
            fetchDelegates();
            if (typeof delegateDropdown !== "undefined") {
                delegateDropdown.currentIndex = 0;  // back to first entry
            }
            loadingStakingData = false;
        }
    }

    Timer {
        id: revoteTimer
        interval: 50    // 50 ms – just enough to let UI update
        repeat: false
        onTriggered: {
            var result = "";
            try {
                result = appWindow.currentWallet.revote();
            } catch (e) {
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
            } catch (e) {;
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

            refreshStakingStatus();
        }
    }

    Timer {
        id: voteTimer
        interval: 50    // small delay so UI updates
        repeat: false
        onTriggered: {
            var result = "";

            try {
                // selectedDelegate is your column1 (delegateName) from the dropdown
                var valueToSend = selectedDelegate + "|all";
                result = appWindow.currentWallet.vote(valueToSend);
            } catch (e) {;
                voteInProgress = false;
                appWindow.showStatusMessage(
                    qsTr("Vote failed.") + translationManager.emptyString,
                    5
                );
                return;
            }

            voteInProgress = false;

            if (result && result.length > 0) {
                appWindow.showStatusMessage(result, 8);
            } else {
                appWindow.showStatusMessage(
                    qsTr("Vote request sent.") + translationManager.emptyString,
                    5
                );
            }

            // update status after voting
            refreshStakingStatus();
        }
    }

    function fetchDelegates() {
        if (!appWindow.currentWallet) {
            resetDelegatesModelToPlaceholder();
            selectedDelegate = null;
            return;
        }
        var json = "";
        try {
            json = appWindow.currentWallet.getRegisteredDelegatesJson();
        } catch (e) {
            resetDelegatesModelToPlaceholder();
            selectedDelegate = null;
            return;
        }

        if (!json || json.length === 0) {
            resetDelegatesModelToPlaceholder();
            selectedDelegate = null;
            return;
        }

        var data;
        try {
            data = JSON.parse(json);
        } catch (e) {
            resetDelegatesModelToPlaceholder();
            selectedDelegate = null;
            return;
        }

        if (!data || !data.length) {
            resetDelegatesModelToPlaceholder();
            selectedDelegate = null;
            return;
        }

        // start fresh with placeholder
        resetDelegatesModelToPlaceholder();
        var sharedCount = 0;

        for (var i = 0; i < data.length; i++) {
            var d = data[i];
            if (d.DelegateType && d.DelegateType.toLowerCase() === "shared" && d.online) {
                var votesXCA = formatVotesAtomicToXcash(d.votes);
                delegatesModel.append({
                    column1: d.delegateName,
                    column2: qsTr("%1% fee · %2 XCA votes").arg(d.fee).arg(votesXCA),
                    delegateIndx: sharedCount
                });
                sharedCount++;
            }
        }

        selectedDelegate = null;
        if (typeof delegateDropdown !== "undefined") {
            delegateDropdown.currentIndex = 0;  // back to “Pick delegate”
        }

    }

    function formatVotesAtomicToXcash(v) {
        // Adjust ATOMIC_UNITS if XCASH uses a different precision
        var ATOMIC_UNITS = 1000000; // e.g. 10^6 = 6 decimals
        var amount = v / ATOMIC_UNITS;
        return amount.toLocaleString(Qt.locale(), "f", 2); // 2 decimal places
    }

    Component.onCompleted: {
        resetDelegatesModelToPlaceholder();
    }

}
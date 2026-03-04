.pragma library

function updateFromQrCode(address, payment_id, amount, tx_description, recipient_name, extra_parameters) {
    // Switch to recover from keys
    recoverFromSeedMode = false
    spendKeyLine.text = ""
    viewKeyLine.text = ""
    restoreHeight.text = ""

    if(typeof extra_parameters.secret_view_key != "undefined") {
        viewKeyLine.text = extra_parameters.secret_view_key
    }
    if(typeof extra_parameters.secret_spend_key != "undefined") {
        spendKeyLine.text = extra_parameters.secret_spend_key
    }
    if(typeof extra_parameters.restore_height != "undefined") {
        restoreHeight.text = extra_parameters.restore_height
    }
    addressLine.text = address

    cameraUi.qrcode_decoded.disconnect(updateFromQrCode)

    // Check if keys are correct
    checkNextButton();
}

function switchPage(next) {
    // Android focus workaround
    releaseFocus();

    // save settings for current page;
    if (next && typeof pages[currentPage].onPageClosed !== 'undefined') {
        if (pages[currentPage].onPageClosed(settings) !== true) {
            print ("Can't go to the next page");
            return;
        };

    }
    console.log("switchpage: currentPage: ", currentPage);

    // Update prev/next button positions for mobile/desktop
    prevButton.anchors.verticalCenter = wizard.verticalCenter
    nextButton.anchors.verticalCenter = wizard.verticalCenter

    if (currentPage > 0 || currentPage < pages.length - 1) {
        pages[currentPage].opacity = 0
        var step_value = next ? 1 : -1
        currentPage += step_value
        pages[currentPage].opacity = 1;

        var nextButtonVisible = currentPage > 1 && currentPage < pages.length - 1
        nextButton.visible = nextButtonVisible

        if (typeof pages[currentPage].onPageOpened !== 'undefined') {
            pages[currentPage].onPageOpened(settings,next)
        }
    }
}

function createWalletPath(isIOS, folder_path,account_name){
    // Store releative path on ios.
    if(isIOS)
        folder_path = "";

    return folder_path + "/" + account_name + "/" + account_name
}

function walletPathExists(accountsDir, directory, filename, isIOS, walletManager) {
    if(!filename || filename === "") return false;
    if(!directory || directory === "") return false;

    if (!directory.endsWith("/") && !directory.endsWith("\\"))
        directory += "/"

    if(isIOS)
        var path = accountsDir + filename;
    else
        var path = directory + filename + "/" + filename;

    if (walletManager.walletExists(path))
        return true;
    return false;
}

function unusedWalletName(directory, filename, walletManager) {
    for (var i = 0; i < 100; i++) {
        var walletName = filename + (i > 0 ? "_" + i : "");
        if (!walletManager.walletExists(directory + "/" + walletName + "/" + walletName)) {
            return walletName;
        }
    }

    return filename;
}

function isAscii(str){
    for (var i = 0; i < str.length; i++) {
        if (str.charCodeAt(i) > 127)
            return false;
    }
    return true;
}

function tr(text) {
    return qsTr(text) + translationManager.emptyString
}

function usefulName(path) {
    // arbitrary "short enough" limit
    if (path.length < 32)
        return path
    return path.replace(/.*[\/\\]/, '').replace(/\.keys$/, '')
}

function checkSeed(seed) {
    console.log("Checking seed")
    var wordsArray = seed.split(/\s+/);
    return wordsArray.length === 25 || wordsArray.length === 24
}

function restoreWalletCheckViewSpendAddress(walletmanager, nettype, viewkey, spendkey, addressline){
    var results = [];
    // addressOK
    results[0] = walletmanager.addressValid(addressline, nettype);
    // viewKeyOK
    results[1] = walletmanager.keyValid(viewkey, addressline, true, nettype);
    // spendKeyOK, Spendkey is optional
    results[2] = walletmanager.keyValid(spendkey, addressline, false, nettype);
    return results;
}

// XCash Klassic: estimate height from date with ~1 month buffer
// usage: getApproximateBlockchainHeight("March 18 2026", "Mainnet")
//        getApproximateBlockchainHeight("2026-02-27", "Mainnet")
//        getApproximateBlockchainHeight("20260227", "Mainnet")
//        getApproximateBlockchainHeight("3/3/2026", "Mainnet")
function getApproximateBlockchainHeight(_date, _nettype) {
    // XCash Klassic genesis: 2026-01-10 22:08:29 UTC
    // (seconds since epoch, UTC)
    const mainnetBirthTime = 1768082909;

    // If different later, set these properly:
    const testnetBirthTime = mainnetBirthTime;
    const stagenetBirthTime = mainnetBirthTime;

    const birthTime =
        _nettype === "Testnet" ? testnetBirthTime :
            _nettype === "Stagenet" ? stagenetBirthTime :
                mainnetBirthTime;

    const secondsPerBlock = 60;

    // ---- parse date -> requestedTimeSec (UTC) ----
    const s = String(_date ?? "").trim();
    if (!s) return 0;

    let requestedTimeSec = 0;
    let m;

    // YYYY-MM-DD => UTC midnight
    if ((m = s.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/))) {
        const y = parseInt(m[1], 10);
        const mo = parseInt(m[2], 10);
        const d = parseInt(m[3], 10);
        requestedTimeSec = Math.floor(Date.UTC(y, mo - 1, d) / 1000);
    }
    // YYYYMMDD => UTC midnight
    else if ((m = s.match(/^(\d{4})(\d{2})(\d{2})$/))) {
        const y = parseInt(m[1], 10);
        const mo = parseInt(m[2], 10);
        const d = parseInt(m[3], 10);
        requestedTimeSec = Math.floor(Date.UTC(y, mo - 1, d) / 1000);
    }
    // M/D/YYYY or MM/DD/YYYY => UTC midnight (matches your UI “3/3/2026”)
    else if ((m = s.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/))) {
        const mo = parseInt(m[1], 10);
        const d = parseInt(m[2], 10);
        const y = parseInt(m[3], 10);
        requestedTimeSec = Math.floor(Date.UTC(y, mo - 1, d) / 1000);
    }
    // Fallback: allow "March 18 2026" etc. (locale-dependent)
    else {
        const t = Date.parse(s);
        if (!Number.isFinite(t)) return 0;
        requestedTimeSec = Math.floor(t / 1000);
    }

    // Before chain start
    if (!Number.isFinite(requestedTimeSec) || requestedTimeSec <= birthTime) return 0;

    let approxHeight = Math.floor((requestedTimeSec - birthTime) / secondsPerBlock);

    // 21-day safety buffer earlier
    const blocksPerBuffer = Math.floor((60 * 60 * 24 * 21) / secondsPerBlock); // 30,240 at 60s blocks
    approxHeight = Math.max(0, approxHeight - blocksPerBuffer);

    return approxHeight;
}
/*
 * SYNTAX: decode-logs <log file> <logmap>
 */
const fs = require('fs');
const path = require('path');

const regExp = /\|\[(\d+)/;
const logPath = process.argv[2];
const logmapPath = process.argv[3];

const logmap = require(path.isAbsolute(logmapPath) ? logmapPath : './' + logmapPath);
const rows =  fs.readFileSync(logPath, 'utf8').split("\n");

for (let row of rows) {
    const number = extractLogNumber(row);

    if (number !== null) {
        row = row.replace("|[" + number, '|["' + logmap[number] + '"');
    }
    console.log(row);
}

function extractLogNumber(line) {
    var res = regExp.exec(line);
    if (res) {
        return res[1];
    }
    return null;
}

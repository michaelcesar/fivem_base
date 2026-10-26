'use strict';
// Live RP: unit tests for live_jobs's genuinely pure functions - no natives, no FiveM globals,
// nothing that only exists inside FXServer. Run against the real function bodies (extract.js
// pulls them out of the actual .lua files), so these fail the moment the real logic changes
// behaviour, not just when a hand-copied duplicate happens to be updated too.
//
// Scope is deliberately narrow: most of live_jobs calls GetEntityCoords, exports.qbx_core:*, or
// similar - none of that is testable without a native/framework mock layer this project doesn't
// have. What's here is what's left after that: table lookups and boolean logic with no side
// effects. See docs/operations.md for how to run this (`npm test` from tests/live_jobs).
const path = require('path');
const assert = require('assert');
const { extractFunction } = require('./extract.js');
const { runLua } = require('./lua-run.js');

const SERVER_LUA = path.resolve(__dirname, '../../server-data/resources/[standalone]/live_jobs/server.lua');
const SHOOTINGRANGE_CONFIG_LUA = path.resolve(__dirname, '../../server-data/resources/[standalone]/live_shootingrange/config.lua');

let failures = 0;
let passed = 0;

function test(name, fn) {
    try {
        fn();
        passed += 1;
        console.log(`  ok  ${name}`);
    } catch (err) {
        failures += 1;
        console.log(`FAIL  ${name}`);
        console.log(`      ${err.message}`);
    }
}

function runExtracted(filePath, functionName, callExpr) {
    const source = extractFunction(filePath, functionName);
    return runLua(`${source}\nreturn ${callExpr}`);
}

// --- tableContains ------------------------------------------------------------------
// Used by setHaul to check a hauled vehicle's model against jobConfig.brokenVehicles.

test('tableContains: finds a value present in the list', () => {
    const result = runExtracted(SERVER_LUA, 'tableContains', "tableContains({10, 20, 30}, 20)");
    assert.strictEqual(result, true);
});

test('tableContains: returns false for a value not in the list', () => {
    const result = runExtracted(SERVER_LUA, 'tableContains', "tableContains({10, 20, 30}, 99)");
    assert.strictEqual(result, false);
});

test('tableContains: returns false for an empty list', () => {
    const result = runExtracted(SERVER_LUA, 'tableContains', "tableContains({}, 1)");
    assert.strictEqual(result, false);
});

// --- returnCoordsFor -----------------------------------------------------------------
// Decides where a job's own vehicle is settled: returnPoint if the job has one, depot otherwise.

test('returnCoordsFor: prefers returnPoint when the job has one', () => {
    const result = runExtracted(
        SERVER_LUA, 'returnCoordsFor',
        "returnCoordsFor({ returnPoint = 'the-return-point', depot = 'the-depot' })"
    );
    assert.strictEqual(result, 'the-return-point');
});

test('returnCoordsFor: falls back to depot when there is no returnPoint', () => {
    const result = runExtracted(SERVER_LUA, 'returnCoordsFor', "returnCoordsFor({ depot = 'the-depot' })");
    assert.strictEqual(result, 'the-depot');
});

test('returnCoordsFor: returns nil for a nil jobConfig (mirrors the `jobConfig and ...` guard)', () => {
    const result = runExtracted(SERVER_LUA, 'returnCoordsFor', "returnCoordsFor(nil)");
    assert.strictEqual(result, undefined);
});

// --- isVehicleSettled ----------------------------------------------------------------
// The single predicate ADR-050/051 build the whole vehicle-settlement flow around.

test('isVehicleSettled: true for a route with no slot (ride-along, ADR-024)', () => {
    const result = runExtracted(SERVER_LUA, 'isVehicleSettled', "isVehicleSettled({ slot = nil, vehicleResolved = nil })");
    assert.strictEqual(result, true);
});

test('isVehicleSettled: false for a route with a slot and no resolution yet', () => {
    const result = runExtracted(SERVER_LUA, 'isVehicleSettled', "isVehicleSettled({ slot = 1, vehicleResolved = nil })");
    assert.strictEqual(result, false);
});

test('isVehicleSettled: true once vehicleResolved is exactly true', () => {
    const result = runExtracted(SERVER_LUA, 'isVehicleSettled', "isVehicleSettled({ slot = 1, vehicleResolved = true })");
    assert.strictEqual(result, true);
});

test('isVehicleSettled: false if vehicleResolved is truthy but not exactly `true` (the `== true` matters)', () => {
    const result = runExtracted(SERVER_LUA, 'isVehicleSettled', "isVehicleSettled({ slot = 1, vehicleResolved = 'yes' })");
    assert.strictEqual(result, false);
});

// --- findCourseBy (live_shootingrange/config.lua) -------------------------------------
// Shared search behind CourseConfig.getByLicence/getById (both call this).

test('findCourseBy: finds a course by an arbitrary field', () => {
    const source = extractFunction(SHOOTINGRANGE_CONFIG_LUA, 'findCourseBy');
    const result = runLua(`
        CourseConfig = { courses = { { id = 'pistol', licence = 'weapon' }, { id = 'rifle', licence = 'weaponrifle' } } }
        ${source}
        return findCourseBy('licence', 'weaponrifle')
    `);
    assert.deepStrictEqual(result, { id: 'rifle', licence: 'weaponrifle' });
});

test('findCourseBy: returns nil when nothing matches', () => {
    const source = extractFunction(SHOOTINGRANGE_CONFIG_LUA, 'findCourseBy');
    const result = runLua(`
        CourseConfig = { courses = { { id = 'pistol', licence = 'weapon' } } }
        ${source}
        return findCourseBy('licence', 'doesnotexist')
    `);
    assert.strictEqual(result, undefined);
});

console.log(`\n${passed} passed, ${failures} failed`);
process.exit(failures > 0 ? 1 : 0);

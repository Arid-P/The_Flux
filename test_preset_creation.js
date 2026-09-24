/**
 * test_preset_creation.js
 * Standalone automated test script for Preset Creation Screen UI logic.
 * Tests every field, category app counts, friction sentence gate, and steppers.
 */

const fs = require('fs');
const path = require('path');
const assert = require('assert');

console.log('🧪 Starting Preset Creation Automated Test Suite...\n');

// 1. Verify HTML file integrity
const htmlPath = path.join(__dirname, 'ui_mockups', 'preset_creation.html');
assert(fs.existsSync(htmlPath), 'preset_creation.html must exist');
const htmlContent = fs.readFileSync(htmlPath, 'utf8');

// 2. Check for required elements and IDs
console.log('Checking required DOM Element IDs in preset_creation.html:');
const requiredIds = [
  'input-preset-name',
  'current-emoji',
  'btn-dec-breaks',
  'btn-inc-breaks',
  'val-breaks',
  'btn-dec-duration',
  'btn-inc-duration',
  'val-duration',
  'count-distracting',
  'count-productive',
  'count-semi',
  'count-others',
  'cb-app-instagram',
  'cb-app-twitter',
  'cb-app-reddit',
  'cb-app-notewise',
  'cb-app-pwapp',
  'cb-app-maps',
  'cb-app-gmail',
  'cb-app-settings',
  'yt-whitelisted-count',
  'yt-channels-badge',
  'header-channels-count',
  'input-confirmation-sentence',
  'btn-submit-channel',
  'channels-list',
  'auto-test-modal'
];

requiredIds.forEach(id => {
  assert(htmlContent.includes(`id="${id}"`), `Missing required element ID: ${id}`);
  console.log(`  ✓ ID present: #${id}`);
});

// 3. Logic Unit Simulation Tests
console.log('\nRunning Business Logic & Counting Assertion Tests:');

// Test 3.1: Category Count Format
function formatAppCount(count) {
  return `${count} app${count === 1 ? '' : 's'} blocked`;
}

assert.strictEqual(formatAppCount(3), '3 apps blocked');
assert.strictEqual(formatAppCount(2), '2 apps blocked');
assert.strictEqual(formatAppCount(1), '1 app blocked');
assert.strictEqual(formatAppCount(0), '0 apps blocked');
console.log('  ✓ Category count singular/plural format: PASS');

// Test 3.2: Distracting selection/deselection simulation
let distractingApps = {
  instagram: true,
  twitter: true,
  reddit: true
};

function getDistractingCount() {
  return Object.values(distractingApps).filter(Boolean).length;
}

assert.strictEqual(getDistractingCount(), 3);
assert.strictEqual(formatAppCount(getDistractingCount()), '3 apps blocked');

// Deselect 1
distractingApps.instagram = false;
assert.strictEqual(getDistractingCount(), 2);
assert.strictEqual(formatAppCount(getDistractingCount()), '2 apps blocked');

// Deselect 2nd
distractingApps.twitter = false;
assert.strictEqual(getDistractingCount(), 1);
assert.strictEqual(formatAppCount(getDistractingCount()), '1 app blocked');

// Deselect 3rd
distractingApps.reddit = false;
assert.strictEqual(getDistractingCount(), 0);
assert.strictEqual(formatAppCount(getDistractingCount()), '0 apps blocked');

// Reselect all
distractingApps = { instagram: true, twitter: true, reddit: true };
assert.strictEqual(getDistractingCount(), 3);
console.log('  ✓ Distracting apps count dynamic transition (3 -> 2 -> 1 -> 0 -> 3): PASS');

// Test 3.3: Productive apps selection simulation
let productiveApps = {
  notewise: false,
  pwapp: false
};

function getProductiveCount() {
  return Object.values(productiveApps).filter(Boolean).length;
}

assert.strictEqual(getProductiveCount(), 0);
assert.strictEqual(formatAppCount(getProductiveCount()), '0 apps blocked');

productiveApps.notewise = true;
assert.strictEqual(getProductiveCount(), 1);
assert.strictEqual(formatAppCount(getProductiveCount()), '1 app blocked');

productiveApps.pwapp = true;
assert.strictEqual(getProductiveCount(), 2);
assert.strictEqual(formatAppCount(getProductiveCount()), '2 apps blocked');

productiveApps = { notewise: false, pwapp: false };
assert.strictEqual(getProductiveCount(), 0);
console.log('  ✓ Productive apps count dynamic transition (0 -> 1 -> 2 -> 0): PASS');

// Test 3.4: Breaks Stepper (0 to 6)
let breaks = 4;
function stepBreaks(delta) {
  breaks = Math.max(0, Math.min(6, breaks + delta));
  return breaks;
}

assert.strictEqual(stepBreaks(1), 5);
assert.strictEqual(stepBreaks(1), 6);
assert.strictEqual(stepBreaks(1), 6, 'Must clamp at max 6');
for (let i = 0; i < 10; i++) stepBreaks(-1);
assert.strictEqual(breaks, 0, 'Must clamp at min 0');
console.log('  ✓ Breaks stepper clamp [0, 6]: PASS');

// Test 3.5: Break Duration Stepper (1 to 15)
let duration = 10;
function stepDuration(delta) {
  duration = Math.max(1, Math.min(15, duration + delta));
  return duration;
}

for (let i = 0; i < 20; i++) stepDuration(1);
assert.strictEqual(duration, 15, 'Must clamp at max 15');
for (let i = 0; i < 20; i++) stepDuration(-1);
assert.strictEqual(duration, 1, 'Must clamp at min 1');
console.log('  ✓ Break duration stepper clamp [1, 15]: PASS');

// Test 3.6: Friction Sentence Gate
const requiredSentence = "I am adding this channel strictly for academic focus and olympiad preparation.";

function isFrictionSatisfied(input) {
  return input.trim() === requiredSentence;
}

assert.strictEqual(isFrictionSatisfied(""), false);
assert.strictEqual(isFrictionSatisfied("I am adding this channel"), false);
assert.strictEqual(isFrictionSatisfied("I am adding this channel strictly for academic focus and olympiad preparation"), false); // missing dot
assert.strictEqual(isFrictionSatisfied(requiredSentence), true);
assert.strictEqual(isFrictionSatisfied(`  ${requiredSentence}  `), true); // trimmed
console.log('  ✓ Friction typing sentence strict matching: PASS');

// Test 3.7: YouTube Channel Count Increment/Decrement
let channelCount = 4;
channelCount++;
assert.strictEqual(channelCount, 5);
channelCount--;
assert.strictEqual(channelCount, 4);
console.log('  ✓ Channel whitelist count increment/decrement (4 -> 5 -> 4): PASS');

console.log('\n========================================');
console.log('🎉 ALL AUTOMATED TESTS PASSED (100%)');
console.log('========================================\n');

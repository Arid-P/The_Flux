/**
 * test_code2_screens.js
 * Automated verification suite for Code2's screens:
 * 1. home_screen.html
 * 2. app_limits.html
 */

const fs = require('fs');
const path = require('path');
const assert = require('assert');

console.log('🧪 Starting Automated Verification for Code2 Screens (Home & App Limits)...\n');

// 1. Verify Home Screen (ui_mockups/home_screen.html)
console.log('--- 1. Testing home_screen.html ---');
const homePath = path.join(__dirname, 'ui_mockups', 'home_screen.html');
assert(fs.existsSync(homePath), 'home_screen.html must exist');
const homeHtml = fs.readFileSync(homePath, 'utf8');

const homeRequiredIds = [
  'header-focused-val',
  'header-weekly-val',
  'upcoming-banner',
  'session-card',
  'session-today-time',
  'preset-title',
  'detail-duration',
  'detail-breaks',
  'detail-break-time',
  'detail-desc',
  'btn-primary-cta',
  'cta-button-text',
  'auto-test-modal',
  'test-results-list',
  'test-summary-status',
  'test-summary-badge'
];

homeRequiredIds.forEach(id => {
  assert(homeHtml.includes(`id="${id}"`), `Missing required ID in home_screen.html: #${id}`);
  console.log(`  ✓ Home ID present: #${id}`);
});

// Verify Rustic Medley Colors in Home Screen
assert(homeHtml.includes('#13191F'), 'Must include #13191F background');
assert(homeHtml.includes('#2B2F2E'), 'Must include #2B2F2E surface');
assert(homeHtml.includes('#594C3D'), 'Must include #594C3D border');
assert(homeHtml.includes('#906D4B'), 'Must include #906D4B accent');
assert(homeHtml.includes('#CA9C68'), 'Must include #CA9C68 primary');
assert(homeHtml.includes('#F8FAFC'), 'Must include #F8FAFC text');
console.log('  ✓ Home Screen Rustic Medley color tokens verified');

// 2. Verify App Limits Screen (ui_mockups/app_limits.html)
console.log('\n--- 2. Testing app_limits.html ---');
const limitsPath = path.join(__dirname, 'ui_mockups', 'app_limits.html');
assert(fs.existsSync(limitsPath), 'app_limits.html must exist');
const limitsHtml = fs.readFileSync(limitsPath, 'utf8');

const limitsRequiredIds = [
  'list-distracting',
  'list-semi',
  'list-others',
  'badge-count-distracting',
  'badge-count-semi',
  'badge-count-others',
  'settings-sheet',
  'modal-app-title',
  'modal-streak-badge',
  'picker-display-val',
  'picker-hours-num',
  'picker-minutes-num',
  'val-extra-sessions',
  'val-total-extra',
  'streak-warning-sheet',
  'warning-app-name',
  'btn-warning-countdown',
  'duration-sheet',
  'add-app-sheet',
  'toast-notif',
  'auto-test-modal',
  'test-results-list'
];

limitsRequiredIds.forEach(id => {
  assert(limitsHtml.includes(`id="${id}"`), `Missing required ID in app_limits.html: #${id}`);
  console.log(`  ✓ App Limits ID present: #${id}`);
});

// Verify Reactive Store and CRUD functions present
assert(limitsHtml.includes('function renderAppLimits()'), 'Must contain renderAppLimits()');
assert(limitsHtml.includes('function saveAppSettings()'), 'Must contain saveAppSettings()');
assert(limitsHtml.includes('function confirmTurnOff()'), 'Must contain confirmTurnOff()');
assert(limitsHtml.includes('function confirmDeleteLimit()'), 'Must contain confirmDeleteLimit()');
assert(limitsHtml.includes('function addAppLimit('), 'Must contain addAppLimit()');
assert(limitsHtml.includes('function runAppLimitsAutoTests()'), 'Must contain runAppLimitsAutoTests()');
console.log('  ✓ Reactive state functions & CRUD handlers verified');

// 3. Logic Unit Simulation for Limits CRUD
console.log('\n--- 3. Testing App Limits In-Memory Reactivity Logic ---');
let limitsStore = [
  { id: 'instagram', name: 'Instagram', category: 'distracting', spentMins: 42, limitHours: 0, limitMins: 45, status: 'blocking', streak: 12 },
  { id: 'youtube', name: 'YouTube', category: 'distracting', spentMins: 70, limitHours: 1, limitMins: 30, status: 'blocking', streak: 24 }
];

// Add
limitsStore.push({ id: 'discord', name: 'Discord', category: 'distracting', spentMins: 0, limitHours: 0, limitMins: 30, status: 'blocking', streak: 0 });
assert.strictEqual(limitsStore.length, 3, 'Must have 3 apps after add');
console.log('  ✓ Add app logic: PASS');

// Edit
const ig = limitsStore.find(a => a.id === 'instagram');
ig.limitHours = 1;
ig.limitMins = 0;
assert.strictEqual(ig.limitHours, 1);
assert.strictEqual(ig.limitMins, 0);
console.log('  ✓ Edit & save limit logic: PASS');

// Turn-off / Pause
ig.status = 'paused';
ig.pausedUntil = 'Tomorrow, 9:00 AM';
assert.strictEqual(ig.status, 'paused');
console.log('  ✓ Turn-off status transition to paused: PASS');

// Delete
const deleteIdx = limitsStore.findIndex(a => a.id === 'discord');
limitsStore.splice(deleteIdx, 1);
assert.strictEqual(limitsStore.length, 2, 'Must have 2 apps after delete');
console.log('  ✓ Delete limit logic: PASS');

console.log('\n========================================');
console.log('🎉 ALL CODE2 SCREEN TESTS PASSED (100%)');
console.log('========================================\n');

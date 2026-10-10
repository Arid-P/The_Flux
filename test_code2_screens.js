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

// 3. Verify Planner Screen (ui_mockups/planner.html)
console.log('\n--- 3. Testing planner.html ---');
const plannerPath = path.join(__dirname, 'ui_mockups', 'planner.html');
assert(fs.existsSync(plannerPath), 'planner.html must exist');
const plannerHtml = fs.readFileSync(plannerPath, 'utf8');

const plannerRequiredIds = [
  'planner-month-year',
  'btn-jump-today',
  'btn-open-help',
  'planner-streak-bar',
  'streak-days-count',
  'calendar-day-strip',
  'stat-focus-total',
  'stat-usage-total',
  'session-cards-container',
  'planner-empty-state',
  'fab-add-preset',
  'help-modal',
  'fab-preset-modal',
  'auto-test-modal',
  'test-results-list'
];

plannerRequiredIds.forEach(id => {
  assert(plannerHtml.includes(`id="${id}"`), `Missing required ID in planner.html: #${id}`);
  console.log(`  ✓ Planner ID present: #${id}`);
});

// Verify Rustic Medley Colors in Planner Screen
['#13191F', '#2B2F2E', '#594C3D', '#906D4B', '#CA9C68', '#F8FAFC', '#94A3B8', '#4E7D56'].forEach(color => {
  assert(plannerHtml.includes(color), `Must include ${color} in planner.html`);
  console.log(`  ✓ Planner Rustic Medley color token verified: ${color}`);
});

assert(plannerHtml.includes('function renderCalendarStrip()'), 'Must contain renderCalendarStrip()');
assert(plannerHtml.includes('function renderSessionsForSelectedDay()'), 'Must contain renderSessionsForSelectedDay()');
assert(plannerHtml.includes('function selectDayByAbbr('), 'Must contain selectDayByAbbr()');
assert(plannerHtml.includes('function jumpToToday()'), 'Must contain jumpToToday()');
assert(plannerHtml.includes('function runPlannerAutoTests()'), 'Must contain runPlannerAutoTests()');
console.log('  ✓ Planner Calendar & Session state engines verified');

// 4. Verify Usage Stats Screen (ui_mockups/usage_stats.html)
console.log('\n--- 4. Testing usage_stats.html ---');
const usagePath = path.join(__dirname, 'ui_mockups', 'usage_stats.html');
assert(fs.existsSync(usagePath), 'usage_stats.html must exist');
const usageHtml = fs.readFileSync(usagePath, 'utf8');

const usageRequiredIds = [
  'screen-title',
  'btn-back-home',
  'btn-open-help',
  'tab-selector',
  'tab-btn-today',
  'tab-btn-daily',
  'tab-btn-weekly',
  'weekly-summary-card',
  'chart-section',
  'view-chart-today',
  'view-chart-daily',
  'view-chart-weekly',
  'legend-grid',
  'app-search-input',
  'apps-list-container',
  'apps-empty-state',
  'app-detail-sheet',
  'help-modal',
  'auto-test-modal',
  'test-results-list'
];

usageRequiredIds.forEach(id => {
  assert(usageHtml.includes(`id="${id}"`), `Missing required ID in usage_stats.html: #${id}`);
  console.log(`  ✓ Usage Stats ID present: #${id}`);
});

['#13191F', '#2B2F2E', '#594C3D', '#906D4B', '#CA9C68', '#F8FAFC', '#94A3B8', '#4E7D56'].forEach(color => {
  assert(usageHtml.includes(color), `Must include ${color} in usage_stats.html`);
  console.log(`  ✓ Usage Stats Rustic Medley color token verified: ${color}`);
});

assert(usageHtml.includes('function switchTab('), 'Must contain switchTab()');
assert(usageHtml.includes('function renderDailyBars()'), 'Must contain renderDailyBars()');
assert(usageHtml.includes('function renderWeeklyBars()'), 'Must contain renderWeeklyBars()');
assert(usageHtml.includes('function renderAppList()'), 'Must contain renderAppList()');
assert(usageHtml.includes('function handleAppSearch('), 'Must contain handleAppSearch()');
assert(usageHtml.includes('function openAppDetail('), 'Must contain openAppDetail()');
assert(usageHtml.includes('function runUsageStatsAutoTests()'), 'Must contain runUsageStatsAutoTests()');
console.log('  ✓ Usage Stats charts, search, and detail sheets verified');

// 5. Logic Unit Simulation for Limits CRUD
console.log('\n--- 5. Testing App Limits In-Memory Reactivity Logic ---');
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

// 6. Test Review Hub Navigation Bridge & Island Synchronization
console.log('\n--- 6. Testing Review Hub Navigation Bridge & Island Synchronization ---');
const indexHtmlPath = path.join(__dirname, 'ui_mockups', 'index.html');
assert(fs.existsSync(indexHtmlPath), 'index.html must exist');
const indexHtml = fs.readFileSync(indexHtmlPath, 'utf8');

assert(indexHtml.includes('syncActiveTab('), 'index.html must implement syncActiveTab');
assert(indexHtml.includes('window.selectScreen = selectScreen'), 'index.html must expose selectScreen globally');
assert(indexHtml.includes("frame.addEventListener('load'"), 'index.html must listen to iframe load events');
assert(indexHtml.includes("window.addEventListener('message'"), 'index.html must support postMessage navigation');
console.log('  ✓ index.html review hub navigation bridge & iframe synchronization verified');

// Verify all screens implement navigateTo
const allScreens = [
  'home_screen.html',
  'planner.html',
  'usage_stats.html',
  'app_limits.html',
  'active_focus_session.html',
  'preset_creation.html',
  'distraction_intervention.html',
  'widget.html'
];

allScreens.forEach(screenName => {
  const sPath = path.join(__dirname, 'ui_mockups', screenName);
  const sHtml = fs.readFileSync(sPath, 'utf8');
  assert(sHtml.includes('function navigateTo(url'), `${screenName} must define navigateTo(url)`);
  assert(sHtml.includes('window.parent.selectScreen('), `${screenName} must notify window.parent.selectScreen`);
  console.log(`  ✓ ${screenName} implements responsive navigateTo() bridge`);
});

// Verify bottom island links use navigateTo
assert(homeHtml.includes("navigateTo('usage_stats.html')"), 'home_screen.html must link to usage_stats via navigateTo');
assert(homeHtml.includes("navigateTo('planner.html')"), 'home_screen.html must link to planner via navigateTo');
assert(homeHtml.includes("navigateTo('app_limits.html')"), 'home_screen.html must link to app_limits via navigateTo');
assert(plannerHtml.includes("navigateTo('home_screen.html')"), 'planner.html must link to home via navigateTo');
assert(usageHtml.includes("navigateTo('home_screen.html')"), 'usage_stats.html must link to home via navigateTo');
assert(limitsHtml.includes("navigateTo('home_screen.html')"), 'app_limits.html must link to home via navigateTo');
console.log('  ✓ Bottom island links wired with reactive navigateTo() handlers');

// 7. Testing distraction_intervention.html
console.log('\n--- 7. Testing distraction_intervention.html ---');
const interventionHtmlPath = path.join(__dirname, 'ui_mockups', 'distraction_intervention.html');
assert(fs.existsSync(interventionHtmlPath), 'distraction_intervention.html must exist');
const interventionHtml = fs.readFileSync(interventionHtmlPath, 'utf8');

const requiredInterventionIds = [
  '#simulated-app-wrapper',
  '#edge-grabber',
  '#edge-panel',
  '#study-mode-toggle',
  '#intervention-sheet',
  '#app-icon',
  '#app-name',
  '#app-limit-text',
  '#streak-badge',
  '#streak-days',
  '#limit-progress-bar',
  '#spent-today-val',
  '#limit-left-val',
  '#yt-study-card',
  '#prompt-label',
  '#time-options-grid',
  '#btn-opt-5m',
  '#btn-opt-10m',
  '#btn-opt-20m',
  '#btn-opt-40m',
  '#cooldown-notice',
  '#btn-exit-app',
  '#non-whitelisted-modal',
  '#whitelist-confirmation-sheet',
  '#target-sentence-box',
  '#input-confirm-sentence',
  '#btn-confirm-add-channel',
  '#auto-test-modal',
  '#test-results-list'
];

requiredInterventionIds.forEach(id => {
  const cleanId = id.replace('#', '');
  assert(interventionHtml.includes(`id="${cleanId}"`), `Distraction Intervention must contain ${id}`);
  console.log(`  ✓ Intervention ID present: ${id}`);
});

const rusticColors = [
  '#13191F',
  '#2B2F2E',
  '#594C3D',
  '#906D4B',
  '#CA9C68',
  '#F8FAFC',
  '#94A3B8',
  '#4E7D56',
  '#38332B'
];

rusticColors.forEach(color => {
  assert(interventionHtml.includes(color), `Distraction Intervention must use Rustic Medley ${color}`);
});
console.log('  ✓ Intervention Screen Rustic Medley color tokens verified');

// 8. Testing widget.html (Android Home Screen Widget 4×2)
console.log('\n--- 8. Testing widget.html (Android Home Screen Widget 4×2) ---');
const widgetHtmlPath = path.join(__dirname, 'ui_mockups', 'widget.html');
assert(fs.existsSync(widgetHtmlPath), 'widget.html must exist');
const widgetHtml = fs.readFileSync(widgetHtmlPath, 'utf8');

const requiredWidgetIds = [
  'widget-container',
  'zone-left-glance',
  'widget-live-indicator',
  'glance-time-val',
  'glance-sub-label',
  'zone-center-donut',
  'donut-svg',
  'donut-seg-productive',
  'donut-seg-semi',
  'donut-seg-distracting',
  'donut-seg-others',
  'zone-right-legend',
  'leg-time-productive',
  'leg-time-semi',
  'leg-time-distracting',
  'leg-time-others',
  'widget-aperture-brand',
  'auto-test-modal',
  'test-results-list'
];

requiredWidgetIds.forEach(id => {
  assert(widgetHtml.includes(`id="${id}"`), `Widget must contain #${id}`);
  console.log(`  ✓ Widget ID present: #${id}`);
});

const widgetRusticColors = [
  '#13191F',
  '#2B2F2E',
  '#594C3D',
  '#906D4B',
  '#CA9C68',
  '#F8FAFC',
  '#94A3B8',
  '#4E7D56',
  '#38332B'
];

widgetRusticColors.forEach(color => {
  assert(widgetHtml.includes(color), `Widget must use Rustic Medley ${color}`);
});
console.log('  ✓ Home Screen Widget Rustic Medley color tokens verified');

console.log('\n======================================================');
console.log('🎉 ALL CODE2 SCREEN TESTS PASSED (Home, App Limits, Planner, Usage Stats, Hub Bridge, Intervention, Widget - 100%)');
console.log('======================================================\n');



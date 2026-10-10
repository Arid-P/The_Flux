const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'ui_mockups', 'distraction_intervention.html');
const content = fs.readFileSync(filePath, 'utf8');

console.log('🧪 Testing ui_mockups/distraction_intervention.html against ui_distracted_intervention.md & ff_design_override.md...\n');

let failed = false;

// 1. Required DOM elements
const requiredElements = [
  'id="simulated-app-wrapper"',
  'id="simulated-app-feed"',
  'id="edge-grabber-container"',
  'id="edge-grabber"',
  'id="edge-panel"',
  'id="study-mode-toggle"',
  'id="intervention-sheet"',
  'id="app-icon"',
  'id="app-name"',
  'id="app-limit-text"',
  'id="streak-badge"',
  'id="streak-days"',
  'id="limit-progress-bar"',
  'id="spent-today-val"',
  'id="limit-left-val"',
  'id="yt-study-card"',
  'id="prompt-label"',
  'id="time-options-grid"',
  'id="btn-opt-2m"',
  'id="btn-opt-5m"',
  'id="btn-opt-10m"',
  'id="btn-opt-20m"',
  'id="cooldown-notice"',
  'id="cooldown-timer-text"',
  'id="btn-exit-app"',
  'id="exit-btn-text"',
  'id="active-session-banner"',
  'id="active-window-timer"',
  'id="non-whitelisted-modal"',
  'id="intercepted-channel-name"',
  'id="btn-got-it"',
  'id="btn-add-study-list"',
  'id="whitelist-confirmation-sheet"',
  'id="target-sentence-box"',
  'id="input-confirm-sentence"',
  'id="char-match-status"',
  'id="btn-confirm-add-channel"',
  'id="toast-notif"',
  'id="bottom-island"',
  'id="auto-test-modal"',
  'id="test-results-list"',
  'id="test-summary-status"'
];

console.log('Checking required DOM Element IDs:');
requiredElements.forEach(elem => {
  if (!content.includes(elem)) {
    console.error(`  ❌ Missing DOM element: ${elem}`);
    failed = true;
  } else {
    console.log(`  ✓ Element present: ${elem}`);
  }
});

// 2. Rustic Medley color tokens
console.log('\nChecking Rustic Medley Color Tokens:');
const requiredColors = [
  '#13191F', // Background River Styx
  '#2B2F2E', // Carbon Fibre surface
  '#232726', // Elevated Carbon
  '#594C3D', // Afternoon Tea border
  '#906D4B', // Tanned Wood accent
  '#CA9C68', // Amber Autumn primary
  '#F8FAFC', // Ghost White text
  '#94A3B8', // Slate Grey muted text
  '#4E7D56', // Productive olive green
  '#38332B'  // Distracting charcoal
];

requiredColors.forEach(color => {
  if (!content.includes(color)) {
    console.error(`  ❌ Missing Rustic Medley color: ${color}`);
    failed = true;
  } else {
    console.log(`  ✓ Color token found: ${color}`);
  }
});

// 3. Test Gates in Auto-Test Modal
console.log('\nChecking 10 Automated Test Gates:');
const testGates = [
  'App Switcher & Dynamic Metadata Update',
  'Row 1 App Info & Flame Streak Badge (#streak-badge)',
  'Row 2 & 3 Progress Bar & Spent/Limit Labels',
  'Row 4 YouTube Study Mode Card Visibility (YouTube-exclusive)',
  'Row 5 & 6 2×2 Time Selection Grid (2m, 5m, 10m, 20m)',
  'Row 7 Dynamic Exit Button ("Exit [App Name]")',
  'Post-Duration Cooldown Friction Wait Logic & Disable State',
  'YouTube Study Mode Edge Grabber & Collapsed/Expanded Panel',
  'Non-Whitelisted Video Interception Modal Trigger',
  'Channel Whitelist Confirmation Sentence Exact-Match Validation'
];

testGates.forEach((gate, idx) => {
  if (!content.includes(gate)) {
    console.error(`  ❌ Missing Test Gate ${idx + 1}: ${gate}`);
    failed = true;
  } else {
    console.log(`  ✓ Test Gate ${idx + 1} present: ${gate}`);
  }
});

// 4. Reactive State Functions
console.log('\nChecking Reactive State Engine Functions:');
const requiredFunctions = [
  'switchApp(',
  'selectTimeOption(',
  'startSimulatedSession(',
  'startCooldownWait(',
  'activateStudyModeFromCard(',
  'toggleEdgePanel(',
  'toggleStudyModeState(',
  'triggerNonWhitelistedVideo(',
  'validateConfirmationSentence(',
  'submitWhitelistChannel(',
  'navigateTo('
];

requiredFunctions.forEach(fn => {
  if (!content.includes(fn)) {
    console.error(`  ❌ Missing function: ${fn}`);
    failed = true;
  } else {
    console.log(`  ✓ Function present: ${fn}`);
  }
});

// 5. Whitelist Sentence Pool & Logic Verification
console.log('\nChecking Confirmation Sentence Pool & Logic:');
if (content.includes('confirmationSentencesPool') && content.includes('.toLowerCase() === input.toLowerCase()')) {
  console.log('  ✓ Sentence pool and case-insensitive exact matching logic verified');
} else {
  console.error('  ❌ Sentence pool or matching logic missing');
  failed = true;
}

if (failed) {
  console.error('\n❌ DISTRACTION INTERVENTION TESTS FAILED');
  process.exit(1);
} else {
  console.log('\n================================================================');
  console.log('🎉 ALL DISTRACTION INTERVENTION TESTS PASSED (100%)');
  console.log('================================================================\n');
  process.exit(0);
}

const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'ui_mockups', 'widget.html');
const content = fs.readFileSync(filePath, 'utf8');

console.log('🧪 Testing ui_mockups/widget.html against ui_widget.md & ff_design_override.md...\n');

let failed = false;

// 1. Required DOM Elements
const requiredElements = [
  'id="launcher-canvas"',
  'id="launcher-clock"',
  'id="widget-container"',
  'id="zone-left-glance"',
  'id="widget-live-indicator"',
  'id="glance-time-val"',
  'id="glance-sub-label"',
  'id="zone-center-donut"',
  'id="donut-svg"',
  'id="donut-empty-track"',
  'id="donut-seg-productive"',
  'id="donut-seg-semi"',
  'id="donut-seg-distracting"',
  'id="donut-seg-others"',
  'id="zone-right-legend"',
  'id="leg-time-productive"',
  'id="leg-time-semi"',
  'id="leg-time-distracting"',
  'id="leg-time-others"',
  'id="widget-aperture-brand"',
  'id="bottom-island"',
  'id="auto-test-modal"',
  'id="test-results-list"',
  'id="test-summary-status"'
];

console.log('Checking required DOM Element IDs in widget.html:');
requiredElements.forEach(elem => {
  if (!content.includes(elem)) {
    console.error(`  ❌ Missing DOM element: ${elem}`);
    failed = true;
  } else {
    console.log(`  ✓ Element present: ${elem}`);
  }
});

// 2. Rustic Medley Color Tokens
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
  'Widget 4×2 Container & Corner Radius Verification',
  'Zone 1 Left: Glance Time & Caption Typography',
  'Zone 1 Left: Live Focus Pulsing Indicator (#widget-live-indicator)',
  'Zone 2 Center: 4-Segment Donut Ring Clockwise Order & Gaps',
  'Zone 2 Center: Category Color Mappings (Olive, Brown, Charcoal, Grey)',
  'Zone 3 Right: 4-Row Category Legend Structure',
  'Zone 3 Right: Distracting Dot 1px Border Safeguard',
  'Bottom-Right FF Aperture Emblem Branding (0.4 Opacity)',
  'No-Data / First Launch Empty Ring State ("--")',
  'Multi-Screen Navigation Island Bridge'
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
console.log('\nChecking State Functions:');
const requiredFunctions = [
  'setWidgetState(',
  'toggleLauncherMode(',
  'runWidgetAutoTests(',
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

if (failed) {
  console.error('\n❌ WIDGET SCREEN TESTS FAILED');
  process.exit(1);
} else {
  console.log('\n================================================================');
  console.log('🎉 ALL HOME SCREEN WIDGET TESTS PASSED (100%)');
  console.log('================================================================\n');
  process.exit(0);
}

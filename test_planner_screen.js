const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'ui_mockups', 'planner.html');
const content = fs.readFileSync(filePath, 'utf8');

console.log('Testing ui_mockups/planner.html against ui_planner.md & ff_design_override.md...');

const requiredElements = [
  'id="planner-month-year"',
  'id="btn-jump-today"',
  'id="btn-open-help"',
  'id="planner-streak-bar"',
  'id="streak-days-count"',
  'id="calendar-day-strip"',
  'id="stat-focus-total"',
  'id="stat-usage-total"',
  'id="session-cards-container"',
  'id="planner-empty-state"',
  'id="fab-add-preset"',
  'id="help-modal"',
  'id="fab-preset-modal"',
  'id="auto-test-modal"',
  'id="test-results-list"',
  'id="test-summary-status"',
  'id="test-summary-badge"'
];

let failed = false;

requiredElements.forEach(elem => {
  if (!content.includes(elem)) {
    console.error(`❌ Missing element ID: ${elem}`);
    failed = true;
  } else {
    console.log(`✓ Element found: ${elem}`);
  }
});

// Check Rustic Medley colors
const requiredColors = [
  '#13191F', // River Styx
  '#2B2F2E', // Carbon Fibre
  '#594C3D', // Afternoon Tea
  '#906D4B', // Tanned Wood
  '#CA9C68', // Amber Autumn
  '#F8FAFC', // Ghost White
  '#94A3B8', // Slate Grey
  '#4E7D56', // Olive Green (Productive / Completed)
];

requiredColors.forEach(color => {
  if (!content.includes(color)) {
    console.error(`❌ Missing Rustic Medley color: ${color}`);
    failed = true;
  } else {
    console.log(`✓ Color token found: ${color}`);
  }
});

// Check automated test runner definitions
const testNames = [
  "1. Header & Date Presentation Check",
  "2. Streak Bar & Typography Verification",
  "3. Calendar Strip 7-Day Rendering & 'Today' Pill State",
  "4. Day Switching & Reactive Stats Calculation",
  "5. Completed Session Card Styling (Checkmark & Olive Border)",
  "6. Active / Live Session Styling with Real-Time Ticker",
  "7. FluxDone (FD) Source Badge & ↻ Sync Icon Verification",
  "8. Empty State Presentation on Inactive Days",
  "9. FAB Layout & Preset Scheduling Flow",
  "10. Floating Pill Navigation Bar (Tab 4 Planner Active)"
];

testNames.forEach(tName => {
  if (!content.includes(tName)) {
    console.error(`❌ Missing test gate: ${tName}`);
    failed = true;
  } else {
    console.log(`✓ Test gate found: ${tName}`);
  }
});

if (failed) {
  console.error('\nTests FAILED!');
  process.exit(1);
} else {
  console.log('\n🎉 ALL 17 elements, 8 Rustic Medley color tokens, and 10 test gates verified successfully!');
}

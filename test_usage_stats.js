const fs = require('fs');
const path = require('path');
const assert = require('assert');

const filePath = path.join(__dirname, 'ui_mockups', 'usage_stats.html');
assert(fs.existsSync(filePath), 'usage_stats.html must exist');
const content = fs.readFileSync(filePath, 'utf8');

console.log('🧪 Testing ui_mockups/usage_stats.html against ui_usage_stats.md & ff_design_override.md...');

const requiredElements = [
  'id="screen-title"',
  'id="btn-back-home"',
  'id="btn-open-help"',
  'id="tab-selector"',
  'id="tab-btn-today"',
  'id="tab-btn-daily"',
  'id="tab-btn-weekly"',
  'id="weekly-summary-card"',
  'id="chart-section"',
  'id="view-chart-today"',
  'id="view-chart-daily"',
  'id="view-chart-weekly"',
  'id="legend-grid"',
  'id="app-search-input"',
  'id="apps-list-container"',
  'id="apps-empty-state"',
  'id="app-detail-sheet"',
  'id="help-modal"',
  'id="auto-test-modal"',
  'id="test-results-list"',
  'id="test-summary-status"',
  'id="test-summary-badge"'
];

requiredElements.forEach(elem => {
  assert(content.includes(elem), `Missing required DOM element: ${elem}`);
  console.log(`  ✓ Element present: ${elem}`);
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
  '#4E7D56', // Olive Green (Productive)
];

requiredColors.forEach(color => {
  assert(content.includes(color), `Missing Rustic Medley color: ${color}`);
  console.log(`  ✓ Color token found: ${color}`);
});

// Check test gates
const testNames = [
  "1. Top Bar Elements & Help Modal Verification",
  "2. Tab Selector Transitions (Today | Daily | Weekly)",
  "3. Today Bézier Smooth Area Chart Layers",
  "4. 2×2 Legend Grid with Category Tokens",
  "5. Daily 7-Day Stacked Bar Chart & Selection Logic",
  "6. Weekly 7-Week Multi-Week Chart Rendering",
  "7. Sunday In-App Weekly Summary Card",
  "8. Live Search Bar Dynamic App Filtering",
  "9. App Detail Bottom Sheet with Limit Integration",
  "10. Floating Pill Navigation Bar (Tab 2 Usage Active)"
];

testNames.forEach(tName => {
  assert(content.includes(tName), `Missing test gate: ${tName}`);
  console.log(`  ✓ Test gate found: ${tName}`);
});

// Check required function handlers
['switchTab', 'renderDailyBars', 'renderWeeklyBars', 'renderAppList', 'handleAppSearch', 'openAppDetail', 'runUsageStatsAutoTests'].forEach(fn => {
  assert(content.includes(`function ${fn}`), `Missing function: ${fn}`);
  console.log(`  ✓ Logic function verified: ${fn}()`);
});

console.log('\n======================================================');
console.log('🎉 ALL USAGE STATS SCREEN TESTS PASSED (100%)');
console.log('======================================================\n');

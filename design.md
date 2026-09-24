# FluxDone Design System (Override)

## Core Palette (Rustic Medley)
This palette completely overrides any default AI generated colors (e.g., standard purples/blues). All Tailwind/CSS generation MUST strictly map to these exact hex codes:

*   **Base Background:** `#13191F` (River Styx)
*   **Surface/Cards:** `#2B2F2E` (Carbon Fibre)
*   **Borders/Muted:** `#594C3D` (Afternoon Tea)
*   **Secondary Elements:** `#906D4B` (Tanned Wood)
*   **Primary/Accent/Buttons:** `#CA9C68` (Amber Autumn)

## Rules for the Agent
*   Do not hallucinate colors outside of this palette.
*   Text should be highly legible against `#13191F` (suggest off-white or soft gray).
*   All UI generation must reference these specific hex codes when building HTML/CSS via Stitch.

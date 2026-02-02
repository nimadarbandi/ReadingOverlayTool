# BookmarkOverlay for Mac
macOS always‑on‑top reading line overlay for PDFs. Transparent/colored overlay to track lines while reading.
This tool is a minimal macOS overlay for reading: transparent top, dark bottom, always on top.

## Run

```bash
swift run
```

## Controls

- Toggle edit mode: Shift + Cmd + X
- Drag the edge line to set the divider
- Use the control panel to adjust opacity and color
- Quit from the control panel
- Shift + Cmd + Z to hide/unhide 

## Notes

- The overlay stays on the current desktop/space.
- In edit mode the overlay captures clicks; otherwise it is click-through.

## Demo

https://github.com/user-attachments/assets/244c2743-ea6c-4a68-9520-10171407b975

## System Requirements

- macOS **12 (Monterey)** or newer  
- Intel or Apple Silicon Mac
- No prior programming experience required
---

# Beginner's Guide

Follow these steps **once** to prepare your Mac.

### 1. Install Xcode Command Line Tools (Required)

This installs **Git** and **Swift**, which are needed to run the app.
1. Open **Terminal**  
   - Press `Cmd + Space`, type **Terminal**, press Enter
2. Run:
   ```bash
   xcode-select --install
   ```
3.	Click Install when prompted and wait for it to finish
4. Verify Installation (Optional but Recommended)
```
git --version
swift --version
```
### 2. Download the App Source Code
1.	Choose where you want the project (example: Desktop):
   ```bash
cd ~/Desktop
```
2. Clone the repository
```bash
git clone https://github.com/nimadarbandi/ReadingOverlayTool.git
```bash
3. Enter the project folder and run the app
```bash
cd BookmarkOverlay
swift run
```
4. Use Shift + Cmd + Z to hide/unhide the app when you need.

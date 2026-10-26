# HDR display output

PhotoCraft can present to an HDR window surface so 16- and 32-bit documents show highlights
brighter than white instead of clipping them, the way Photoshop's "Precise Color Management for
HDR Display" does.

## Turning it on

1. Turn HDR on for the screen in the system's display settings (see your platform below).
2. Preferences › Performance › **HDR Output (applies at next launch)**: on.
3. Set **HDR Peak Brightness (nits)** and **HDR SDR White (nits)** to what your display settings
   show. The canvas lets highlights go up to *peak ÷ SDR white* times brighter than white
   (the *headroom*) and rolls brighter values off smoothly instead of clipping them. These two
   apply right away.
4. Restart PhotoCraft. Help › System Info shows `HDR output: on (scRGB, …)`, or why it is off.

`PHOTOCRAFT_HDR=1` (or `0`) turns it on (or off) for one launch, whatever the preference says.

### Linux: KDE Plasma

- Plasma 6 on **Wayland** (not X11). System Settings › Display & Monitor › your screen ›
  **High Dynamic Range** on. The same page has **Peak brightness** and the **SDR brightness**
  slider: put those numbers in PhotoCraft's two HDR preferences.
- PhotoCraft must run as a native Wayland window (Preferences › Performance › Linux Display
  Server: Auto or Wayland, not X11) with the **Vulkan** backend (Graphics Backend: Auto or
  Vulkan).
- A Vulkan driver whose Wayland support offers HDR swapchains (recent Mesa for AMD and Intel,
  a recent NVIDIA driver). Older ones offer only an SDR surface; System Info then says so.

### Windows and macOS

Windows: Settings › System › Display › Use HDR. macOS: an EDR display. Both offer the scRGB
surface PhotoCraft asks for. Only the KDE Plasma path has been the target of this work so far;
the others are untested.

## What it changes

- The window surface is `Rgba16Float` in extended-range linear sRGB (scRGB): `1.0` is SDR white,
  values above it are brighter. The interface itself stays at SDR white.
- The compositor colour-manages scRGB to the display, so the canvas ends at sRGB primaries in
  linear light rather than at a monitor ICC profile (Color Settings' monitor status says
  `hdr`). Wide-gamut colours outside sRGB go through as scRGB's negative values.
- The colour-managed canvas keeps values above 1.0 on the matrix/shaper path (RGB documents
  with matrix/TRC profiles: sRGB, Display P3, Adobe RGB, Rec. 2020, ProPhoto and their linear
  forms, including the PQ and HLG HEIC images PhotoCraft opens as 32-bit linear Rec. 2020).
- View › 32-bit Preview Options' exposure no longer clips what it lifts above white.

## Limits

- Proof Colors, Gamut Warning, CMYK and Lab documents, and profiles with lookup tables use the
  3D LUT display path, which is SDR (clipped at white) in HDR output too.
- 16/32-bit documents larger than the float canvas budget (100 MP) use an 8-bit canvas texture,
  which has no values above white.
- The CPU canvas (Rendering Mode: CPU) is SDR.
- Screenshots of the window (control channel `ui.screenshot`) clip highlights to SDR.
- The window can't read the display's headroom on Linux, so it comes from the two preferences.

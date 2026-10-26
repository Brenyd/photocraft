# PhotoCraft patches to egui-wgpu

Vendored from [storytold/egui](https://github.com/storytold/egui) at
`6d518fc799681571963842f95b55a6b68431b15a` (`crates/egui-wgpu`, MIT OR Apache-2.0; licence files
alongside). Wired in through `[patch]` in the workspace `Cargo.toml`. Changes, all for HDR output:

- `WgpuConfiguration::hdr` (`HdrOutput::Off` by default, `Auto`): when `Auto` and the surface
  offers `ExtendedSrgbLinear` on `Rgba16Float`, `RenderState::create` picks that format and
  colour space (scRGB: linear, `1.0` = SDR reference white, brighter above).
- `RenderState::target_color_space`, passed to `SurfaceConfiguration::color_space` when the
  window surfaces are configured.
- `writes_linear`: egui's shader writes linear light to float targets as it does to sRGB ones
  (`fs_main_linear_framebuffer`), so the UI keeps its SDR look on an HDR surface.
- Screenshots (`capture.rs`) read an `Rgba16Float` surface, encoding it to sRGB with highlights
  clipped.

Everything else is upstream. To move to a newer egui revision, copy `crates/egui-wgpu` from it and
re-apply these changes (each is marked "PhotoCraft HDR patch").

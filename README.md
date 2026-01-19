# PSX Visuals - GD4 Port

This plugin for Godot 4 provides a comprehensive suite of shaders and tools to recreate the iconic aesthetic of the PlayStation 1 (PSX). It includes vertex snapping, affine texture mapping, distance-based fog, and post-processing dithering.

## How the Plugin Works

The plugin achieves its look through several key components:

* **Shader Global Parameters:** The plugin uses Godot's Global Shader Uniforms to manage settings like vertex snap distance, fog, and affine strength across all materials simultaneously.
* **Custom Shaders:** A set of specialized shaders (`psx_opaque`, `psx_transparent`, etc.) handle the heavy lifting of vertex jittering and texture warping.
* **Autoloads:**
  * `PsxVisualsGd4AutoLoad`: Automatically adds a `CanvasLayer` with a post-processing ColorRect to apply dithering to the entire screen.
  * `PsxVisualsGd4AutoApply`: An optional utility that automatically swaps `StandardMaterial3D` on meshes for the PSX-compatible shaders.

## Installation & Setup

1. Copy the `addons/psx_visuals_gd4` folder into your project's `addons` directory.
2. Go to **Project Settings > Plugins** and enable **PSX Visuals - GD4 Port**.
3. Upon activation, the plugin will automatically create the necessary **Shader Globals** in your Project Settings.
4. Go to **Project Settings > Autoload** and enable `PsxVisualsGd4AutoLoad`

## How to Use

### The "Easy Way" (Auto-Apply)

If you want to quickly convert an existing project, ensure both Autoloads are enabled:

1. Go to **Project Settings > Autoload**.
2. Ensure `PsxVisualsGd4AutoApply` is active.
3. This script will automatically detect `GeometryInstance3D` nodes as they enter the scene tree and replace their `StandardMaterial3D` with the PSX default material, while attempting to preserve your original Albedo and Emission textures.

### The Manual Way

Apply the provided materials or create new ones using the PSX shaders:

1. Select a `MeshInstance3D`.
2. Create a new `ShaderMaterial` and apply it either as the **surface material** on the mesh or as a **material override** on the `MeshInstance3D` (do not use material overlay for this).
3. Assign one of the shaders from `addons/psx_visuals_gd4/shaders/`:
   * `psx_opaque.gdshader`: For standard solid objects.
   * `psx_transparent.gdshader`: For objects with transparency.
   * `psx_opaque_double.gdshader` / `psx_transparent_double.gdshader`: For double-sided meshes (disables backface culling).
4. (Optional) Add an extra material pass using your original material so it renders after the PSX shader, allowing you to combine the PSX effects with your existing look.

### Disabling Auto-Apply on Specific Nodes

If you are using the "Easy Way" but want certain objects to keep their original materials, use **Metadata**:

* **To disable a single node:** Add a Metadata entry named `psx_disable` (Boolean) and set it to `true`.
* **To disable a whole branch:** Add a Metadata entry named `psx_disable_children` (Boolean) to a parent node and set it to `true`. This prevents the shader from being applied to any of its descendants.

## Shader Settings Description

You can find these settings under **Project Settings > Shader Globals**.

* **`psx_snap_distance`**: Controls the "vertex jitter." A value of `0.025` is standard; lower values result in smoother movement, while higher values increase the "shaking" effect.
* **`psx_affine_strength`**: Controls texture warping. `1.0` provides full PSX-style warping, while `0.0` is modern perspective-correct mapping.
* **`psx_bit_depth`**: Determines the color depth for the dither effect. Lower values (e.g., `4` or `5`) result in more aggressive banding/dithering.
* **`psx_fog_color`**: The color of the distance fog. The Alpha channel determines the fog's intensity.
* **`psx_fog_near` / `psx_fog_far`**: The start and end distances for the fog gradient.

## License

The original forked repository does not provide an explicit license. However, all changes, porting work for Godot 4, and new code provided in this version are licensed under the **MIT License**.


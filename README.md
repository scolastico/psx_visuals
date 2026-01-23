# PSX Visuals - GD4 Port

[![DEMO IMAGE](https://github.com/scolastico/psx_visuals_gd4/blob/main/.github/demo.png?raw=true)](https://github.com/scolastico/psx_visuals_gd4/blob/main/.github/demo.png?raw=true)

This plugin for Godot 4 provides a comprehensive suite of shaders and tools to recreate the iconic aesthetic of the PlayStation 1 (PSX). It includes vertex snapping, affine texture mapping, distance-based fog, and post-processing dithering.

For a GD3 version, visit [the repo of snotbane](https://github.com/snotbane/psx_visuals) from which this repo is based.

## How the Plugin Works

The plugin achieves its look through several key components:

* **Shader Global Parameters:** The plugin uses Godot's Global Shader Uniforms to manage settings like vertex snap distance, fog, and affine strength across all materials simultaneously.
* **Custom Shaders:** A set of specialized shaders (`psx_opaque`, `psx_transparent`, etc.) handle the heavy lifting of vertex jittering and texture warping.
* **Autoloads:**
   * `PsxVisualsGd4AutoLoad`: Manages the post-processing layer for screen-space dithering.
   * `PsxVisualsGd4AutoApply`: An optional utility that automatically swaps `StandardMaterial3D` on meshes for PSX-compatible shaders at runtime.

## Installation & Setup

1. Copy the `addons/psx_visuals_gd4` folder into your project's `addons` directory.
2. Go to **Project Settings > Plugins** and enable **PSX Visuals - GD4 Port**.
3. **Setup Dialog:** Upon activation, a configuration dialog will appear. Here you can:
   * Automatically create the necessary **Shader Globals**.
   * Toggle the **Dithering** (Post-processing) Autoload.
   * Toggle the **Auto-Apply** (Material Swapping) Autoload.
4. If you need to change these later, you can manually toggle the scripts in **Project Settings > Globals > Autoload**.

## How to Use

### The "Easy Way" (Auto-Apply)

With `PsxVisualsGd4AutoApply` enabled, the plugin automatically detects `GeometryInstance3D` nodes as they enter the scene tree and replaces their materials with PSX shaders while preserving Albedo and Emission textures.

**Node-Specific Configuration:**
You can configure how the plugin treats specific nodes via a context menu:

1. **Right-click** any node in the Scene Tree.
2. Select **PSX Visuals Settings**.
3. Use the dialog to toggle effects or override material types for that node or its children.

### The Manual Way

Apply the provided materials or create new ones using the PSX shaders:

1. Select a `MeshInstance3D`.
2. Create a new `ShaderMaterial` on the **Surface** or **Material Override**.
3. Assign a shader from `addons/psx_visuals_gd4/shaders/`:
   * `psx_opaque.gdshader`: Standard solid objects.
   * `psx_transparent.gdshader`: For transparency/alpha-cutouts.
   * `psx_opaque_double.gdshader` / `psx_transparent_double.gdshader`: Double-sided meshes.

## Metadata Configuration Reference

If you prefer to set values manually or via script, the plugin looks for the following **Metadata** (Boolean or String) on nodes:

| Flag                    | Type     | Description                                                                                             |
|-------------------------|----------|---------------------------------------------------------------------------------------------------------|
| `psx_disable`           | `bool`   | If `true`, Auto-Apply ignores this specific node.                                                       |
| `psx_disable_children`  | `bool`   | If `true`, Auto-Apply ignores this node and all its descendants.                                        |
| `psx_material`          | `string` | Force a specific shader for this node (`opaque`, `transparent`, `opaque_double`, `transparent_double`). |
| `psx_material_children` | `string` | Force a specific shader for all children of this node.                                                  |

## Shader Settings

Settings are located under **Project Settings > Globals > Shader Globals**:

* **`psx_snap_distance`**: Controls the "vertex jitter". A value of `0.025` is standard; lower values result in smoother movement, while higher values increase the "shaking" effect.
* **`psx_affine_strength`**: Controls texture warping. `1.0` provides full PSX-style warping, while `0.0` is modern perspective-correct mapping.
* **`psx_bit_depth`**: Determines the color depth for the dither effect. Lower values (e.g., `4` or `5`) result in more aggressive banding/dithering.
* **`psx_fog_color`**: The color of the distance fog. The Alpha channel determines the fog's intensity.

## Updating the Plugin

When updating to a newer version of **PSX Visuals - GD4 Port**, follow these steps to ensure you don't accidentally wipe your project configuration:

1. **Disable the Plugin:** * Go to **Project Settings > Plugins** and uncheck the **Enabled** box for PSX Visuals.
   * A **Cleanup PSX Visuals** dialog will appear.
   * **CRITICAL:** To keep your progress, simply click **Cancel** or ensure both checkboxes (**Remove Shader Globals** and **Remove Node Metadata**) are **unchecked** before clicking **Execute Cleanup**. This preserves your project settings and the `psx_*` tags on your nodes.
2. **Remove Old Files:**
   * Delete the `addons/psx_visuals_gd4` folder from your project directory.
   * *Note: Deleting the folder does not delete the metadata stored inside your .tscn files, so your settings are safe.*
3. **Install New Version:**
   * Copy the new `addons/psx_visuals_gd4` folder into your project's `addons` directory.
4. **Re-enable:**
   * Go back to **Project Settings > Plugins** and check the **Enabled** box.
   * The **Setup Dialog** will appear. Re-verify your preferred components (Dithering/Auto-Apply) and click **Apply Settings** to re-initialize the plugin and its shader globals.

## License

The [original forked repository](https://github.com/snotbane/psx_visuals) is listed as using the Unlicense. All changes, Godot 4 porting work, and new code provided in this version are licensed under the **MIT License**.

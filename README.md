# Volumetric Lines URP - Unity Asset
Source of the [Volumetric Lines URP Asset from Unity's Asset Store](http://u3d.as/1N5u), which is the original Volumetric Lines asset extended by support for the Universal Render Pipeline (URP).

Here, on GitHub, you find the free to use version of this Unity asset. You can download it (make sure to checkout the right branch, which is `universal_render_pipeline`), try it out, and even use it for your projects.

However, if you find this asset helpful, **please consider purchasing it on the Unity Asset store** (use the link above). Your support helps to further the development of the URP version of this asset. Thank you!

# Description
Volumetric Lines is a fast, GPU-based volumetric line renderer based on a technique by Sébastien Hillaire. It can be used to render lines with a volumetric appearance by smartly utilizing a texture. Through the use of different textures, different volumetric line effects can be achieved.

*Some usage examples:*      
Example 1: A radial gradient texture can be used to render anti-aliased volumetric lines like laser shots or light sabers.      
Example 2: A texture with a filled, solid circle positioned in the center of the square texture can be used to create the appearance of pipes.        

Technically, the algorithm only uses as little as 8 vertices to describe a single line and positions them smartly on the screen to create a volumetric appearance. It also includes an algorithm to render volumetric line strips.


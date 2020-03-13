[![paypal](https://www.paypalobjects.com/en_US/AT/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=C9MYXDBT7RB8L&currency_code=EUR&source=url)

# Volumetric Lines - Unity Asset
Source of the [Volumetric Lines Asset from Unity's Asset Store](http://u3d.as/br1).

Support the development of this asset by donating via the PayPal link above. Your donations are greatly appreciated and help to improve this asset. Volumetric Lines is available for free on both, the Unity's Asset Store and here, on GitHub.

# Description
Volumetric Lines is a fast, GPU-based volumetric line renderer based on a technique by Sébastien Hillaire. It can be used to render lines with a volumetric appearance by smartly utilizing a texture. Through the use of different textures, different volumetric line effects can be achieved.

*Some usage examples:*      
Example 1: A radial gradient texture can be used to render anti-aliased volumetric lines like laser shots or light sabers.      
Example 2: A texture with a filled, solid circle positioned in the center of the square texture can be used to create the appearance of pipes.        

Technically, the algorithm only uses as little as 8 vertices to describe a single line and positions them smartly on the screen to create a volumetric appearance. It also includes an algorithm to render volumetric line strips.

# Support for the Universal Render Pipeline

Support for the Universal Render Pipeline (URP) has been added and is available on the branch [`universal_render_pipeline`](https://github.com/johannesugb/VolumetricLinesUnity/tree/universal_render_pipeline).

# Custom Camera Preview

A plugin to create a floating camera preview window for Godot 4, based on [Nefrace's Godot 3 plugin](https://github.com/nefrace/godot-camera-preview)

**Why would you need this? Godot already comes with a camera preview.**

Yes, well, for my own project I need the preview to be locked to a certain aspect ratio because of the way I'm using screen space shaders and don't want to run the game every time I want to see how a scene looks.

I also added a tool for toggling object visibility layers in the main 3D editor (which should be a built-in feature!). This is very handy in some situations where an object is interfering with the editor view but you still want to see it in the camera preview.

https://github.com/djunkles/custom-camera-preview/assets/53077435/a281a47f-9cec-4083-9ed5-69fa7a71dd58

## Features

- Floating camera preview window
- Lock the preview window to an aspect ratio:
  - Unconstrained / 4:3 / 16:9 / 16:10
- 3D editor cull mask tool, allowing you to hide objects in the main 3D viewport using cull layers

## Installation

- Clone repo into "addons" folder
- Enable plugin in project settings

## How to Use

- Enable the window in the "Camera Preview" button on the 3D editor toolbar
- Select a camera node to look through it
- (optional) choose to lock the preview window to an aspect ratio
- (optional) hide objects in main viewport by assigning them a visibility layer and turning off that layer in the editor camera cull tool

Thanks to Nefrace for sharing their camera plugin which gave me a great starting point for this plugin.

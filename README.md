# Custom Camera Preview
A plugin to create a floating camera preview window for Godot 4, based on [Nefrace's Godot 3 plugin](https://github.com/nefrace/godot-camera-preview)

**Why would you need this? Godot already comes with a camera preview.**

Yes, well, for my own project I need the preview to be locked to a certain aspect ratio because of the way I'm using screen space shaders and don't want to run the game every time I want to see how a scene looks.
So if you are in a similar situation and need to see the camera preview with a locked aspect ratio this might be helpful.

The aspect options are:
- Unconstrained
- 4:3
- 16:9
- 16:10

## Installation
 - Clone repo into "addons" folder
 - Enable plugin in project settings

## How to Use
- Enable the window in the "Camera Preview" button on the 3D editor toolbar
- Select a camera node to look through it
- (optional) choose to lock the preview window to an aspect ratio
- The window can be dragged to be resized/repositioned

Thanks to Nefrace for doing the hard work, I just got it running in Godot 4.2, took out some features I wouldn't use and added what I needed.

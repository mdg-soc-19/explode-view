# Explode View
A new open-source Flutter project that enables the developers to quickly enhance the ui of their application and can easily get started with the Flutter animation. The ui has been inspired from Redmi's uninstall application animation shown [here](https://github.com/mdg-soc-19/explode-view/blob/master/gif/explode-view-idea.gif).

This project contains the features of Flutter Animation that are required to complete an amazing Flutter application.

# Algorithm 
The algorithm used to build this project is as follows:

On clicking the view, the view would be disappeared and at random position surrounding the view, there would be random particle generation and they would go farther with fading and upcoming transition and disappear finally on the screen.

# Work Status
- I have created the Particle class which takes in id, position, color, and screenSize as the parameters and returns a circular particle for fixed radius.
- Then I have also implemented the algorithm for picking color from particular position of image. 
- I have also implemented that on clicking image, it would disappear and random particles will be generated and scatter with fading.

# To-Do List
- I have implemented the scattering of particles and color picking from image separately which has to be combined for proper color cobination of the particles according to the image.
- I have to decide position for particles according to the image to give a realistic feel of breaking of the image.
- I have to convert the app into flutter package.
- Fixing some bugs and animation changes.

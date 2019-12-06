
# <div align="center">Explode View</div>

<p align="center"> <img src="https://github.com/mdg-soc-19/explode-view/blob/master/gif/explode-view.gif?raw=true" height = "500px"/></p>

<p align="center">A beautiful explosion animation for Flutter</p>

A new open-source Flutter project that enables the developers to quickly enhance the ui of their application and can easily get started with the Flutter animation. The UI has been inspired from Redmi's uninstall application animation shown [here](https://github.com/mdg-soc-19/explode-view/blob/master/gif/explode-view-idea.gif).

<p align="center">This project contains the features of Flutter Animation that are required to complete an amazing Flutter application.</p>


# How To Use
## Let's get this animation
Here is how explode animation works.
```dart
ExplodeView(
      imagePath: 'assets/images/abc.png',	// path where the image is stored
      imagePosFromLeft: 120.0,	// set x-coordinate for image
      imagePosFromRight: 300.0,		// set y-coordinate for image
      );
```
For more info, please refer to the `main.dart` in example.


# Algorithm 
The algorithm used to build this project is as follows:

On clicking the view, the view would be disappeared and at random position surrounding the view, there would be random particle generation and they would go farther with fading and upcoming transition and disappear finally on the screen.

For more info, please refer to the `explode_view.dart`.

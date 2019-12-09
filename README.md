
<p align="center"> <img src="https://github.com/mdg-soc-19/explode-view/blob/master/gif/cover.png?raw=true" height = "500px"/></p>  
  
<div align="center">  
<a href="https://flutter.io">  
    <img src="https://img.shields.io/badge/Platform-Flutter-yellow.svg"  
      alt="Platform" />  
  </a>  
  <a href="https://opensource.org/licenses/MIT">  
    <img src="https://img.shields.io/badge/License-MIT-red.svg"  
      alt="License: MIT" />  
  </a>  
  <a href="https://pub.dev/packages/explode_view">  
    <img src="https://img.shields.io/pub/v/explode_view.svg"  
      alt="Pub Package" />  
  </a>  
  </div>  
<br/>  
A new open-source Flutter project that enables the developers to quickly enhance the ui of their application and can easily get started with the Flutter animation. The UI has been inspired from Redmi's uninstall application animation shown [here](https://github.com/mdg-soc-19/explode-view/blob/master/gif/explode-view-idea.gif).  
  
This project contains the features of Flutter Animation that are required to complete an amazing Flutter application.  
  
Explore how ExplodeView is made through this [blog](https://medium.com/mobile-development-group/flutter-explosion-animation-for-image-3dd5e2863427).  
  
# Index  
* [Installing](#installing)  
* [How To Use](#how-to-use)  
* [Algorithm](#algorithm)  
* [Documentation](#documentation)  
* [Bugs/Requests](#bugsrequests)  
* [License](#license)  
  
  
# Installing  
  
<img src="https://github.com/mdg-soc-19/explode-view/blob/master/gif/explode-view.gif?raw=true" height = "400px" align = "right"/>  
  
### 1. Depend on it  
Add this to your package's `pubspec.yaml` file:  
  
```yaml dependencies:   
  explode_view: ^1.0.3  
```  
  
### 2. Install it  
  
You can install packages from the command line:  
  
with `pub`:  
  
```css  
$ pub get  
```  
  
with `Flutter`:  
  
```css  
$ flutter packages get  
```  
  
Alternatively, your editor might support  `flutter pub get`. Check the docs for your editor to learn more.  
  
### 3. Import it  
  
Now in your `Dart` code, you can use:   
  
```dart 
import  'package:explode_view/explode_view.dart';  
```  
  
# How To Use  
  
## Let's get this animation  
For the explosion animation in the app, user has to simply add the `ExplodeView` as a child in any Widget like Stack and many more.  
  
Example Code:   
```dart 
ExplodeView(  
 imagePath: 'assets/images/abc.png',  // path where the image is stored 
 imagePosFromLeft: 	120.0, // set x-coordinate for image 
 imagePosFromRight: 300.0,  // set y-coordinate for image 
);
 ```  
For more info, please refer to the `main.dart` in example.  
  
  
# Algorithm 
The algorithm used to build this project is as follows:  
  
On clicking the image, the image would shake for some time and will disappear with generation of random particles in that image area and they would scatter farther with fading and upcoming transition and disappear finally on the screen. The colors of the particles are decided by the colors of the pixels of the image which provides the effect of breaking the image into pieces.  
  
For more info, please refer to the `explode_view.dart`.  
  
  
# Documentation  
  
| Dart attribute                        | Datatype                    | Description                                                  |     Default Value     |  
| :------------------------------------ | :-------------------------- | :----------------------------------------------------------- | :-------------------: |  
| imagePath                                 | String                  | The string which gives the path to the image.                    |       @required       |  
| imagePosFromLeft                             | double             | The distance from the left edge of the screen. |       @required       |  
| imagePosFromTop                                | double                      | The distance from the top edge of the screen. |         @required         |  
  
# Bugs/Requests  
  
If you encounter any problems feel free to open an issue. If you feel the library is  
missing a feature, please raise a ticket on Github and I'll look into it.  
Pull request are also welcome.  
  
# License  
ExplodeView is licensed under MIT License. View [license](https://github.com/mdg-soc-19/explode-view/blob/master/explode_view/LICENSE).

<p align="center">
  <img src="https://github.com/MerrickSapsford/CocoaBar/blob/develop/Resource/Icon.png?raw=true" alt="MSSTabbedPageViewController" height="160" width="160"/>
</p>

# CocoaBar
[![Build Status](https://travis-ci.org/MerrickSapsford/CocoaBar.svg?branch=develop)](https://travis-ci.org/MerrickSapsford/CocoaBar)
![](https://img.shields.io/cocoapods/v/CocoaBar.svg)
![](https://img.shields.io/badge/Swift-3.0-orange.svg)

A flexible and simple to use SnackBar view for iOS.

## Installation
CocoaBar is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

    pod 'CocoaBar'

Swift 2.1 support is available in version 0.1.7 or below:

    pod 'CocoaBar', '~> 0.1.0'

And run `pod install`.

## Usage
CocoaBar can be attached to a view or window.

	public init(window: UIWindow?)
	public init(view: UIView?)

The CocoaBar can then be shown or hidden using the `showAnimated` or `hideAnimated` functions. There are numerous convenience functions available for showing the CocoaBar to allow for easy customisation. They provide the following:

- **Duration** - either a `Double` or `DisplayDuration`; which provides a preset time period to display the bar for.
- **Layout** - provide a custom `CocoaBarLayout` layout to display.
- **Style** - use one of the predefined layouts for display.

When a CocoaBar is attached to the `keyWindow`, it is made available as the `keyCocoaBar`. `showAnimated` and `hideAnimated` class functions are then available on `CocoaBar` for the `keyCocoaBar`.

### Customisation
Custom layouts can be displayed in a CocoaBar with the use of a `CocoaBarLayout` subclass.

`CocoaBarLayout` will automatically attempt to inflate a nib associated with the layout (using the same class name), and use AutoLayout to calculate the required dimensions. `init(nibName, height)` is also available to manually specify the nib to use and set an explicit height. Refer to the example project to see usage of a custom layout.

The following properties are available to customise on a CocoaBarLayout:

- **backgroundStyle** - customise the appearance of the layout background.
- **displayStyle** - customise the display appearance of the layout.
- **keylineColor** - the colour of the 1pt keyline at the top of the layout.
- **dismissButton** - attach to a button that serves purely for dismissal of the CocoaBar.
- **actionButton** - attach to a button that serves as an action button for the layout. Interaction will result in the `cocoaBar(cocoaBar: actionButtonPressed actionButton:)` being called for the `CocoaBarDelegate`.

## Requirements
Supports iOS 8 and above.

## Author
Merrick Sapsford

[sapsford.tech](http://www.sapsford.tech)  
[@MerrickSapsford](http://www.twitter.com/MerrickSapsford)  
[merrick@sapsford.tech](mailto:merrick@sapsford.tech)

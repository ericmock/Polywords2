//
//  ButtonView.m
//  AlphaHedra
//
//  Created by Eric Mockensturm on 5/25/09.
//  Copyright 2009 Small Feats Software. All rights reserved.
//

import Foundation
import AppKit

//@implementation ButtonView

//@synthesize submitWordButton;
//@synthesize backButton;
//@synthesize pauseButton;
//
class ButtonView {
    var backgroundColor:CGColor
    var appController: AppDelegate
    let submitWordButton: NSButton

    init(withFrame frame:CGRect, withController d:AppDelegate) {

        appController = d
        backgroundColor = CGColor.clear
        let buttonBackground = NSImage(named: NSImage.Name("WhiteButton"))//[let buttonBackground:NSImage = [UIImage imageNamed:@"whiteButton.png"];
        let buttonBackgroundPressed = NSImage(named: NSImage.Name("blueButton"))//UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"blueButton.png"];
        buttonBackground?.resizingMode = .stretch
//            UIImage *newImage = [buttonBackground stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
        buttonBackground?.resizingMode = .stretch
//            UIImage *newPressedImage = [buttonBackgroundPressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
//
//            // create the buttons
        submitWordButton = NSButton(title: "Pause", image: buttonBackground!, target: Any?.self, action: #selector(submitWord))
        submitWordButton.alternateImage = buttonBackgroundPressed
        //TODO:  Figure out how to add button to view
//            submitWordButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 70.0)];
//            [submitWordButton setBackgroundImage:newImage forState:UIControlStateNormal];
//            [submitWordButton setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
//            [submitWordButton setTitle:@"Pause" forState:UIControlStateNormal];
//            // deprecated		submitWordButton.font = [UIFont boldSystemFontOfSize:30];
//            submitWordButton.titleLabel.font = [UIFont boldSystemFontOfSize:30]; // 3.0 only
//            submitWordButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//            submitWordButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//            submitWordButton.adjustsImageWhenDisabled = YES;
//            [submitWordButton addTarget:self action:@selector(submitWord) forControlEvents:UIControlEventTouchUpInside];
//            [self addSubview:submitWordButton];
//            [submitWordButton release];
//
//        return self;
         }

//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}
//

    @objc func submitWord() {
        if submitWordButton.title == "Pause" {
            appController.pause()
        } else {
            appController.setSubmitted()
        }
    }


//- (void) submitWord {
//	if ([submitWordButton.currentTitle isEqualToString:@"Pause"])
//		[appController pause];
//	else
//		[appController setSubmitted];
//}
//
//- (void) back {
////	[appController showMainMenu];
//}
//
//- (void) pause {
////	[appController pause];
//}
//
//- (void)dealloc {
//    [super dealloc];
//}
//
//@end
}

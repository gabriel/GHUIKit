//
//  GHUIActivityView.h
//  GHUIKit
//
//  Created by Gabriel Handford on 10/30/13.
//  Copyright (c) 2013 Gabriel Handford. All rights reserved.
//

#import "GHUIView.h"

/*!
 View with activity indicator and label.
 */
@interface GHUIActivityView : GHUIView

@property UIActivityIndicatorView *activityIndicator;

- (void)setAnimating:(BOOL)animating;
- (BOOL)isAnimating;

- (void)presentInView:(UIView *)view keyboardRect:(CGRect)keyboardRect animated:(BOOL)animated;
- (void)dismissView:(BOOL)animated;

@end


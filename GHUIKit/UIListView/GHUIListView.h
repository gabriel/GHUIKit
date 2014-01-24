//
//  GHUIListView.h
//  GHUIKit
//
//  Created by Gabriel Handford on 11/5/13.
//  Copyright (c) 2013 Gabriel Handford. All rights reserved.
//

#import "GHUIView.h"

@interface GHUIListView : GHUIView {
  NSMutableArray *_views;
}

@property UIEdgeInsets insets;
@property UIColor *borderColor;

- (NSArray *)views;

/*!
 Add view.
 @param view
 */
- (void)addView:(UIView *)view;


@end

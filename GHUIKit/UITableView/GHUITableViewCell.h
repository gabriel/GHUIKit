//
//  GHUITableViewCell.h
//  GHUIKit
//
//  Created by Gabriel Handford on 1/22/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHUITableViewCell : UITableViewCell

+ (Class)contentViewClass;

- (id)viewForContent;

@end
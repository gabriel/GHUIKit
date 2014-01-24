//
//  GHUILabel.m
//  GHUIKit
//
//  Created by Gabriel Handford on 11/8/13.
//  Copyright (c) 2013 Gabriel Handford. All rights reserved.
//

#import "GHUILabel.h"
#import "GHUIUtils.h"

@implementation GHUILabel

- (void)sharedInit {
  [super sharedInit];
  self.layout = [GHLayout layoutForView:self];
  self.backgroundColor = [UIColor clearColor];
  self.userInteractionEnabled = NO;
  self.contentMode = UIViewContentModeRedraw;
  self.selectedShadingType = GHUIShadingTypeUnknown;
  self.highlightedShadingType = GHUIShadingTypeUnknown;
  self.disabledShadingType = GHUIShadingTypeUnknown;
  self.disabledAlpha = 1.0;
  self.borderWidth = 1.0;
  self.titleColor = [UIColor blackColor];
  self.titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  self.textFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  
  _observeAttributes = @[@"title", @"titleInsets", @"titleFont", @"titleAlignment", @"text", @"textFont", @"textAlignment", @"cornerRadius", @"cornerRadiusRatio", @"accessoryTitle", @"borderStyle"];
  for (NSString *attr in _observeAttributes) {
    [self addObserver:self forKeyPath:attr options:NSKeyValueObservingOptionNew context:nil];
  }
}

- (void)dealloc {
  for (NSString *attr in _observeAttributes) {
    [self removeObserver:self forKeyPath:attr];
  }
  [_imageView removeObserver:self forKeyPath:@"image"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  [self setNeedsLayout];
}

- (void)_sizeText:(CGSize)constrainedToSize size:(CGSize *)size titleSize:(CGSize *)titleSize {
  *size = CGSizeZero;
  *titleSize = CGSizeZero;
  if (_textHidden) return;
  CGSize sizeText = CGSizeZero;
  
  if (_title) {
    sizeText = [GHUIUtils sizeWithText:_title font:_titleFont size:constrainedToSize multiline:YES truncate:YES];
    *titleSize = sizeText;
  }
  
  if (_accessoryTitle) {
    constrainedToSize.width -= roundf(sizeText.width);
    UIFont *font = (_accessoryTitleFont ? _accessoryTitleFont : _titleFont);
    CGSize accessoryTitleSize = [GHUIUtils sizeWithText:_accessoryTitle font:font size:constrainedToSize multiline:NO truncate:YES];
    sizeText.width += roundf(accessoryTitleSize.width);
  }
  
  if (_text) {
    UIFont *font = (_textFont ? _textFont : _titleFont);
    CGSize textSize = [GHUIUtils sizeWithText:_text font:font size:constrainedToSize multiline:YES truncate:YES];
    sizeText.height += roundf(textSize.height);
  }
  
  *size = sizeText;
}

- (CGSize)layout:(id<GHLayout>)layout size:(CGSize)size {
  CGFloat y = 0;
  
  y += _insets.top;
  UIEdgeInsets titleInsets = (_textHidden ? UIEdgeInsetsZero : _titleInsets);
  y += titleInsets.top;
  
  CGSize imageSize = [self _imageSize];
  
  _sizeThatFitsText = CGSizeZero;
  _titleSize = CGSizeZero;
  
  CGSize constrainedToSize = size;
  // Subtract insets
  constrainedToSize.width -= (titleInsets.left + titleInsets.right);
  constrainedToSize.width -= (_insets.left + _insets.right);
  
  // Subtract activity indicator view
  if (_activityIndicatorView && _activityIndicatorView.isAnimating) {
    constrainedToSize.width -= _activityIndicatorView.frame.size.width;
  }
  
  if (constrainedToSize.height == 0) {
    constrainedToSize.height = CGFLOAT_MAX;
  }
  
  [self _sizeText:constrainedToSize size:&_sizeThatFitsText titleSize:&_titleSize];
  
  if (_activityIndicatorView) {
    CGPoint p = GHCGPointToCenter(_activityIndicatorView.frame.size, size);
    if (!_textHidden) {
      p.x -= _activityIndicatorView.frame.size.width + 4;
    }
    [layout setOrigin:p view:_activityIndicatorView];
  }
  
  if (imageSize.height > _sizeThatFitsText.height) {
    y += imageSize.height;
  } else {
    y += _sizeThatFitsText.height;
  }
  
  y += titleInsets.bottom;
  y += _insets.bottom;
  
  return CGSizeMake(size.width, y);
}

- (CGSize)_imageSize {
  CGSize imageSize = _imageSize;
  if (GHCGSizeIsZero(imageSize)) {
    if (self.imageView.image) imageSize = self.imageView.image.size;
  }
  return imageSize;
}

- (CGSize)sizeForVariableWidth:(CGSize)size {
  CGSize imageSize = [self _imageSize];
  CGSize sizeForHeight = [GHUIUtils sizeWithText:_title font:_titleFont size:size multiline:NO truncate:NO];
  sizeForHeight.width += self.insets.left + self.insets.right;
  sizeForHeight.height += self.insets.top + self.insets.bottom;
  sizeForHeight.width += self.titleInsets.left + self.titleInsets.right;
  sizeForHeight.height += self.titleInsets.top + self.titleInsets.bottom;
  sizeForHeight.width += imageSize.width;
  if (self.accessoryImage) sizeForHeight.width += self.accessoryImage.size.width;
  return sizeForHeight;
}

- (void)setDisabled:(BOOL)disabled {
  _disabled = disabled;
  if (_disabledAlpha == 1.0) return;
  self.alpha = (_disabled ? _disabledAlpha : 1.0);
}

- (void)_cornerRadiusChanged {
  if (_borderStyle == GHUIBorderStyleNone && (_cornerRadius > 0 || _cornerRadiusRatio > 0)) {
    self.borderStyle = GHUIBorderStyleRounded;
  }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
  [self willChangeValueForKey:@"cornerRadius"];
  _cornerRadius = cornerRadius;
  [self didChangeValueForKey:@"cornerRadius"];
  [self _cornerRadiusChanged];
}

- (void)setCornerRadiusRatio:(CGFloat)cornerRadiusRatio {
  [self willChangeValueForKey:@"cornerRadiusRatio"];
  _cornerRadiusRatio = cornerRadiusRatio;
  [self didChangeValueForKey:@"cornerRadiusRatio"];
  [self _cornerRadiusChanged];
}

- (UIImageView *)imageView {
  if (!_imageView) {
    _imageView = [[UIImageView alloc] init];
    [_imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
  }
  return _imageView;
}

- (void)setImage:(UIImage *)image {
  self.imageView.image = image;
}

- (void)sizeToFitWithMinimumSize:(CGSize)minSize {
  CGSize size = [self sizeThatFits:minSize];
  if (size.width < minSize.width) size.width = minSize.width;
  if (size.height < minSize.height) size.height = minSize.height;
  self.frame = GHCGRectSetSize(self.frame, size);
}

- (void)setBorderStyle:(GHUIBorderStyle)borderStyle {
  _borderStyle = borderStyle;
  [self didChangeValueForKey:@"borderStyle"];
}

- (void)setBorderStyle:(GHUIBorderStyle)borderStyle color:(UIColor *)color width:(CGFloat)width cornerRadius:(CGFloat)cornerRadius {
  self.borderStyle = borderStyle;
  self.borderColor = color;
  self.borderWidth = width;
  self.cornerRadius = cornerRadius;
}

- (UIColor *)textColorForState {
  
  BOOL isSelected = self.isSelected;
  BOOL isHighlighted = self.isHighlighted;
  BOOL isDisabled = self.isDisabled;
  
  if (_selectedTitleColor && isSelected) {
    return _selectedTitleColor;
  } else if (_highlightedTitleColor && isHighlighted) {
    return _highlightedTitleColor;
  } else if (_disabledTitleColor && isDisabled) {
    return _disabledTitleColor;
  } else if (_titleColor) {
    return _titleColor;
  } else {
    return [UIColor blackColor];
  }
}

- (UIActivityIndicatorView *)activityIndicatorView {
  if (!_activityIndicatorView) {
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.hidesWhenStopped = YES;
    [self addSubview:_activityIndicatorView];
  }
  return _activityIndicatorView;
}

- (void)setActivityIndicatorAnimating:(BOOL)animating {
  if (animating) {
    [self.activityIndicatorView startAnimating];
    if (self.hideTextIfAnimating) self.textHidden = YES;
  } else {
    [self.activityIndicatorView stopAnimating];
    if (self.hideTextIfAnimating) self.textHidden = NO;
  }
  [self setNeedsLayout];
}

- (BOOL)isAnimating {
  return [_activityIndicatorView isAnimating];
}

- (void)drawInRect:(CGRect)rect {
  // Force layout if we never have
  if (GHCGSizeIsZero(_sizeThatFitsText)) [self layoutView];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGRect bounds = rect;
  bounds = UIEdgeInsetsInsetRect(bounds, self.margin);
  CGSize size = bounds.size;
  
  size.height -= self.insets.top + self.insets.bottom;
  
  BOOL isHighlighted = self.isHighlighted;
  BOOL isSelected = self.isSelected;
  BOOL isDisabled = self.isDisabled;
  
  GHUIShadingType shadingType = self.shadingType;
  UIColor *fillColor = self.fillColor;
  UIColor *fillColor2 = self.fillColor2;
  UIColor *fillColor3 = self.fillColor3;
  UIColor *fillColor4 = self.fillColor4;
  UIColor *borderColor = self.borderColor;
  
  CGFloat cornerRadius = self.cornerRadius;
  if (self.cornerRadiusRatio > 0) {
    cornerRadius = roundf((bounds.size.height/2.0f) * self.cornerRadiusRatio);
  }
  
  UIImage *accessoryImage = self.accessoryImage;
  
  if (isDisabled) {
    if (self.disabledShadingType != GHUIShadingTypeUnknown) shadingType = self.disabledShadingType;
    if (self.disabledFillColor) fillColor = self.disabledFillColor;
    if (self.disabledFillColor2) fillColor2 = self.disabledFillColor2;
    if (self.disabledBorderColor) borderColor = self.disabledBorderColor;
  } else if (isHighlighted) {
    if (self.highlightedShadingType != GHUIShadingTypeUnknown) shadingType = self.highlightedShadingType;
    if (self.highlightedFillColor) fillColor = self.highlightedFillColor;
    if (self.highlightedFillColor2) fillColor2 = self.highlightedFillColor2;
    if (self.highlightedBorderColor) borderColor = self.highlightedBorderColor;
    if (self.highlightedAccessoryImage) accessoryImage = self.highlightedAccessoryImage;
  } else if (isSelected) {
    // Set from selected properties; Fall back to highlighted properties
    if (self.selectedShadingType != GHUIShadingTypeUnknown) shadingType = self.selectedShadingType;
    else if (self.highlightedShadingType != GHUIShadingTypeUnknown) shadingType = self.highlightedShadingType;
    if (self.selectedFillColor) fillColor = self.selectedFillColor;
    else if (self.highlightedFillColor) fillColor = self.highlightedFillColor;
    if (self.selectedFillColor2) fillColor2 = self.selectedFillColor2;
    else if (self.highlightedFillColor2) fillColor2 = self.highlightedFillColor2;
  }
  
  CGFloat borderWidth = self.borderWidth;
  
  // Clip for border styles that support it (that form a cohesive path)
  BOOL clip = GHIsBorderStyleClippable(self.borderStyle, cornerRadius);
  
  GHCGContextAddStyledRect(context, bounds, self.borderStyle, borderWidth, cornerRadius);
  if (clip) {
    CGContextSaveGState(context);
    CGContextClip(context);
  }
  
  if (fillColor && shadingType != GHUIShadingTypeNone) {
    GHCGContextDrawShading(context, fillColor.CGColor, fillColor2.CGColor, fillColor3.CGColor, fillColor4.CGColor, bounds.origin, CGPointMake(bounds.origin.x, CGRectGetMaxY(bounds)), shadingType, NO, NO);
    fillColor = nil;
  } else if (fillColor) {
    [fillColor setFill];
    CGContextFillRect(context, bounds);
  }
  
  UIColor *textColor = [self textColorForState];
  
  UIFont *font = self.titleFont;
  
  UIImage *image = self.imageView.image;
  CGSize imageSize = self.imageSize;
  if (image && GHCGSizeIsZero(imageSize)) {
    imageSize = image.size;
  }
  
  CGFloat x = bounds.origin.x;
  CGFloat y = bounds.origin.y;
  
  if (image) {
    [image drawInRect:CGRectMake(x, y, imageSize.width, imageSize.height)];
  }
  
  CGSize sizeThatFits = _sizeThatFitsText;

  x += self.insets.left;
  y += roundf(GHCGPointToCenter(sizeThatFits, size).y) + self.insets.top;
  
  UIEdgeInsets titleInsets = _titleInsets;
  
  CGFloat lineWidth = sizeThatFits.width + titleInsets.left + titleInsets.right;
  if (accessoryImage) lineWidth += accessoryImage.size.width;
  
  if (self.titleAlignment == NSTextAlignmentCenter) {
    CGFloat width = size.width - self.insets.left - self.insets.right;
    x += roundf(width/2.0f - lineWidth/2.0f);
  }
  if (x < 0) x = 0;
  
  x += titleInsets.left;
  
  CGPoint titleOrigin = CGPointMake(x, y);
  
  if (self.title && !self.textHidden) [GHUIUtils drawText:self.title rect:CGRectMake(titleOrigin.x, titleOrigin.y, _titleSize.width, _titleSize.height) font:font color:textColor alignment:self.titleAlignment multiline:YES truncate:YES];
  
  if (self.accessoryTitle && !self.textHidden) {
    if (self.accessoryTitleColor) textColor = self.accessoryTitleColor;
    if (self.accessoryTitleFont) font = self.accessoryTitleFont;
    if (self.accessoryTitleAlignment == NSTextAlignmentLeft) {
      x += _titleSize.width;
      CGFloat accessoryTitleWidth = size.width - x - self.insets.right - titleInsets.right;
      [GHUIUtils drawText:self.accessoryTitle rect:CGRectMake(x, y, accessoryTitleWidth, CGFLOAT_MAX) font:font color:textColor alignment:NSTextAlignmentLeft multiline:YES truncate:YES];
    } else if (self.accessoryTitleAlignment == NSTextAlignmentRight) {
      x += _titleSize.width;
      [GHUIUtils drawText:self.accessoryTitle rect:CGRectMake(x, y, size.width - x - self.insets.right - self.titleInsets.right, size.height) font:font color:textColor alignment:NSTextAlignmentRight multiline:YES truncate:YES];
    } else {
      NSAssert(NO, @"Unsupported accessory title alignment");
    }
  }
  
  if (accessoryImage) {
    [accessoryImage drawAtPoint:GHCGPointToRight(accessoryImage.size, CGSizeMake(size.width - 10, bounds.size.height))];
  }
  
  // Arrow
  if (self.leftArrowColor) {
    CGContextBeginPath(context); // Clear any paths
    CGFloat arrowHalf = roundf((size.height - 12.0f)/2.0f);
    CGFloat arrowX = bounds.origin.x + 2;
    CGFloat arrowY = bounds.origin.y + 6;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(arrowX + arrowHalf, arrowY)];
    [path addLineToPoint:CGPointMake(arrowX, arrowY + arrowHalf)];
    [path addLineToPoint:CGPointMake(arrowX + arrowHalf, arrowY + arrowHalf + arrowHalf)];
    [self.leftArrowColor setStroke];
    [path setLineWidth:3];
    [path stroke];
  }
  
  y += _titleSize.height;
  
  if (self.text && !self.textHidden) {
    if (self.textColor) textColor = self.textColor;
    if (self.textFont) font = self.textFont;
    if (self.titleAlignment == NSTextAlignmentLeft) {
      x = titleOrigin.x;
    } else {
      x = self.insets.left;
    }
    [GHUIUtils drawText:self.text rect:CGRectMake(x, y, size.width - x - self.insets.right, CGFLOAT_MAX) font:font color:textColor alignment:self.textAlignment multiline:YES truncate:YES];
  }
  
  if (clip) {
    CGContextRestoreGState(context);
  }
  
  if (borderWidth > 0 || cornerRadius > 0) {
    GHCGContextDrawBorder(context, bounds, self.borderStyle, NULL, borderColor.CGColor, borderWidth, cornerRadius);
  }
}

- (void)drawRect:(CGRect)rect {
  [self drawInRect:self.bounds];
}

@end

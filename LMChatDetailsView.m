//
//  LMChatDetailsView.m
//  LangueMatch
//
//  Created by Travis Buttaccio on 4/14/15.
//  Copyright (c) 2015 LangueMatch. All rights reserved.
//

#import "LMChatDetailsView.h"
#import "Utility.h"

@interface LMChatDetailsView() <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation LMChatDetailsView

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _chatTitle = [[UITextField alloc] init];
        _chatTitle.placeholder = @"Chat Name";
        _chatTitle.borderStyle = UITextBorderStyleRoundedRect;
        _chatTitle.clearsOnBeginEditing = NO;
        _chatTitle.textAlignment = NSTextAlignmentCenter;
        _chatTitle.keyboardAppearance = UIKeyboardAppearanceDark;
        
        
        UIImage *chatImagePlaceholder = [UIImage imageNamed:@"multiplepeople.png"];
        
        _chatImageView = [[UIImageView alloc] initWithImage:chatImagePlaceholder];
        _chatImageView.contentMode = UIViewContentModeScaleAspectFill;
        _chatImageView.userInteractionEnabled = YES;
        
//        UIBezierPath *clippingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.chatImageView.frame), CGRectGetMidY(self.chatImageView.frame)) radius:150 startAngle:0 endAngle:2*M_PI clockwise:YES];
//        CAShapeLayer *mask = [CAShapeLayer layer];
//        mask.path = clippingPath.CGPath;
//        self.chatImageView.layer.mask = mask;
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatImageViewTapped:)];
        _tapGesture.delegate = self;
        [_chatImageView addGestureRecognizer:_tapGesture];
        
        for (UIView *view in @[_chatTitle, _chatImageView]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    return self;
}

-(void)layoutSubviews
{
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_chatTitle, _chatImageView);
    
    CENTER_VIEW_H(self, _chatTitle);
    CONSTRAIN_WIDTH(_chatTitle, 250);
    
    CENTER_VIEW_H(self, _chatImageView);
    CONSTRAIN_HEIGHT(_chatImageView, 300);
    CONSTRAIN_WIDTH(_chatImageView, 300);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-115-[_chatTitle(==40)]-50-[_chatImageView]"
                                                               options:kNilOptions
                                                               metrics:nil
                                                                  views:viewDictionary]];
    
}

-(void)chatImageViewTapped:(UIGestureRecognizer *)gesture
{
    [self.delegate chatImageViewTapped:_chatImageView];
}

@end

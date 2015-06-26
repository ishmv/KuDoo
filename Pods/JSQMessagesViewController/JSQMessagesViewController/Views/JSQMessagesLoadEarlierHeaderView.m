//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesLoadEarlierHeaderView.h"

#import "NSBundle+JSQMessages.h"


const CGFloat kJSQMessagesLoadEarlierHeaderViewHeight = 32.0f;


@interface JSQMessagesLoadEarlierHeaderView ()

@property (weak, nonatomic) IBOutlet UIButton *loadButton;

- (IBAction)loadButtonPressed:(UIButton *)sender;

@end


@implementation JSQMessagesLoadEarlierHeaderView

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([JSQMessagesLoadEarlierHeaderView class])
                          bundle:[NSBundle bundleForClass:[JSQMessagesLoadEarlierHeaderView class]]];
}

+ (NSString *)headerReuseIdentifier
{
    return NSStringFromClass([JSQMessagesLoadEarlierHeaderView class]);
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.backgroundColor = [UIColor clearColor];
    self.loadButton.backgroundColor = [UIColor colorWithRed:233/255.0 green:99/255.0 blue:59/255.0 alpha:1.0];
    self.loadButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
    [self.loadButton.layer setCornerRadius:10.0f];
    [self.loadButton.layer setMasksToBounds:YES];

    [self.loadButton setTitle:[NSBundle jsq_localizedStringForKey:@"load_earlier_messages"] forState:UIControlStateNormal];
}

- (void)dealloc
{
    _loadButton = nil;
    _delegate = nil;
}

#pragma mark - Reusable view

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.loadButton.backgroundColor = backgroundColor;
}

#pragma mark - Actions

- (IBAction)loadButtonPressed:(UIButton *)sender
{
    [self.delegate headerView:self didPressLoadButton:sender];
}

@end

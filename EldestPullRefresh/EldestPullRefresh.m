//
//  EldestPullRefresh.m
//  EldestPullRefresh
//
//  Created by WilliamZhang on 15/9/24.
//  Copyright © 2015年 WilliamZhang. All rights reserved.
//

#import "EldestPullRefresh.h"

#define TEXT_COLOR [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0];
static CGFloat flipAnimationDuration = 0.18f;

@interface EldestPullRefresh ()

@property (nonatomic ,assign) EldestPullRefreshState state;

@property (nonatomic ,strong) UILabel *lastUpdatedLabel;
@property (nonatomic ,strong) UILabel *stateLabel;
@property (nonatomic ,strong) CALayer *arrowImage;
@property (nonatomic ,strong) UIActivityIndicatorView *activityView;

@end

@implementation EldestPullRefresh

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        
        [self addSubview:self.lastUpdatedLabel];
        [self addSubview:self.stateLabel];
        [self.layer addSublayer:self.arrowImage];
        [self addSubview:self.activityView];
        
        [self setState:EldestPullRefreshNormal];
    }
    return self;
}

#pragma mark -
#pragma mark Setter
- (void)refreshLastUpdatedDate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(eldestRefreshTableHeaderDataSourceLastUpdated:)]) {
        NSDate *date = [self.delegate eldestRefreshTableHeaderDataSourceLastUpdated:self];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setAMSymbol:@"AM"];
        [formatter setPMSymbol:@"PM"];
        [formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
        self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
        [[NSUserDefaults standardUserDefaults] setObject:self.lastUpdatedLabel.text forKey:@"EldestPullRefresh_LastRefresh"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.lastUpdatedLabel.text = @"";
    }
}

- (void)setState:(EldestPullRefreshState)state {
    switch (state) {
        case EldestPullRefreshPulling:
            self.stateLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
            [CATransaction begin];
            [CATransaction setAnimationDuration:flipAnimationDuration];
            self.arrowImage.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            [CATransaction commit];
            break;
        case EldestPullRefreshNormal:
            if (self.state == EldestPullRefreshPulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:flipAnimationDuration];
                self.arrowImage.transform = CATransform3DIdentity;
                [CATransaction commit];
            }
            
            self.stateLabel.text = NSLocalizedString(@"Pull Down to refresh...", @"Pull Down to refresh status");
            
            [self.activityView stopAnimating];
            [CATransaction begin];
            [CATransaction setAnimationDuration:flipAnimationDuration];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            self.arrowImage.hidden = NO;
            self.arrowImage.transform = CATransform3DIdentity;
            
            [CATransaction commit];
            
            [self refreshLastUpdatedDate];
            
            break;
        
        case EldestPullRefreshLoading:
            self.stateLabel.text = NSLocalizedString(@"Loading...", @"Loading status");
            [self.activityView startAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            self.arrowImage.hidden = YES;
            [CATransaction commit];
            break;
    }
    
    _state = state;
}

#pragma mark -
#pragma mark ScrollView Method
- (void)eldestRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.state == EldestPullRefreshLoading) {
        
        CGFloat offset = MAX(-scrollView.contentOffset.y, 0);
        offset = MIN(offset, 60);
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0);
        
    } else if (scrollView.isDragging) {
        
        BOOL loading = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(eldestRefreshTableHeaderDataSourceIsLoading:)]) {
            loading = [self.delegate eldestRefreshTableHeaderDataSourceIsLoading:self];
        }
        
        if (self.state != EldestPullRefreshNormal && scrollView.contentOffset.y > -65 && scrollView.contentOffset.y < 0 && !loading) {
            [self setState:EldestPullRefreshNormal];
        } else if (self.state == EldestPullRefreshNormal && scrollView.contentOffset.y < -65 && !loading) {
            [self setState:EldestPullRefreshPulling];
        }
        
        if (scrollView.contentInset.top != 0) {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
    }
}

- (void)eldestRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    BOOL loading = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(eldestRefreshTableHeaderDataSourceIsLoading:)]) {
        loading = [self.delegate eldestRefreshTableHeaderDataSourceIsLoading:self];
    }
    
    if (scrollView.contentOffset.y <= -65 && !loading) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(eldestRefreshTableHeaderDidTriggerRefresh:)]) {
            [self.delegate eldestRefreshTableHeaderDidTriggerRefresh:self];
        }
        
        [self setState:EldestPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        [UIView commitAnimations];
    }
}

- (void)eldestRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [UIView commitAnimations];
    
    [self setState:EldestPullRefreshNormal];
}

#pragma mark -
#pragma mark Initializer

- (UILabel *)lastUpdatedLabel {
    if (!_lastUpdatedLabel) {
        _lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 30, CGRectGetWidth(self.frame), 20)];
        _lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _lastUpdatedLabel.font = [UIFont systemFontOfSize:12];
        _lastUpdatedLabel.textColor = TEXT_COLOR;
        _lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9 alpha:1];
        _lastUpdatedLabel.shadowOffset = CGSizeMake(0, 1);
        _lastUpdatedLabel.backgroundColor = [UIColor clearColor];
        _lastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _lastUpdatedLabel;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 48.0f, CGRectGetWidth(self.frame), 20.0f)];
        _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _stateLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _stateLabel.textColor = TEXT_COLOR;
        _stateLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        _stateLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        _stateLabel.backgroundColor = [UIColor clearColor];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _stateLabel;
}

- (CALayer *)arrowImage {
    if (!_arrowImage) {
        _arrowImage = [CALayer layer];
        _arrowImage.frame = CGRectMake(25, CGRectGetHeight(self.frame) - 65, 30, 55);
        _arrowImage.contentsGravity = kCAGravityResizeAspect;
        _arrowImage.contents = (id)[UIImage imageNamed:@"blueArrow"].CGImage;
        _arrowImage.contentsScale = [UIScreen mainScreen].scale;
    }
    return _arrowImage;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(25, CGRectGetHeight(self.frame) - 38, 20, 20)];
    }
    return _activityView;
}

@end

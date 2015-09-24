//
//  EldestPullRefresh.h
//  EldestPullRefresh
//
//  Created by WilliamZhang on 15/9/24.
//  Copyright © 2015年 WilliamZhang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EldestPullRefreshState) {
    EldestPullRefreshPulling = 0,
    EldestPullRefreshNormal,
    EldestPullRefreshLoading,
};

@protocol EldestPullDelegate;

@interface EldestPullRefresh : UIView

@property (nonatomic , weak) id <EldestPullDelegate> delegate;

- (void)refreshLastUpdatedDate;
- (void)eldestRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)eldestRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)eldestRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end

@protocol EldestPullDelegate <NSObject>

- (void)eldestRefreshTableHeaderDidTriggerRefresh:(EldestPullRefresh *)headerView;
- (BOOL)eldestRefreshTableHeaderDataSourceIsLoading:(EldestPullRefresh *)headerView;

@optional
- (NSDate *)eldestRefreshTableHeaderDataSourceLastUpdated:(EldestPullRefresh *)headerView;

@end
//
//  CalendarClass.h
//  MyCalendar
//
//  Created by B1403001 on 2015/8/18.
//  Copyright (c) 2015年 B1403001. All rights reserved.
//
//  coding by Wayne Lai

#import <UIKit/UIKit.h>

@interface CalendarClass : UIView
{
    NSDateComponents *dateComp;
    int year, month;
    float btnYPoint, calendarFontSize;
    float calendarBtnWidth, calendarBtnHeight;
}

@property (nonatomic, weak) UIImage *dayBtnImgNormal;
@property (nonatomic, weak) UIImage *dayBtnImgHighlighted;

//初始化calendar物件
-(id) initWithFrame:(CGRect)frame;
//新增Calendar buttons
-(BOOL) createCalendar;

@end

//
//  CalendarClass.m
//  MyCalendar
//
//  Created by B1403001 on 2015/8/18.
//  Copyright (c) 2015年 B1403001. All rights reserved.
//

#import "CalendarClass.h"

@implementation CalendarClass

@synthesize dayBtnImgNormal, dayBtnImgHighlighted;

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    //NSLog(@"x:%f y:%f w:%f h:%f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    if (self)
    {
        //default day button image
        dayBtnImgNormal = [UIImage imageNamed:@"lightgray"];
        dayBtnImgHighlighted = [UIImage imageNamed:@"highlight"];
        
        //初始year,month,day為當地時區
        dateComp = [CalendarClass getCurrentDate];
        self->year = (int)dateComp.year;
        self->month = (int)dateComp.month;
        
        //取出title view佔掉多少的frame
        CGRect titleFrame = [self createTitleView:self withStartPoint:frame];
        
        //1行7個button
        calendarBtnWidth = frame.size.width / 7;
        //1列6個button
        calendarBtnHeight = (frame.size.height - titleFrame.size.height - 30) / 6 - 1;
        //接下來要顯示label和button的y off set
        btnYPoint = titleFrame.size.height;
        //字型是calendar btn的寬度 x 0.3
        calendarFontSize = calendarBtnWidth * 0.3;
        //NSLog(@"calendarBtnWidth:%f calendarBtnHeight:%f", calendarBtnWidth, calendarBtnHeight);
        
        //顯示"星期"
        [self createDayLabelAt:self withSizePoint:CGPointMake(0, 0)];
        //view的背景色
        [self setBackgroundColor:[UIColor colorWithRed:0.642 green:0.803 blue:0.999 alpha:1.000]];
    }
    
    return self;
}

//取得系統語系
-(NSString *) checkUserDefaultLanguage
{
    NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    return currentLanguage;
}

//取得當地時區
+(NSDateComponents *) getCurrentDate
{
    //建立日期型態
    NSDate *date = [NSDate date];
    //日期格式轉換
    NSInteger flag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComp = [calendar components:flag fromDate:date];
    //NSLog(@"dateComp:%@", dateComp);
    
    return dateComp;
}

#pragma mark Create title view

//設定顯示年份和月份的label, pre, next month button
-(CGRect) createTitleView:(UIView *) view withStartPoint:(CGRect) rect
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height/8)];
    [titleView setTag:100];
    
    //顯示 年, 月
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleView.frame.size.width/2, titleView.frame.size.height)];
    [dateLabel setTag:200];
    [dateLabel setTextColor:[UIColor whiteColor]];
    [dateLabel setFont:[UIFont fontWithName:@"Arial" size:dateLabel.frame.size.width * 0.175]];
    [dateLabel setShadowOffset:CGSizeMake(1, 1)];
    [dateLabel setShadowColor:[UIColor blackColor]];
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    //只判斷中文和英文
    if ([[self checkUserDefaultLanguage] isEqualToString:@"zh-Hant"])
        [dateLabel setText:[NSString stringWithFormat:@"%d年%d月", year, month]];
    else
        [dateLabel setText:[NSString stringWithFormat:@"%d - %d", year, month]];
    
    [titleView addSubview:dateLabel];
    
    //重新計算算pre button所有需要的x座標
    float xoff = dateLabel.frame.origin.x + titleView.frame.size.width / 1.5;
    //顯示 上一個月份的button
    UIButton *pre = [[UIButton alloc] initWithFrame:CGRectMake(xoff, 0, titleView.frame.size.width/6, titleView.frame.size.height)];
    [pre setTag:300];
    [pre setBackgroundImage:[UIImage imageNamed:@"pre"] forState:UIControlStateNormal];
    [pre setBackgroundColor:[UIColor clearColor]];
    [pre addTarget:self action:@selector(preMonth:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:pre];
    
    //重新計算算next button所有需要的x座標
    xoff += titleView.frame.size.width/6;
    //顯示 下一個月份的button
    UIButton *next = [[UIButton alloc] initWithFrame:CGRectMake(xoff, 0, titleView.frame.size.width/6, titleView.frame.size.height)];
    [next setTag:400];
    [next setBackgroundImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [next setBackgroundColor:[UIColor clearColor]];
    [next addTarget:self action:@selector(nextMonth:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:next];
    
    [view addSubview:titleView];
    
    return titleView.frame;
}

//顯示上一個月份
-(void) preMonth:(id) sender
{
    if (--month <= 0)
    {
        year--;
        month = 12;
    }
    
    if ([self refreshCalendar])
    {
        [self createTitleView:self withStartPoint:self.frame];
        [self createCalendar];
    }
    else
        NSLog(@"refresh fail");
}

//顯示下一個月份
-(void) nextMonth:(id) sender
{
    if (++month >= 13)
    {
        year++;
        month = 1;
    }
    
    if ([self refreshCalendar])
    {
        [self createTitleView:self withStartPoint:self.frame];
        [self createCalendar];
    }
    else
        NSLog(@"refresh fail");
}

#pragma mark Create day labels

//設定顯示星期的label
-(void) createDayLabelAt:(UIView *) inView withSizePoint:(CGPoint) point
{
    int i, j;
    float xoff, yoff, xoffTemp, yoffTemp;
    NSArray *dayTemp = [[NSArray alloc] init];
    
    //只判斷中文和英文
    if ([[self checkUserDefaultLanguage] isEqualToString:@"zh-Hant"])
        dayTemp = [NSArray arrayWithObjects:@"日", @"一", @"二", @"三", @"四", @"五", @"六", nil];
    else
        dayTemp = [NSArray arrayWithObjects:@"Sun.", @"Mon.", @"Tue.", @"Wen.", @"Thr.", @"Fri.", @"Sat.", nil];
    
    xoff = xoffTemp = point.x;
    yoff = yoffTemp = btnYPoint;
    
    //設定label
    for (j=0;j!=1;j++)
    {
        for (i=0;i!=7;i++)
        {
            UILabel *week = [[UILabel alloc] init];
            [week setTag:0];
            [week setFrame:CGRectMake(xoff+(i*calendarBtnWidth), yoff, calendarBtnWidth, 30)];
            
            //如果是六或日, 顯示的字體就為紅色, 其他為黑色
            if (i == 0 || i == 6)
                [self setCalendarDayLableAttributes:week txtString:[dayTemp objectAtIndex:i] txtColor:[UIColor redColor] fontSize:calendarFontSize addTo:inView];
            else
                [self setCalendarDayLableAttributes:week txtString:[dayTemp objectAtIndex:i] txtColor:[UIColor whiteColor] fontSize:calendarFontSize addTo:inView];
        }
    }
    
    btnYPoint += 30;
}

//設定月曆表的title view, 顯示年份, 星期,
-(void) setCalendarDayLableAttributes:(UILabel *) uiLabel txtString:(NSString *) string txtColor:(UIColor *) color fontSize:(CGFloat) fSize addTo:(UIView *) rootView
{
    float xoff, yoff;
    xoff = uiLabel.frame.origin.x;
    yoff = uiLabel.frame.origin.y;
    
    [uiLabel setText:string];
    [uiLabel setFont:[UIFont fontWithName:@"Arial" size:fSize]];
    [uiLabel setTextColor:color];
    [uiLabel setShadowOffset:CGSizeMake(1, 1)];
    [uiLabel setShadowColor:[UIColor blackColor]];
    [uiLabel setTextAlignment:NSTextAlignmentCenter];
    [uiLabel setBackgroundColor:[UIColor clearColor]];
    [uiLabel setFrame:CGRectMake(0+xoff, yoff, uiLabel.frame.size.width, uiLabel.frame.size.height)];
    [rootView addSubview:uiLabel];
}

#pragma mark Create calendar buttons

//設定顯示日期的buttons
-(BOOL) createCalendar
{
    int day, weekday;
    int i, j , k;
    const int numberOfDayInMonth [13] = {31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    float xoff = 0.5, yoff = btnYPoint;
    
    //取得使用者時區, 算出每月1號為星期幾
    weekday = (int)[self getWeekdayOfAssignedDate:[NSString stringWithFormat:@"%d-%d-1 0:00:00 +0000", year, month]];
    //判斷當月有多少天數
    k = numberOfDayInMonth[month];
    NSLog(@"此月有%d天", k);
    
    //判斷得到的年份是否為潤年
    if (year % 4 == 0 && month == 2)
        k++;
    
    if (weekday - 1 != 0)
    {
        day = numberOfDayInMonth[month-1] - weekday + 2;
        
        //如果是2月, 又是潤年, 天數必須再加一天
        if ((month -1) == 2 && (year % 4) == 0)
            day++;
        //顯示上個月的尾數天
        for (i=0;i!=weekday-1;i++)
        {
            //新增UIButton
            UIButton *btnTemp1 = [[UIButton alloc] initWithFrame:CGRectMake(xoff+i*calendarBtnWidth, yoff, 40, 37)];
            
            [self setCalendarButtonAttributes:btnTemp1
                                    txtString:[NSString stringWithFormat:@"%d", day++]
                                     txtColor:[UIColor lightGrayColor]
                                     fontSize:calendarFontSize-1];
            [self addSubview:btnTemp1];
            btnTemp1.tag = -1;
            btnTemp1.alpha = 0.9;
        }
    }
    
    //開始月曆UIButton製作- 取出weekday的值並減1, 則可判斷當日為星期幾
    i = (int) weekday - 1;
    NSLog(@"本月1號為星期%d", i);
    
    day = 0;
    
    for (j=0;j<=5;j++)
    {
        for (;i<=6;i++,day++)
        {
            if (day == k)
                break;
            
            //新增UIButton
            UIButton *btnTemp = [[UIButton alloc] initWithFrame:CGRectMake(xoff+i*calendarBtnWidth, yoff, 40, 37)];
            //顯示今日
            if(day+1 == dateComp.day && month == dateComp.month && year == dateComp.year)
            {
                [self setCalendarButtonAttributes:btnTemp
                                        txtString:[NSString stringWithFormat:@"%02d", day+1]
                                        txtColor:[UIColor whiteColor]
                                        fontSize:calendarFontSize];
                [btnTemp setBackgroundImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
            }
            //顯示星期六，日
            else if (i == 0 || i == 6)
            {
                [self setCalendarButtonAttributes:btnTemp
                                        txtString:[NSString stringWithFormat:@"%02d", day+1]
                                        txtColor:[UIColor redColor]
                                        fontSize:calendarFontSize];
                [btnTemp setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            }
            //顯示其他天數
            else
            {
                [self setCalendarButtonAttributes:btnTemp
                                        txtString:[NSString stringWithFormat:@"%02d", day+1]
                                         txtColor:[UIColor blackColor]
                                         fontSize:calendarFontSize];
                [btnTemp setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            }
            
            [btnTemp addTarget:self action:@selector(doSomething:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:btnTemp];
        }
        
        if (day == k)
            break;
        
        i = 0;
        yoff += calendarBtnHeight + 1;
    }
    
    day = 1;
    
    //顯示下個月的頭數天
    for (;i<=6;i++)
    {
        UIButton *btnTemp1 = [[UIButton alloc] initWithFrame:CGRectMake(xoff+i*calendarBtnWidth, yoff, 40, 37)];
        
        [self setCalendarButtonAttributes:btnTemp1
                                txtString:[NSString stringWithFormat:@"%d", day++]
                                txtColor:[UIColor lightGrayColor]
                                fontSize:calendarFontSize];
        [self addSubview:btnTemp1];
        btnTemp1.tag = -2;
        btnTemp1.alpha = 0.9;
    }
    
    return true;
}

//計算出每月的1好為星期幾
-(NSInteger) getWeekdayOfAssignedDate:(NSString *) assignedDate
{
    //獲取該年該月的1號為星期幾
    NSInteger weekday;
    //判斷日期格式
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-1 0:00:00 +0000"];
    NSDate *date = [dateFormater dateFromString:assignedDate];
    
    NSInteger flag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:flag fromDate:date];
    
    //取出1號為星期幾
    weekday = [dateComponents weekday];
    //NSLog(@"weekday:%ld", (long)weekday);
    
    return weekday;
}

//設定月曆表的UIButton 物件的字型、顏色、位置等屬性，並將其顯示在所欲顯示的 view 之上
-(BOOL) setCalendarButtonAttributes:(UIButton *) uiBtn txtString:(NSString *) string txtColor:(UIColor *) color fontSize:(CGFloat) fSize
{
    [uiBtn setFrame:CGRectMake(uiBtn.frame.origin.x, uiBtn.frame.origin.y, self->calendarBtnWidth-1, self->calendarBtnHeight)];
    [uiBtn setBackgroundImage:dayBtnImgNormal forState:UIControlStateNormal];
    [uiBtn setBackgroundImage:dayBtnImgHighlighted forState:UIControlStateHighlighted];
    
#if 0
    [uiBtn setBackgroundColor:[UIColor greenColor]];
#else
    [uiBtn setBackgroundColor:[UIColor clearColor]];
#endif
    [uiBtn setTag:[string intValue]];
    [uiBtn setTitle:string forState:UIControlStateNormal];
    [uiBtn setTitleColor:color forState:UIControlStateNormal];
    [uiBtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [uiBtn.titleLabel setFont:[UIFont fontWithName:@"Arial" size:fSize]];
    [uiBtn.titleLabel setShadowColor:[UIColor blackColor]];
    [uiBtn.titleLabel setShadowOffset:CGSizeMake(1, 1)];
    
    return true;
}

#pragma mark Refresh calendar and button action

//移除所需要更新的title view and label and buttons
-(BOOL) refreshCalendar
{
    for (UIButton *bt in self.subviews)
    {
        if ([bt isKindOfClass:[UIButton class]] && (bt.tag >= -2 && bt.tag < 49))
            [bt removeFromSuperview];
        
        if (bt.tag == 300 || bt.tag ==400)
            [bt removeFromSuperview];
    }
    
    for (UILabel *lb in self.subviews)
    {
        if ([lb isKindOfClass:[UILabel class]] && lb.tag == 200)
            [lb removeFromSuperview];
    }
    
    for (UIView *view in self.subviews)
    {
        if ([view isKindOfClass:[UIView class]] && view.tag == 100)
            [view removeFromSuperview];
    }
    return YES;
}

#pragma mark Select day(button) action

-(void) doSomething:(UIButton *) btn
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Date"
                                                    message:[NSString stringWithFormat:@"%d-%d-%d", year, month, (int)btn.tag]
                                                   delegate:nil
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [alert show];
}

@end

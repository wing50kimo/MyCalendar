//
//  ViewController.m
//  MyCalendar
//
//  Created by B1403001 on 2015/8/18.
//  Copyright (c) 2015年 B1403001. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    CalendarClass *calendar = [[CalendarClass alloc] initWithFrame:CGRectMake(0,
                                                                              [UIScreen mainScreen].bounds.size.height/2,
                                                                              [UIScreen mainScreen].bounds.size.width,
                                                                              [UIScreen mainScreen].bounds.size.height/2)];
    
    //CalendarClass *calendar = [[CalendarClass alloc] initWithFrame:CGRectMake(0,20, 200, 200)];
    
    [self.view addSubview:calendar];
    
    [calendar createCalendar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ViewController.m
//  Demo
//
//  Created by  高东星 on 17/9/8.
//  Copyright © 2017年  高东星. All rights reserved.
//

#import "ViewController.h"
#import "RTSerializer.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    RTSerializer * serializer=[[RTSerializer alloc]init];
    
    NSMutableDictionary *pack=[NSMutableDictionary dictionary];
    [pack setValue:@"id" forKey:@"3"];
    [pack setValue:@"tariffid" forKey:@"152"];
    [pack setValue:@"rgid" forKey:@"1"];
    [pack setValue:@"name" forKey:@"Test"];
    
    NSMutableDictionary *data=[NSMutableDictionary dictionary];
    [data setValue:@"123" forKey:@"username"];
    [data setValue:@"456" forKey:@"password"];
    [data setValue:@"name"forKey:@"name"];
    [data setValue:@"country" forKey:@"country"];
    [data setValue:@"email" forKey:@"email_address"];
    [data setValue:pack forKey:@"package"];
    NSString *str = @"";
    str = [serializer  serialize:data inString:str];
    
    NSLog(@"%@",str);
    
    
    
    RTSerializer *anotherSerializer= [[RTSerializer alloc]init];
    id object=[anotherSerializer deserialize:@"a:1:{i:0;a:4:{s:2:\"id\";s:1:\"3\";s:8:\"tariffid\";s:3:\"152\";s:4:\"rgid\";s:1:\"1\";s:4:\"name\";s:4:\"Test\";}}"withStringEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",object);
}

@end

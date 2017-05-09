//
//  ViewController.m
//  套接字
//
//  Created by Qianrun on 16/8/18.
//  Copyright © 2016年 qianrun. All rights reserved.
//

#import "ViewController.h"
#import "CDEchoClient.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITextField *msgField;
@property (strong, nonatomic) IBOutlet UILabel *echoMsgLabel;

- (IBAction)sendAction:(UIButton *)sender;

- (IBAction)handOfTap:(UITapGestureRecognizer *)sender;
@end

@implementation ViewController {
    CDEchoClient *client;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    client = [[CDEchoClient alloc] initWithAddress:@"14.17.103.3" port:9808];
}

- (IBAction)sendAction:(UIButton *)sender {
    
    NSLog(@"......client:%@, error:%ld", client, client.errorCode);
    
    // 发送bye消息会断开与服务器的连接 不能再发送消息
    if (client && client.errorCode == NoError) {
        NSString *msg = [self.msgField.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceCharacterSet]];
        if (msg.length > 0) {
            [self.msgField resignFirstResponder];
            self.echoMsgLabel.text = [client sendMessage:msg];
        }
    }
    else {
        NSLog(@"Cannot send message!!!");
    }
}

- (IBAction)handOfTap:(UITapGestureRecognizer *)sender {
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
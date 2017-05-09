//
//  main.m
//  套接字2
//
//  Created by Qianrun on 16/8/18.
//  Copyright © 2016年 qianrun. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

static const short SERVER_PORT = 1234;  // 端口
static const int MAX_Q_LEN = 64;        // 最大队列长度
static const int MAX_MSG_LEN = 1;    // 最大消息长度

void change_enter_to_tail_zero(char * const buffer, int pos) {
    for (int i = pos - 1; i >= 0; i--) {
        if (buffer[i] == '\r') {
            buffer[i] = '\0';
            break;
        }
    }
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        
        // 1. 调用socket函数创建套接字
        // 第一个参数指定使用IPv4协议进行通信(AF_INET6代表IPv6)
        // 第二个参数指定套接字的类型(SOCK_STREAM代表可靠的全双工通信)
        // 第三个参数指定套接字使用的协议
        // 如果返回值是-1表示创建套接字时发生错误 否则返回服务器套接字文件描述符
        int serverSocketFD = socket(AF_INET, SOCK_STREAM, 0);
        if (serverSocketFD < 0) {
            perror("无法创建套接字!!!\n");
            exit(1);
        }
        
        // 代表服务器地址的结构体
        struct sockaddr_in serverAddr;
        serverAddr.sin_family = AF_INET;
        serverAddr.sin_port = htons(SERVER_PORT);
        serverAddr.sin_addr.s_addr = htonl(INADDR_ANY);
        
        // 2. 将套接字绑定到指定的地址和端口
        // 第一个参数指定套接字文件描述符
        // 第二个参数是上面代表地址的结构体变量的地址
        // 第三个参数是上面代表地址的结构体占用的字节数
        // 如果返回值是-1表示绑定失败
        int ret = bind(serverSocketFD, (struct sockaddr *)&serverAddr,
                       sizeof serverAddr);
        if (ret < 0) {
            perror("无法将套接字绑定到指定的地址!!!\n");
            close(serverSocketFD);
            exit(1);
        }
        
        // 3. 开启监听(监听客户端的连接)
        ret = listen(serverSocketFD, MAX_Q_LEN);
        if (ret < 0) {
            perror("无法开启监听!!!\n");
            close(serverSocketFD);
            exit(1);
        }
        
        bool serverIsRunning = true;
        while(serverIsRunning) {
            // 代表客户端地址的结构体
            struct sockaddr_in clientAddr;
            socklen_t clientAddrLen = sizeof clientAddr;
            // 4. 接受客户端的连接(从队列中取出第一个连接请求)
            // 如果返回-1表示发生错误 否则返回客户端套接字文件描述符
            // 该方法是一个阻塞方法 如果队列中没有连接就会一直阻塞
            int clientSocketFD = accept(serverSocketFD,
                                        (struct sockaddr *)&clientAddr, &clientAddrLen);
            bool clientConnected = true;
            if (clientSocketFD < 0) {
                perror("接受客户端连接时发生错误!!!\n");
                clientConnected = false;
            }
            
            while (clientConnected) {
                // 接受数据的缓冲区
                char buffer[MAX_MSG_LEN + 1];
                // 5. 接收客户端发来的数据
                ssize_t bytesToRecv = recv(clientSocketFD, buffer,
                                           sizeof buffer - 1, 0);
                if (bytesToRecv > 0) {
                    buffer[bytesToRecv] = '\0';
                    change_enter_to_tail_zero(buffer, (int)bytesToRecv);
                    printf("%s\n", buffer);
                    // 如果收到客户端发来的bye消息服务器主动关闭
                    if (!strcmp(buffer, "bye\r\n")) {
                        serverIsRunning = false;
                        clientConnected = false;
                    }
                    // 6. 将消息发回到客户端
                    ssize_t bytesToSend = send(clientSocketFD, buffer,
                                               bytesToRecv, 0);
                    if (bytesToSend > 0) {
                        printf("Echo message has been sent.\n");
                    }
                }
                else {
                    printf("client socket closed!\n");
                    clientConnected = false;
                }    
            }
            // 7. 关闭客户端套接字
            close(clientSocketFD);
        }
        // 8. 关闭服务器套接字
        close(serverSocketFD);
    }
    return 0;
}

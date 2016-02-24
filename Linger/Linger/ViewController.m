//
//  ViewController.m
//  Linger
//
//  Created by 杨萧玉 on 16/2/23.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController()
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSTextField *ruleContent;
@property (nonatomic,nonnull) NSTask *filter;
@property (weak) IBOutlet NSMatrix *rule;
@property (copy,nonnull) NSURL *fileURL;
@property (weak) IBOutlet NSTextField *beginLine;
@property (weak) IBOutlet NSTextField *endLine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)clickRadioButton:(NSMatrix *)sender {
    
}

- (IBAction)openLog:(NSButton *)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setPrompt: @"打开"];
    
    openPanel.allowedFileTypes = [NSArray arrayWithObjects: @"log", nil];
    openPanel.directoryURL = nil;
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode == 1) {
            self.fileURL = [[openPanel URLs] objectAtIndex:0];
            // 获取文件内容
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:self.fileURL error:nil];
            NSString *fileContext = [[NSString alloc] initWithData:fileHandle.readDataToEndOfFile encoding:NSUTF8StringEncoding];
            
            // 将 获取的数据传递给 ViewController 的 TextView
            self.textView.string = fileContext;
        }
    }];
}

- (IBAction)processLog:(NSButton *)sender {
    _filter = [[NSTask alloc] init];
    _filter.launchPath = @"/bin/sh";
    NSString *beginCmd = @"";
    NSString *endCmd = @"";
    if ([self.endLine.stringValue integerValue] > 0) {
        endCmd = [NSString stringWithFormat:@" | head -n %ld",(long)[self.endLine.stringValue integerValue]];
    }
    if ([self.beginLine.stringValue integerValue] > 0) {
        beginCmd = [NSString stringWithFormat:@" | tail -n +%ld",(long)[self.beginLine.stringValue integerValue]];
    }
    NSString *ruleCmd;
    if ([self.rule.selectedCell.title isEqualToString:@"包含"]) {
        ruleCmd = @" ";
    }
    else if ([self.rule.selectedCell.title isEqualToString:@"排除"]) {
        ruleCmd = @" -v ";
    }
    NSString *command = [NSString stringWithFormat:@"cat %@%@%@ | grep%@%@",[self.fileURL.absoluteString substringFromIndex:7],beginCmd,endCmd,ruleCmd,self.ruleContent.stringValue];
    _filter.arguments = @[@"-c",command];
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [_filter setStandardOutput: pipe];   //设置输出参数
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];   // 句柄
    [_filter launch];
    NSData *data;
    data = [file readDataToEndOfFile];  // 读取数据
    
    NSString *string = [[NSString alloc] initWithData: data
                                             encoding: NSUTF8StringEncoding];
    self.textView.string = string;
}
@end

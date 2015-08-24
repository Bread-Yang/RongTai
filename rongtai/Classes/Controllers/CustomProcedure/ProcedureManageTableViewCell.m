//
//  ProcedureManageTableViewCell.m
//  rongtai
//
//  Created by William-zhang on 15/6/19.
//  Copyright (c) 2015年 William-zhang. All rights reserved.
//

#import "ProcedureManageTableViewCell.h"
#import "CustomProgram.h"
#import "IQKeyboardManager.h"
#import "CoreData+MagicalRecord.h"

@interface ProcedureManageTableViewCell ()<UIAlertViewDelegate>
{
    UIButton* _btn;
    UIView* _line;
}
@end

@implementation ProcedureManageTableViewCell


- (void)awakeFromNib {
    // Initialization code
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    _btn.frame = CGRectMake(0.1*w, 0.15*h, 0.4*w, 0.7*h);
    _line.frame = CGRectMake(0, h-0.5, w, 0.5);
}

-(void)setCustomProgram:(CustomProgram *)customProgram
{
    _customProgram = customProgram;
    [_btn setTitle:_customProgram.name forState:UIControlStateNormal];
}

-(void)setIsEdit:(BOOL)isEdit
{
    _isEdit = isEdit;
    if (_isEdit) {
        _btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _btn.layer.borderWidth = 0.5;
    }
    else
    {
        _btn.layer.borderColor = [UIColor clearColor].CGColor;
    }
}


#pragma mark - 初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        _btn = [[UIButton alloc]initWithFrame:CGRectMake(0.1*w, 0.15*h, 0.4*w, 0.7*h)];
//        _btn.backgroundColor = [UIColor redColor];
        [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(clickName) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btn];
        
        _line = [[UIView alloc]initWithFrame:CGRectMake(0, h-0.5, w, 0.5)];
        _line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_line];
    }
    return self;
}

#pragma mark - 点击名称方法
-(void)clickName
{
    if (_isEdit) {
        IQKeyboardManager* m = [IQKeyboardManager sharedManager];
        [m setEnable:NO];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"名称", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"保存", nil), nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.delegate = self;
        UITextField* textFeile = [alert textFieldAtIndex:0];
        textFeile.text = _customProgram.name;
        [alert show];

    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    IQKeyboardManager* m = [IQKeyboardManager sharedManager];
    [m setEnable:YES];
    if (buttonIndex == 1) {
        CustomProgram* c = [CustomProgram MR_findByAttribute:@"name" withValue:_customProgram.name][0];
        UITextField* textFeile = [alertView textFieldAtIndex:0];
        c.name = textFeile.text;
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
    if ([self.delegate respondsToSelector:@selector(cellDidFinishedChangeName:)]) {
        [self.delegate cellDidFinishedChangeName:self];
    }
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UITextField* textFeile = [alertView textFieldAtIndex:0];
    if (textFeile.text.length>0) {
        return YES;
    }
    else
    {
        return NO;
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

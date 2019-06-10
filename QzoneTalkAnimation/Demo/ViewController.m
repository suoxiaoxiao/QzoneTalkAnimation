//
//  ViewController.m
//  Demo
//
//  Created by 索晓晓 on 16/9/30.
//  Copyright © 2016年 SXiao.RR. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+RefreshSingleRow.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic ,strong)NSMutableArray *dataArray;

@end

@implementation ViewController

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(40,64, 200, 40)];
    [btn setTitle:@"测试" forState:0];
    [btn setTitleColor:[UIColor whiteColor] forState:0];
    [btn addTarget:self action:@selector(ceshiaddDataRefreshTable) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:btn];
    
    
    
    for (int i = 20; i > 0; i--) {
        
        [self.dataArray addObject:[NSString stringWithFormat:@"第%d个cell",i]];
    }
   
    self.tableView = [[UITableView alloc] initWithFrame:(CGRect){{0,200},{self.view.frame.size.width ,self.view.frame.size.height - 200}} style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
    
    [self.view addSubview:self.tableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            
            [cell setSeparatorInset:UIEdgeInsetsZero];
            
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            
            [cell setLayoutMargins:UIEdgeInsetsZero];
            
        }
    }
    
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [UIColor redColor];
    
    return cell;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)ceshiaddDataRefreshTable
{
    [self.dataArray insertObject:[NSString stringWithFormat:@"第%ld个cell",self.dataArray.count + 1]atIndex:0];
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    self.tableView.coefficient = @(0.1);
    [self.tableView insertRowsAtIndexPaths:@[index] withRowCustomAnimation:TableViewRowAnimation3DInsertMode];
}

@end

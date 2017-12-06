//
//  FFBlackListVC.m
//  SmartMesh
//
//  Created by Megan on 2017/10/13.
//  Copyright © 2017年 SmartMesh Foundation All rights reserved.
//

#import "FFBlackListVC.h"
#import "FFContactCell.h"

@interface FFBlackListVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView    * tableView;
@property(nonatomic,assign) NSInteger        page;
@property(nonatomic,strong) NSMutableArray * listArray;
@property(nonatomic,strong) UILabel        * emptyLabel;

@end

@implementation FFBlackListVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadBlackListData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Blacklist";
    
    self.page = 0;
    
    _listArray = [NSMutableArray array];

}

-(void)buildUI
{
    _tableView = [[UITableView alloc] initWithFrame:LC_RECT(0, 64, DDYSCREENW, DDYSCREENH)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    self.view.backgroundColor = LC_RGB(245, 245, 245);
    _tableView.backgroundColor = LC_RGB(245, 245, 245);
    
//    [self setupRefresh];
}

#pragma mark - setupRefresh
- (void)setupRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

-(void)showEmptyTips
{
    _emptyLabel = [[UILabel alloc] initWithFrame:LC_RECT(10, 0, DDYSCREENW - 20, 20)];
    _emptyLabel.viewCenterY = DDYSCREENH*0.5;
    _emptyLabel.text = @"暂无数据";
    _emptyLabel.textColor = LC_RGB(51, 51, 51);
    _emptyLabel.font = NA_FONT(15);
    _emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_emptyLabel];
}

-(void)pushUserInfoViewController
{
    
}

#pragma mark TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FFContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseRegionCell"];
    
    if (!cell) {
        cell = [[FFContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChooseRegionCell"];
    }
    
    cell.type = FFBlackUserType;
    cell.user = self.listArray[indexPath.row];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FFUser * user= [self.listArray objectAtIndex:indexPath.row];
//    [self pushUserInfoViewController:user];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"解除黑名单";
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FFUser * user = self.listArray[indexPath.row];
    [self requestRemoveBlackFriend:user.localid];
}

#pragma mark -

-(void) requestRemoveBlackFriend:(NSString *)localID
{
    NSDictionary * params = @{@"blocalid":localID};
    
    [NANetWorkRequest na_postDataWithService:@"blacklist" action:@"remove_black_list" parameters:params results:^(BOOL status, NSDictionary *result) {
        
        if (status) {
            
            for (FFUser * user in self.listArray) {
                
                if ([localID integerValue] == [user.localid integerValue])
                {
                    [self.listArray removeObject:user];
                    break;
                }
            }
            
            [self.tableView reloadData];
        }
        else
        {
            if ([result objectForKey:@"errcode"] !=0) {
                
                NSLog(@"==网络异常==");
            }
        }
        
    }];
}

- (void)loadBlackListData
{
    NSInteger page = _page + 1;
    
    NSDictionary * params = @{@"page":@(page)};
    
    [NANetWorkRequest na_postDataWithService:@"blacklist" action:@"black_list" parameters:params results:^(BOOL status, NSDictionary *result) {
        
        if (status) {
            
            self->_page = page;
            
            NSArray * data = [result objectForKey:@"data"];
            NSMutableArray * temp = [NSMutableArray array];
            for (NSDictionary * dict in data) {
                
                FFUser * user = [FFUser userWithDict:dict];
                [temp addObject:user];
            }
            
            _listArray = temp;
            _emptyLabel.hidden = _listArray.count == 0 ? NO : YES;
            
            NSLog(@"===黑名单请求数据成功====");
            [self.tableView reloadData];
        }
        else
        {
            
        }
        
    } ];
}

@end

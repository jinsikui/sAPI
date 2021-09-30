//
//  MainViewController.m
//  xLib
//
//  Created by JSK on 2019/9/23.
//  Copyright © 2019 JSK. All rights reserved.
//

#import "MainViewController.h"
#import "sAPI.h"
#import "Masonry.h"


@interface MainViewController ()
@property(nonatomic,strong) UIScrollView *scroll;
@property (nonatomic, assign) CGFloat currentY;

@end

@implementation MainViewController

#pragma mark - life circle
- (instancetype)init {
    if (self = [super init]) {
        self.currentY = 30;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self setupUI];
}

#pragma mark - UI func
- (void)setupUI {
    self.title = @"sAPI Test";
    self.view.backgroundColor = UIColor.whiteColor;
    _scroll = [[UIScrollView alloc] init];
    _scroll.alwaysBounceVertical = true;
    [self.view addSubview:_scroll];
    [_scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self addBtn:@"api ret json" selector:@selector(actionJson)];
    [self addBtn:@"api ret http" selector:@selector(actionHttp)];
    
    _scroll.contentSize = CGSizeMake(0, self.currentY);
}

-(UIButton *)addBtn:(NSString*)text selector:(SEL)selector{
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState: UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];;
    btn.backgroundColor = UIColor.clearColor;
    btn.layer.borderWidth = 0.5f;
    btn.layer.borderColor = UIColor.blackColor.CGColor;
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0.5 * ([UIScreen mainScreen].bounds.size.width - 200), self.currentY, 200, 40);
    [self.scroll addSubview:btn];
    self.currentY += 50;
    return btn;
}

#pragma mark - Actions

-(void)actionJson {
    sAPI.host(@"https://sss.qingting.fm")
    .method(HTTP_GET)
//    .decodingType(sResponseDecncodingJSON) // default decodingType, the ret data will be JSON object
    .path(@"/pms/config/priv/lv.json")
    .execute().then(^id(NSDictionary *ret) {
        //using API result here...
        NSLog(@"===== %@ =====", ret);
        return nil;
    }).catch(^(NSError *error) {
        NSLog(@"%@", error);
    });
}
    
-(void)actionHttp {
    sAPI.host(@"https://www.baidu.com")
    .method(HTTP_GET)
    .path(@"/")
    .decodingType(sResponseDecncodingHTTP) // the ret data will be original NSData
    .execute().then(^id(NSData *ret) {
        //using API result here...
        NSString *strRet = [[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding];
        NSLog(@"===== %@ =====", strRet);
        return nil;
    }).catch(^(NSError *error) {
        NSLog(@"%@", error);
    });
}

@end

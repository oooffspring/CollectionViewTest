//
//  ViewController.m
//  CollectionViewTest
//
//  Created by xiezilong on 6/6/13.
//  Copyright (c) 2013 xiezilong. All rights reserved.
//

#import "ViewController.h"
#import "CollectionLayout.h"
#import "CustomCollectionViewCell.h"
#import "RXMLElement.h"
#import "BasicLayoutItem.h"
#import "ILSPolygonImagesView.h"

@interface ViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *basicLayoutArray;
@property (nonatomic, strong) ILSPolygonImagesView *polygonView;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CollectionLayout *flowLayout = [[CollectionLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, 320, 320) collectionViewLayout:flowLayout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor redColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.pagingEnabled = YES;
    [self.view addSubview:self.collectionView];
    [self parseXML];
    self.polygonView = [[ILSPolygonImagesView alloc] initWithFrame:CGRectMake(10, 30, 300, 300)];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.backButton addTarget:self action:@selector(presentCollectionView) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setFrame:CGRectMake(100, 350, 120, 40)];
    
    [self.view addSubview:self.backButton];
    self.backButton.hidden = YES;
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)presentCollectionView
{
    self.backButton.hidden = YES;
    self.polygonView.hidden = YES;
    [UIView animateWithDuration:.4 animations:^{
        self.collectionView.center = CGPointMake(self.collectionView.center.x + 320, self.collectionView.center.y);
    }];
}

- (void)parseXML
{
    RXMLElement *rootXML = [RXMLElement elementFromXMLFile:@"layout.xml"];
    
    self.basicLayoutArray = [NSMutableArray arrayWithCapacity:100];
    
    [rootXML iterate:@"BasicLayout.layout" usingBlock:^(RXMLElement *layout){
        //解析layout 初始化layoutItem
        BasicLayoutItem *basicLayoutItem = [[BasicLayoutItem alloc] initWithIndex:[layout attribute:@"num"].integerValue NumbersOfSlots:[layout attribute:@"numberOfSlots"].integerValue Type:[layout attribute:@"type"] PointsString:[layout attribute:@"points"] SlotsString:[layout attribute:@"slots"] PolygonString:[layout attribute:@"polygons"]];
        [self.basicLayoutArray addObject:basicLayoutItem];
    }];
    
    for (BasicLayoutItem *item in self.basicLayoutArray) {
        NSLog(@"index:%d numberOfSlots:%d type:%@ point:%@ slots:%@", item.index, item.numberOfSlots, item.type, item.pointsString, item.slotsString);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark collection delegate method

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 120;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.label.text = [NSString stringWithFormat:@"%d", indexPath.row];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 10, 20, 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(60, 60);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger randomNumber = arc4random() % 5;
    UIColor *color;
    switch (randomNumber) {
        case 0:
            color = [UIColor whiteColor];
            break;
        case 1:
            color = [UIColor blackColor];
            break;
        case 2:
            color = [UIColor blueColor];
            break;
        case 3:
            color = [UIColor orangeColor];
            break;
        case 4:
            color = [UIColor grayColor];
            break;
            
        default:
            break;
    }
    self.collectionView.backgroundColor = color;
    
    if ([((BasicLayoutItem*)self.basicLayoutArray[indexPath.row]).type isEqualToString:@"basic"]) {
        [self.polygonView setupSlotsWithString:((BasicLayoutItem *)self.basicLayoutArray[indexPath.row]).slotsString];
    }
    else
    {
        [self.polygonView setupSlotsWithString:((BasicLayoutItem *)self.basicLayoutArray[indexPath.row]).polygonString];
    }
    [self.polygonView setupVertexWithString:((BasicLayoutItem *)self.basicLayoutArray[indexPath.row]).pointsString];
    [self.polygonView setupSubViewsForPolygons];

    [UIView animateWithDuration:.4 animations:^{
        self.collectionView.center = CGPointMake(self.collectionView.center.x - 320, self.collectionView.center.y);
    } completion:^(BOOL finished){
        [self.view addSubview:self.polygonView];
        self.polygonView.hidden = NO;
        self.backButton.hidden = NO;
    }];
    
}


@end

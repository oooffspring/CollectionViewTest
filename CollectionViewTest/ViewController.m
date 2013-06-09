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


@interface ViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *basicLayoutArray;

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
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)parseXML
{
    RXMLElement *rootXML = [RXMLElement elementFromXMLFile:@"layout.xml"];
    
    self.basicLayoutArray = [NSMutableArray arrayWithCapacity:100];
    
    [rootXML iterate:@"BasicLayout.layout" usingBlock:^(RXMLElement *layout){
        //解析layout 初始化layoutItem
        BasicLayoutItem *basicLayoutItem = [[BasicLayoutItem alloc] initWithIndex:[layout attribute:@"num"].integerValue NumbersOfSlots:[layout attribute:@"numberOfSlots"].integerValue Type:[layout attribute:@"type"] PointsString:[layout attribute:@"points"] SlotsString:[layout attribute:@"slots"]];
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
    return 40;
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
}


@end

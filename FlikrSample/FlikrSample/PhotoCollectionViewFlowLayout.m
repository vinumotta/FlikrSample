//
//  PhotoCollectionViewFlowLayout.m
//  FlikrSample
//
//  Created by Vineet Sathyan on 2/1/16.
//  Copyright © 2016 vinumotta. All rights reserved.
// https://www.objc.io/issues/12-animations/collectionview-animations/

#import "PhotoCollectionViewFlowLayout.h"

@interface PhotoCollectionViewFlowLayout()
@property (nonatomic) CGSize previousSize;
@property (nonatomic, strong) NSMutableArray *indexPathsToAnimate;

@property (nonatomic, strong) NSIndexPath *pinchedItem;
@property (nonatomic) CGSize pinchedItemSize;

@end

@implementation PhotoCollectionViewFlowLayout

- (void)commonInit
{
    self.itemSize = CGSizeMake(50, 50);
    self.minimumLineSpacing = 16;
    self.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    NSArray *attrs = [super layoutAttributesForElementsInRect:rect];
    
    if (_pinchedItem) {
        UICollectionViewLayoutAttributes *attr = [[attrs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath == %@", _pinchedItem]] firstObject];
        
        attr.size = _pinchedItemSize;
        attr.zIndex = 100;
    }

    return attrs;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    if ([indexPath isEqual:_pinchedItem]) {
        attr.size = _pinchedItemSize;
        attr.zIndex = 100;
    }
    
    return attr;
}

- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    if ([_indexPathsToAnimate containsObject:itemIndexPath]) {
        attr.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.2, 0.2), M_PI);
        attr.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMaxY(self.collectionView.bounds));
        [_indexPathsToAnimate removeObject:itemIndexPath];
    }
    
    return attr;
}

- (UICollectionViewLayoutAttributes*)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    if ([_indexPathsToAnimate containsObject:itemIndexPath]) {
        
        CATransform3D flyUpTransform = CATransform3DIdentity;
        flyUpTransform.m34 = 1.0 / -20000;
        flyUpTransform = CATransform3DTranslate(flyUpTransform, 0, 0, 19500);
        attr.transform3D = flyUpTransform;
        attr.center = self.collectionView.center;
        
        attr.alpha = 0.2;
        attr.zIndex = 1;
        
        [_indexPathsToAnimate removeObject:itemIndexPath];
    }
    else{
        attr.alpha = 1.0;
    }
    
    return attr;
}

- (void)prepareLayout
{
    [super prepareLayout];
    self.previousSize = self.collectionView.bounds.size;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        switch (updateItem.updateAction) {
            case UICollectionUpdateActionInsert:
                [indexPaths addObject:updateItem.indexPathAfterUpdate];
                break;
            case UICollectionUpdateActionDelete:
                [indexPaths addObject:updateItem.indexPathBeforeUpdate];
                break;
            case UICollectionUpdateActionMove:
                [indexPaths addObject:updateItem.indexPathBeforeUpdate];
                [indexPaths addObject:updateItem.indexPathAfterUpdate];
                break;
            default:
                NSLog(@"unhandled case: %@", updateItem);
                break;
        }
    }
    
    self.indexPathsToAnimate = indexPaths;
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    self.indexPathsToAnimate = nil;
}

- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds
{
    [super prepareForAnimatedBoundsChange:oldBounds];
}

- (void)finalizeAnimatedBoundsChange {
    [super finalizeAnimatedBoundsChange];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    if (!CGSizeEqualToSize(oldBounds.size, newBounds.size)) {
        return YES;
    }
    return NO;
}


- (void)resizeItemAtIndexPath:(NSIndexPath*)indexPath withPinchDistance:(CGFloat)distance
{
    self.pinchedItem = indexPath;
    self.pinchedItemSize = CGSizeMake(distance, distance);
    
}

- (void)resetPinchedItem
{
    self.pinchedItem = nil;
    self.pinchedItemSize = CGSizeZero;
}


@end

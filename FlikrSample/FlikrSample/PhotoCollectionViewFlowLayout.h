//
//  PhotoCollectionViewFlowLayout.h
//  FlikrSample
//
//  Created by Vineet Sathyan on 2/1/16.
//  Copyright © 2016 vinumotta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewFlowLayout : UICollectionViewFlowLayout
- (void)resizeItemAtIndexPath:(NSIndexPath*)indexPath withPinchDistance:(CGFloat)distance;
- (void)resetPinchedItem;
@end

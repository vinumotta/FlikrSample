//
//  PhotoCollectionViewCell.h
//  FlikrSample
//
//  Created by Vineet Sathyan on 1/31/16.
//  Copyright © 2016 vinumotta. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FlickrPhoto;

@interface PhotoCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) FlickrPhoto *photo;
@end

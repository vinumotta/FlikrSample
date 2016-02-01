//
//  PhotoCollectionViewCell.m
//  FlikrSample
//
//  Created by Vineet Sathyan on 1/31/16.
//  Copyright © 2016 vinumotta. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "FlickrPhoto.h"

@implementation PhotoCollectionViewCell

-(void)setPhoto:(FlickrPhoto *)photo {
    
    if(_photo != photo) {
        _photo = photo;
    }
    self.imageView.image = _photo.thumbnail;
}

@end

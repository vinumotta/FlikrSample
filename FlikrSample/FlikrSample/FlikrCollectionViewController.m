//
//  FlikrCollectionViewController.m
//  FlikrSample
//
//  Created by Vineet Sathyan on 1/31/16.
//  Copyright © 2016 vinumotta. All rights reserved.
//

#import "FlikrCollectionViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"
#import "PhotoCollectionViewCell.h"
#import "PhotoCollectionViewFlowLayout.h"

@interface FlikrCollectionViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSMutableDictionary *photoResults;
@property (nonatomic, strong) NSMutableArray *searches;
@property (nonatomic, strong) Flickr *flickr;
@property (nonatomic, strong) UIPinchGestureRecognizer *pincher;
@property (nonatomic, strong) CAGradientLayer *gradient;
@end

@implementation FlikrCollectionViewController

static NSString * const reuseIdentifier = @"FlickrCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.searches = [@[] mutableCopy];
    self.photoResults = [@{} mutableCopy];
    self.flickr = [[Flickr alloc] init];
    
    self.pincher = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    
    [self.collectionView addGestureRecognizer:_pincher];
    
    [self.flickr loadPublicFeedWithCompletionBlock:^(NSArray *results, NSError *error) {
        if(results && [results count] > 0) {
            
            [self.searches insertObject:@"" atIndex:0];
            self.photoResults[@""] = results;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } else {
            NSLog(@"Error searching Flickr: %@", error.localizedDescription);
        }
    }];
    
}

-(void)viewDidLayoutSubviews {
    [self addGradientBackground];
}

- (void)addGradientBackground {
    if (!self.gradient) {
        self.gradient = [CAGradientLayer layer];
    }
    
    self.gradient .frame = self.view.bounds;
    UIColor *darkColor =
    [UIColor colorWithRed:0.62f green:0.4f blue:0.42f alpha:1.0];
    UIColor *lightColor =
    [UIColor colorWithRed:0.43f green:0.76f blue:0.07f alpha:1.0];
    self.gradient .colors = [NSArray arrayWithObjects:(id)[lightColor CGColor], (id)[darkColor CGColor], nil];
    [self.view.layer insertSublayer:self.gradient atIndex:0];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)sender {
    if ([sender numberOfTouches] != 2)
        return;
    
    if (sender.state == UIGestureRecognizerStateBegan ||
        sender.state == UIGestureRecognizerStateChanged) {
        
        CGPoint p1 = [sender locationOfTouch:0 inView:[self collectionView]];
        CGPoint p2 = [sender locationOfTouch:1 inView:[self collectionView]];
        
        CGFloat xd = p1.x - p2.x;
        CGFloat yd = p1.y - p2.y;
        CGFloat distance = sqrt(xd*xd + yd*yd);
        
        PhotoCollectionViewFlowLayout* layout = (PhotoCollectionViewFlowLayout*)[[self collectionView] collectionViewLayout];
        
        NSIndexPath *pinchedItem = [self.collectionView indexPathForItemAtPoint:CGPointMake(0.5*(p1.x+p2.x), 0.5*(p1.y+p2.y))];
        [layout resizeItemAtIndexPath:pinchedItem withPinchDistance:distance];
        [layout invalidateLayout];
        
    }
    else if (sender.state == UIGestureRecognizerStateCancelled ||
             sender.state == UIGestureRecognizerStateEnded){
        PhotoCollectionViewFlowLayout* layout = (PhotoCollectionViewFlowLayout*)[[self collectionView] collectionViewLayout];
        [self.collectionView
         performBatchUpdates:^{
             [layout resetPinchedItem];
         }
         completion:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionViewLayout invalidateLayout];
}

-(void)presentAlertViewForTitle:(NSString*)title message:(NSString *)message {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark - UITextFieldDelegate methods
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self.flickr searchFlickrForTerm:textField.text completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
        if(results) {
            if ([results count] == 0) {
                [self presentAlertViewForTitle:@"No Results" message:@"Try another tag"];
            }
            if(![self.searches containsObject:searchTerm]) {
                
                [self.searches insertObject:searchTerm atIndex:0];
                self.photoResults[searchTerm] = results; }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } else {
            NSLog(@"Error searching Flickr: %@", error.localizedDescription);
        } }];
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSString *searchTerm = self.searches[section];
    return [self.photoResults[searchTerm] count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return [self.searches count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSString *searchTerm = self.searches[indexPath.section];
    cell.photo = self.photoResults[searchTerm]
    [indexPath.row];
    return cell;
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *searchTerm = self.searches[indexPath.section]; FlickrPhoto *photo =
    self.photoResults[searchTerm][indexPath.row];
    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
    retval.height += 35; retval.width += 35; return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

@end

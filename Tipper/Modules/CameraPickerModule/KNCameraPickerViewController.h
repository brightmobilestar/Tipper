//
//  KNCameraPickerTemplateViewController.h
//  EverAfter
//
//  Created by Jianying Shi on 6/20/14.
//
//
//  Interface of template view controller which has camera picker feature and image view for preview.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol KNCameraPickerViewControllerDelegate<NSObject>

@optional
-(void)didSelectedImage:(UIImage *)image;
@end

@interface KNCameraPickerViewController:UIViewController <UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIToolbar *controlsToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *changeCameraButton;

// preview image view
@property(nonatomic,weak)IBOutlet UIImageView* preview;

// method to get image file name to save it.
- (NSString*) generateImageName;

// callback when taken image
- (void) onImagePicked:(UIImage*) image;

// path of current image.
@property(nonatomic,strong) NSString* currentImagePath;

// Set type of camera will be used, default rear camare
@property(nonatomic) BOOL isFrontCameraUsed;

-(IBAction)launchCamera:(id)sender;

@property(nonatomic)id<NSObject, KNCameraPickerViewControllerDelegate>delegate;
@end

//
//  KNCameraPickerTemplateViewController.m
//  EverAfter
//
//  Created by Jianying Shi on 6/20/14.
//
//

#import "KNCameraPickerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "Tipper-Swift.h"

#define kNavigationTitleTintColor       [UIColor whiteColor]

#define kRegularFontName                @"HelveticaNeue"
#define kBigFontSize                    19.0
#define kNavigationTitleFont            [UIFont fontWithName:kRegularFontName size:kBigFontSize]

@interface KNCameraPickerViewController() <UIActionSheetDelegate,KNEditImageViewControllerDelegate> {
    UIImagePickerController* camera;
}

@end

@implementation KNCameraPickerViewController{
    UIViewController *containVC;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set font and style for navigation item title
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary
      dictionaryWithObjectsAndKeys:
      kNavigationTitleTintColor, NSForegroundColorAttributeName,
      kNavigationTitleFont, NSFontAttributeName, nil]];
    
    // Set navigationbaritem color
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if (self.currentImagePath)
        self.preview.image=[UIImage imageWithContentsOfFile:self.currentImagePath];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    self.preview.image=nil;
}

#pragma mark - IB Actions

-(IBAction)launchCamera:(id)sender{
    
    
   
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"Get Picture From", nil)
                                                           delegate:self cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:
                                NSLocalizedString(@"Camera", nil),
                                NSLocalizedString(@"Photos", nil),
                                nil];
        popup.tag = 1;
        [popup showInView:[UIApplication sharedApplication].keyWindow];
        
        if ([sender isKindOfClass:[UIViewController class]]) {
            containVC = sender;
        } else {
            containVC = self;
        }
 
        
    
    
   
        
        
}

#pragma mark - Generate Image name & path

- (NSString*) generateImageName{
    return @"new_Selected_Image";
}

- (NSString*) generateImagePath{
    
    return [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/%@.jpg",[self generateImageName]]];
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    image = [UIImage imageWithCGImage: image.CGImage
                                            scale: image.scale
                                      orientation: image.imageOrientation];
    
    image = [self scaleAndRotateImage: image];
    
    if (self.isFrontCameraUsed && picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        image = [self flipImage:image];
    }
    
    if (picker.sourceType==UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil,nil,nil);
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UINavigationController *vc = (UINavigationController *)[[KNStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:@"UINavigationController" storyboardName:@"KNEditImage"];
    
    KNEditImageViewController *editImageVC = (KNEditImageViewController*)vc.viewControllers[0];
    
    editImageVC.rawImage = image;
    editImageVC.knDelegate = self;
    
    [camera presentViewController:vc animated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [containVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Image Picked

- (void) onImagePicked:(UIImage*) image {
    
    self.currentImagePath = [self generateImagePath];
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:self.currentImagePath atomically:YES];
    
    UIImage *imageTmp = [UIImage imageWithContentsOfFile:self.currentImagePath];
    self.preview.image= imageTmp;
    
    [self.delegate didSelectedImage:imageTmp];
}

- (void) onImageSent:(NSNotification*) notification
{
    self.preview.image=nil;
    self.currentImagePath = nil;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: // From Camera
            
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeCamera]) {
                
                camera = [[UIImagePickerController alloc] init];
                camera.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                /*
                 The user wants to use the camera interface. Set up our custom overlay view for the camera.
                 */
                camera.showsCameraControls = NO;
                
                /*
                 Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
                 */
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
                
                UIView *overlayView = [nibArray objectAtIndex:0];
                
                overlayView.frame = camera.cameraOverlayView.frame;
                camera.cameraOverlayView = overlayView;
                overlayView = nil;
                
                if (self.isFrontCameraUsed) {
                    camera.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                
                CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0f, CGRectGetHeight(self.controlsToolbar.frame));
                transform = CGAffineTransformScale(transform, 1.4f, 1.4f);
                camera.cameraViewTransform = transform;
                
                [camera setDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) self];
                camera.modalPresentationStyle = UIModalPresentationFullScreen;
                [containVC presentViewController:camera animated:YES completion:nil];
            }
            else {
                // Your device doesn't have a camera"
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"") message:NSLocalizedString(@"noCamera", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"") otherButtonTitles:nil, nil];
                [alert show];
                
            }
            break;
        case 1: // From Photos
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypePhotoLibrary]) {
                camera = [[UIImagePickerController alloc] init];
                
                camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                [camera setDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) self];
                camera.modalPresentationStyle = UIModalPresentationFullScreen;

                camera.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeMovie, (NSString*)kUTTypeImage,nil];
                [containVC presentViewController:camera animated:YES completion:nil];
            }
            else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"") message:NSLocalizedString(@"noPhotoLibrary", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"") otherButtonTitles:nil, nil];
                [alert show];
            }
            break;
        default:
            break;
    }
}

#pragma mark - KNEditImageViewControllerDelegate

- (void)didUseCroppeAvatar:(UIImage *)image {
    
    [containVC dismissViewControllerAnimated:YES completion:nil];

    [self onImagePicked:image];
}

- (IBAction)takePhoto:(id)sender {
    [camera takePicture];
}

- (IBAction)closeCamera:(id)sender {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [containVC dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeCamera:(id)sender {

    self.isFrontCameraUsed = !self.isFrontCameraUsed;
    
    if (self.isFrontCameraUsed) {
        
        camera.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else{
    
        camera.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}


- (UIImage*) flipImage:(UIImage*)sourceImage{
    
    UIImage * resultImage;
    UIImageOrientation imageOrientation;
    
    switch (sourceImage.imageOrientation) {
        case UIImageOrientationDown:
            imageOrientation = UIImageOrientationDownMirrored;
            break;
            
        case UIImageOrientationDownMirrored:
            imageOrientation = UIImageOrientationDown;
            break;
            
        case UIImageOrientationLeft:
            imageOrientation = UIImageOrientationLeftMirrored;
            break;
            
        case UIImageOrientationLeftMirrored:
            imageOrientation = UIImageOrientationLeft;
            
            break;
            
        case UIImageOrientationRight:
            imageOrientation = UIImageOrientationRightMirrored;
            
            break;
            
        case UIImageOrientationRightMirrored:
            imageOrientation = UIImageOrientationRight;
            
            break;
            
        case UIImageOrientationUp:
            imageOrientation = UIImageOrientationUpMirrored;
            break;
            
        case UIImageOrientationUpMirrored:
            imageOrientation = UIImageOrientationUp;
            break;
        default:
            break;
    }
    
    resultImage = [UIImage imageWithCGImage:sourceImage.CGImage scale:sourceImage.scale orientation:imageOrientation];
    
    return resultImage;
    
}

- (UIImage *) scaleAndRotateImage: (UIImage *) imageIn {
    
    int kMaxResolution = 3264;
    
    CGImageRef        imgRef    = imageIn.CGImage;
    CGFloat           width     = CGImageGetWidth(imgRef);
    CGFloat           height    = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect            bounds    = CGRectMake( 0, 0, width, height );
    
    if ( width > kMaxResolution || height > kMaxResolution )
    {
        CGFloat ratio = width/height;
        
        if (ratio > 1)
        {
            bounds.size.width  = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else
        {
            bounds.size.height = kMaxResolution;
            bounds.size.width  = bounds.size.height * ratio;
        }
    }
    
    CGFloat            scaleRatio   = bounds.size.width / width;
    CGSize             imageSize    = CGSizeMake( CGImageGetWidth(imgRef),         CGImageGetHeight(imgRef) );
    UIImageOrientation orient       = imageIn.imageOrientation;
    CGFloat            boundHeight;
    
    switch(orient)
    {
        case UIImageOrientationUp:                                        //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored:                                //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:                                      //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:                              //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored:                              //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft:                                      //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:                             //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:                                     //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise: NSInternalInconsistencyException
                        format: @"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext( bounds.size );
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ( orient == UIImageOrientationRight || orient == UIImageOrientationLeft )
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM( context, transform );
    
    CGContextDrawImage( UIGraphicsGetCurrentContext(), CGRectMake( 0, 0, width, height ), imgRef );
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return( imageCopy );
}

@end

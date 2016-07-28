//
//  GRMediaManager.swift
//  GRFramework
//
//  Created by Gnatsel Reivilo on 17/09/2015.
//  Copyright © 2015 Gnatsel Reivilo. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

public class GRMediaManager: NSObject {
    public static func showPhotoLibrary(sender:UIViewController, delegate:protocol<UIImagePickerControllerDelegate,UINavigationControllerDelegate>? = nil){
        PHPhotoLibrary.requestAuthorization({ (status) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                switch (status) {
                case .Authorized:
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                    imagePickerController.delegate = delegate;
                    imagePickerController.allowsEditing = true
                    sender.presentViewController(imagePickerController, animated:true, completion:nil);
                    break
                case .Restricted:
                    sender.showAlertForPermissionsDisabled("Photos")
                    break
                case .Denied:
                    sender.showAlertForPermissionsDisabled("Photos")
                    break
                    
                default:
                    break
                }
            })
        })
    }
  public static func showCamera(sender:UIViewController, delegate:protocol<UIImagePickerControllerDelegate,UINavigationControllerDelegate>? = nil, title:String? = "Camera unavailable", message:String? = "The camera is not available for this device."){
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) else {
            sender.showAlertWithTitle(nil,
                message: nil,
                actions: [UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)],
                usesDefaultCancelAction: false)
            
            return
        }
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo);
        switch (status) {
        case .Authorized:
            dispatch_async(dispatch_get_main_queue(),{
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePickerController.delegate = delegate;
                sender.presentViewController(imagePickerController, animated:true, completion:nil);
            })
            break
        case .Restricted:
            dispatch_async(dispatch_get_main_queue(),{
                sender.showAlertForPermissionsDisabled("Photos")
            })
            break
        case .Denied:
            dispatch_async(dispatch_get_main_queue(),{
                sender.showAlertForPermissionsDisabled("Photos")
            })
            break
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
                if granted {
                    dispatch_async(dispatch_get_main_queue(),{
                        let imagePickerController = UIImagePickerController()
                        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera;
                        imagePickerController.delegate = delegate;
                        sender.presentViewController(imagePickerController, animated:true, completion:nil);
                    })
                    
                }
                else {
                    dispatch_async(dispatch_get_main_queue(),{
                        sender.showAlertForPermissionsDisabled("Photos")
                    })
                }
            })
            break
            
        }
    }
}

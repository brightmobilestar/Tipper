import Foundation

class KNS3BucketManager: NSObject
{

    class var sharedInstance: KNS3BucketManager
    {
        struct Singleton
        {
            static let instance = KNS3BucketManager()
        }
        return Singleton.instance
    }
    
    override init()
    {
        super.init()
        
        var credentialsProvider: AWSStaticCredentialsProvider = AWSStaticCredentialsProvider(accessKey: kS3BucketAccessKey, secretKey: kS3BucketSecretKey)
        
        // kS3BucketRegionType - AWSRegionUSEast1
        let kS3BucketRegionType = AWSRegionType.USEast1
        var configuration: AWSServiceConfiguration = AWSServiceConfiguration(region: kS3BucketRegionType, credentialsProvider: credentialsProvider)
        var serviceManager: AWSServiceManager = AWSServiceManager.defaultServiceManager()
        serviceManager.setDefaultServiceConfiguration(configuration)
        
    }
    
    func uploadFile(#fromLocalFileURL: NSURL, toFilePathInBucket: String, publicRead:Bool? = false, uploadProgress: ((bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void)!, uploadComplete: ((uploadSuccessful: Bool, errorDescription: String) -> Void)!)
    {
        
        var transferManager: AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
        var uploadRequest: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = kS3BucketName
        uploadRequest.key = toFilePathInBucket
        uploadRequest.body = fromLocalFileURL
        uploadRequest.uploadProgress = uploadProgress
        //It's an optional
        /*
        if ((publicRead) != nil ){
            //now it is safe to unwrap it
            if (publicRead!){
                uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
            }
            
        }
        */
        uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
        transferManager.upload(uploadRequest).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock:
        { task in
                
                if (task as BFTask).error == nil
                {
                    
                    uploadComplete(uploadSuccessful: true, errorDescription: "")
                }
                else
                {
                    uploadComplete(uploadSuccessful: false, errorDescription: (task as BFTask).error.localizedDescription)
                }
                
                return nil
                
        })
        
    }
    
    func downloadFile(#fromBucketFilePath: String, toLocalFileURL: NSURL, downloadProgress: ((bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void)!, downloadComplete: ((downloadSuccessful: Bool, errorDescription: String) -> Void)!)
    {
        
        var transferManager: AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        var downloadRequest: AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest.bucket = kS3BucketName
        downloadRequest.key = fromBucketFilePath
        downloadRequest.downloadingFileURL = toLocalFileURL
        downloadRequest.downloadProgress = downloadProgress

        
        transferManager.download(downloadRequest).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock:
        { task in
            
                if (task as BFTask).error == nil
                {
                    downloadComplete(downloadSuccessful: true, errorDescription: "")
                }
                else
                {
                    downloadComplete(downloadSuccessful: false, errorDescription: (task as BFTask).error.localizedDescription)
                }
                
                return nil
                
        })
    }
    
}
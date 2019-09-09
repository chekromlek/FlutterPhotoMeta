import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {

    // register method
    Plugins.sharedInstance()
        .Register(identifier: ValidMethod.listPhotos, method: GetAllPhoto)
        .Register(identifier: ValidMethod.getPhoto, method: GetPhoto)
        .Register(identifier: ValidMethod.getPhotoMetadata, method: GetPhotoMetadata)
        .Register(identifier: ValidMethod.removePhotoMetadata, method: RemovePhotoMetadata)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let photoChannel = FlutterMethodChannel(name: "com.example.flutterphotometa/photos",
                                            binaryMessenger: controller,
                                            codec: Plugins.sharedInstance())

    photoChannel.setMethodCallHandler(Plugins.sharedInstance().HandlingMethodCall(call:result:))
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

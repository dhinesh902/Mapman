import Flutter
import UIKit
#if canImport(GoogleMaps)
import GoogleMaps
#endif


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if canImport(GoogleMaps)
    GMSServices.provideAPIKey("AIzaSyD5DDgkqYerJpBqwE2PVU-WVRQAs8ujfbw")
    #endif
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}


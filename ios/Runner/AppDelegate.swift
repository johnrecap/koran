import Flutter
import Photos
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let quizCardChannelName = "quran_kareem/quiz_card_image_exporter"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: quizCardChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        self?.handleQuizCardMethodCall(call, result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleQuizCardMethodCall(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard call.method == "saveImageToGallery" else {
      result(FlutterMethodNotImplemented)
      return
    }

    guard
      let arguments = call.arguments as? [String: Any],
      let bytes = arguments["bytes"] as? FlutterStandardTypedData,
      let fileName = arguments["fileName"] as? String,
      !fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      result(
        FlutterError(
          code: "invalid-args",
          message: "Image bytes and file name are required.",
          details: nil
        )
      )
      return
    }

    saveImageToGallery(bytes.data, fileName: fileName, result: result)
  }

  private func saveImageToGallery(
    _ data: Data,
    fileName: String,
    result: @escaping FlutterResult
  ) {
    requestPhotoAccess { [weak self] granted in
      guard granted else {
        result(
          FlutterError(
            code: "permission-denied",
            message: "Photo access denied.",
            details: nil
          )
        )
        return
      }

      self?.persistImage(data, fileName: fileName, result: result)
    }
  }

  private func requestPhotoAccess(completion: @escaping (Bool) -> Void) {
    if #available(iOS 14, *) {
      let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
      switch status {
      case .authorized, .limited:
        completion(true)
      case .notDetermined:
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
          DispatchQueue.main.async {
            completion(newStatus == .authorized || newStatus == .limited)
          }
        }
      default:
        completion(false)
      }
      return
    }

    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized:
      completion(true)
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization { newStatus in
        DispatchQueue.main.async {
          completion(newStatus == .authorized)
        }
      }
    default:
      completion(false)
    }
  }

  private func persistImage(
    _ data: Data,
    fileName: String,
    result: @escaping FlutterResult
  ) {
    PHPhotoLibrary.shared().performChanges({
      let creationRequest = PHAssetCreationRequest.forAsset()
      let options = PHAssetResourceCreationOptions()
      options.originalFilename = fileName
      creationRequest.addResource(with: .photo, data: data, options: options)
    }) { success, error in
      DispatchQueue.main.async {
        if success {
          result(fileName)
          return
        }

        result(
          FlutterError(
            code: "save-failed",
            message: error?.localizedDescription ?? "Unable to save image.",
            details: nil
          )
        )
      }
    }
  }
}

package com.silf.quran_kareem

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : AudioServiceActivity() {
  companion object {
    private const val QUIZ_CARD_CHANNEL = "quran_kareem/quiz_card_image_exporter"
    private const val LEGACY_STORAGE_REQUEST_CODE = 4707
    private const val GALLERY_DIRECTORY = "Quran Kareem"
  }

  private var pendingGalleryBytes: ByteArray? = null
  private var pendingGalleryFileName: String? = null
  private var pendingGalleryResult: MethodChannel.Result? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      QUIZ_CARD_CHANNEL,
    ).setMethodCallHandler { call, result ->
      when (call.method) {
        "saveImageToGallery" -> {
          val bytes = call.argument<ByteArray>("bytes")
          val fileName = call.argument<String>("fileName")
          if (bytes == null || fileName.isNullOrBlank()) {
            result.error(
              "invalid-args",
              "Image bytes and file name are required.",
              null,
            )
            return@setMethodCallHandler
          }

          saveImageToGallery(bytes, fileName, result)
        }

        else -> result.notImplemented()
      }
    }
  }

  override fun onRequestPermissionsResult(
    requestCode: Int,
    permissions: Array<out String>,
    grantResults: IntArray,
  ) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)

    if (requestCode != LEGACY_STORAGE_REQUEST_CODE) {
      return
    }

    val result = pendingGalleryResult ?: return
    val bytes = pendingGalleryBytes
    val fileName = pendingGalleryFileName
    clearPendingGalleryRequest()

    if (
      grantResults.isNotEmpty() &&
      grantResults[0] == PackageManager.PERMISSION_GRANTED &&
      bytes != null &&
      fileName != null
    ) {
      saveLegacyImage(bytes, fileName, result)
      return
    }

    result.error("permission-denied", "Gallery permission denied.", null)
  }

  private fun saveImageToGallery(
    bytes: ByteArray,
    fileName: String,
    result: MethodChannel.Result,
  ) {
    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        saveScopedImage(bytes, fileName, result)
        return
      }

      if (
        ContextCompat.checkSelfPermission(
          this,
          Manifest.permission.WRITE_EXTERNAL_STORAGE,
        ) == PackageManager.PERMISSION_GRANTED
      ) {
        saveLegacyImage(bytes, fileName, result)
        return
      }

      pendingGalleryBytes = bytes
      pendingGalleryFileName = fileName
      pendingGalleryResult = result
      ActivityCompat.requestPermissions(
        this,
        arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
        LEGACY_STORAGE_REQUEST_CODE,
      )
    } catch (error: Exception) {
      clearPendingGalleryRequest()
      result.error("save-failed", error.message ?: "Unable to save image.", null)
    }
  }

  private fun saveScopedImage(
    bytes: ByteArray,
    fileName: String,
    result: MethodChannel.Result,
  ) {
    val resolver = applicationContext.contentResolver
    val values = ContentValues().apply {
      put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
      put(MediaStore.Images.Media.MIME_TYPE, "image/png")
      put(
        MediaStore.Images.Media.RELATIVE_PATH,
        "${Environment.DIRECTORY_PICTURES}/${GALLERY_DIRECTORY}",
      )
      put(MediaStore.Images.Media.IS_PENDING, 1)
    }
    val collection =
      MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
    val uri = resolver.insert(collection, values)
      ?: throw IOException("Unable to create a gallery item.")

    try {
      resolver.openOutputStream(uri)?.use { stream ->
        stream.write(bytes)
        stream.flush()
      } ?: throw IOException("Unable to open a gallery stream.")

      val readyValues = ContentValues().apply {
        put(MediaStore.Images.Media.IS_PENDING, 0)
      }
      resolver.update(uri, readyValues, null, null)
      result.success(uri.toString())
    } catch (error: Exception) {
      resolver.delete(uri, null, null)
      throw error
    }
  }

  private fun saveLegacyImage(
    bytes: ByteArray,
    fileName: String,
    result: MethodChannel.Result,
  ) {
    val picturesDirectory =
      Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
    val appDirectory = File(picturesDirectory, GALLERY_DIRECTORY)
    if (!appDirectory.exists() && !appDirectory.mkdirs()) {
      throw IOException("Unable to create a gallery directory.")
    }

    val file = File(appDirectory, fileName)
    FileOutputStream(file).use { output ->
      output.write(bytes)
      output.flush()
    }

    MediaScannerConnection.scanFile(
      this,
      arrayOf(file.absolutePath),
      arrayOf("image/png"),
      null,
    )
    result.success(file.absolutePath)
  }

  private fun clearPendingGalleryRequest() {
    pendingGalleryBytes = null
    pendingGalleryFileName = null
    pendingGalleryResult = null
  }
}

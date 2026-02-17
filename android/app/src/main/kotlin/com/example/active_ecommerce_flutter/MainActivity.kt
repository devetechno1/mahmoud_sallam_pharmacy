package com.devefinancestore

import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.OutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "media_store_saver"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToPublicDownloads" -> {
                        val filePath = call.argument<String>("filePath")
                        val fileName = call.argument<String>("fileName")
                        val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                        val subDir  = call.argument<String>("subDir") ?: ""

                        if (filePath.isNullOrEmpty() || fileName.isNullOrEmpty()) {
                            result.error("ARG_ERROR", "Missing filePath or fileName", null); return@setMethodCallHandler
                        }
                        try {
                            val uri = saveToDownloads(filePath, fileName, mimeType, subDir)
                            result.success(uri?.toString())
                        } catch (e: Exception) {
                            result.error("SAVE_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveToDownloads(filePath: String, fileName: String, mimeType: String, subDir: String): Uri? {
        val resolver = applicationContext.contentResolver
        val cleanSubDir = subDir.trim().replace(Regex("[\\\\/:*?\"<>|]"), "_")
        val relativePath = if (cleanSubDir.isNotEmpty())
            Environment.DIRECTORY_DOWNLOADS + "/" + cleanSubDir
        else
            Environment.DIRECTORY_DOWNLOADS

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, mimeType)
                put(MediaStore.Downloads.IS_PENDING, 1)
                put(MediaStore.Downloads.RELATIVE_PATH, relativePath)
            }
            val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            val uri = resolver.insert(collection, values) ?: return null

            resolver.openOutputStream(uri)?.use { out: OutputStream ->
                FileInputStream(File(filePath)).use { input -> input.copyTo(out) }
            }

            values.clear(); values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            return uri
        }

        // Pre-Android 10 fallback
        val downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        val targetDir = if (cleanSubDir.isNotEmpty()) File(downloads, cleanSubDir) else downloads
        if (!targetDir.exists()) targetDir.mkdirs()
        val target = File(targetDir, fileName)

        FileInputStream(File(filePath)).use { input ->
            FileOutputStream(target).use { out -> input.copyTo(out) }
        }

        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DATA, target.absolutePath)
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
        }
        return resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
    }
}

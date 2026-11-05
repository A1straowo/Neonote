package io.aistra.neonote.note

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val channelName = "neonote/media"
    private val MAX_IMAGE_DIMENSION = 2048
    private val pickImageRequestCode = 4301
    private val takePhotoRequestCode = 4303
    private val recordPermissionRequestCode = 4302

    private var pendingPickResult: MethodChannel.Result? = null
    private var pendingTakePhotoResult: MethodChannel.Result? = null
    private var pendingRecordResult: MethodChannel.Result? = null

    private var recorder: MediaRecorder? = null
    private var recordingFile: File? = null
    private var player: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickImage" -> pickImage(result)
                    "takePhoto" -> takePhoto(result)
                    "startRecording" -> startRecording(result)
                    "stopRecording" -> stopRecording(result)
                    "playAudio" -> playAudio(call.argument<String>("path"), result)
                    "stopAudio" -> {
                        stopAudio()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Suppress("DEPRECATION")
    private fun pickImage(result: MethodChannel.Result) {
        if (pendingPickResult != null) {
            result.error("busy", "A gallery request is already running", null)
            return
        }
        pendingPickResult = result
        try {
            val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                type = "image/*"
                addCategory(Intent.CATEGORY_OPENABLE)
            }
            startActivityForResult(intent, pickImageRequestCode)
        } catch (error: Exception) {
            pendingPickResult = null
            result.error("pick_failed", error.message, null)
        }
    }

    private fun takePhoto(result: MethodChannel.Result) {
        if (pendingTakePhotoResult != null) {
            result.error("busy", "A camera request is already running", null)
            return
        }
        pendingTakePhotoResult = result
        try {
            val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
            startActivityForResult(intent, takePhotoRequestCode)
        } catch (error: Exception) {
            pendingTakePhotoResult = null
            result.error("take_photo_failed", error.message, null)
        }
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == pickImageRequestCode) {
            val result = pendingPickResult
            pendingPickResult = null
            val uri: Uri? = data?.data
            if (resultCode != Activity.RESULT_OK || uri == null) {
                result?.success(null)
                return
            }
            try {
                result?.success(saveCompressedImage(uri, "img"))
            } catch (error: Exception) {
                result?.error("pick_failed", error.message, null)
            }
            return
        }
        if (requestCode == takePhotoRequestCode) {
            val result = pendingTakePhotoResult
            pendingTakePhotoResult = null
            if (resultCode != Activity.RESULT_OK) {
                result?.success(null)
                return
            }
            val uri = data?.data
            if (uri != null) {
                try {
                    result?.success(saveCompressedImage(uri, "photo"))
                } catch (error: Exception) {
                    result?.error("take_photo_failed", error.message, null)
                }
                return
            }
            val bitmap = data?.extras?.get("data") as? Bitmap
            if (bitmap == null) {
                result?.success(null)
                return
            }
            try {
                val directory = File(filesDir, "avatars").apply { mkdirs() }
                val target = File(
                    directory,
                    "photo_${System.currentTimeMillis()}_${UUID.randomUUID().toString().take(6)}.jpg",
                )
                target.outputStream().use { output ->
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 88, output)
                }
                result?.success(target.absolutePath)
            } catch (error: Exception) {
                result?.error("take_photo_failed", error.message, null)
            }
            return
        }
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun saveCompressedImage(uri: Uri, prefix: String): String {
        val directory = File(filesDir, "avatars").apply { mkdirs() }
        val target = File(
            directory,
            "${prefix}_${System.currentTimeMillis()}_${UUID.randomUUID().toString().take(6)}.jpg",
        )

        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        contentResolver.openInputStream(uri)?.use { stream ->
            BitmapFactory.decodeStream(stream, null, bounds)
        }
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) {
            copyImageStream(uri, target)
            return target.absolutePath
        }

        val options = BitmapFactory.Options().apply {
            inSampleSize = calculateInSampleSize(
                bounds.outWidth,
                bounds.outHeight,
                MAX_IMAGE_DIMENSION,
            )
            inPreferredConfig = Bitmap.Config.ARGB_8888
        }
        val decoded = contentResolver.openInputStream(uri)?.use { stream ->
            BitmapFactory.decodeStream(stream, null, options)
        } ?: run {
            copyImageStream(uri, target)
            return target.absolutePath
        }

        val orientation = readExifOrientation(uri)
        val oriented = orientAndScale(decoded, orientation)
        if (oriented !== decoded) decoded.recycle()
        target.outputStream().use { output ->
            oriented.compress(Bitmap.CompressFormat.JPEG, 86, output)
        }
        oriented.recycle()
        return target.absolutePath
    }

    private fun copyImageStream(uri: Uri, target: File) {
        val input = contentResolver.openInputStream(uri)
            ?: throw IllegalStateException("Unable to read the selected image")
        input.use { stream ->
            target.outputStream().use { output -> stream.copyTo(output) }
        }
    }

    private fun calculateInSampleSize(width: Int, height: Int, maxDimension: Int): Int {
        var sample = 1
        while (width / (sample * 2) >= maxDimension ||
            height / (sample * 2) >= maxDimension
        ) {
            sample *= 2
        }
        return sample
    }

    private fun readExifOrientation(uri: Uri): Int {
        return try {
            contentResolver.openInputStream(uri)?.use { stream ->
                ExifInterface(stream).getAttributeInt(
                    ExifInterface.TAG_ORIENTATION,
                    ExifInterface.ORIENTATION_NORMAL,
                )
            } ?: ExifInterface.ORIENTATION_NORMAL
        } catch (_: Exception) {
            ExifInterface.ORIENTATION_NORMAL
        }
    }

    private fun orientAndScale(source: Bitmap, orientation: Int): Bitmap {
        val matrix = Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.setScale(-1f, 1f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.setRotate(180f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.setScale(1f, -1f)
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.setRotate(90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.setRotate(90f)
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.setRotate(-90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.setRotate(-90f)
        }

        val maxDimension = maxOf(source.width, source.height)
        if (maxDimension > MAX_IMAGE_DIMENSION) {
            val scale = MAX_IMAGE_DIMENSION.toFloat() / maxDimension.toFloat()
            matrix.postScale(scale, scale)
        }

        if (matrix.isIdentity) return source
        val oriented = Bitmap.createBitmap(
            source,
            0,
            0,
            source.width,
            source.height,
            matrix,
            true,
        )
        return if (oriented === source) source else oriented
    }

    private fun hasRecordPermission(): Boolean =
        ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED

    private fun startRecording(result: MethodChannel.Result) {
        if (!hasRecordPermission()) {
            if (pendingRecordResult != null) {
                result.error("busy", "A permission request is already running", null)
                return
            }
            pendingRecordResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                recordPermissionRequestCode,
            )
            return
        }
        result.success(beginRecording())
    }

    private fun beginRecording(): Boolean {
        stopAudio()
        return try {
            val directory = File(filesDir, "audio").apply { mkdirs() }
            val file = File(directory, "rec_${System.currentTimeMillis()}.m4a")
            val mediaRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                MediaRecorder(this)
            } else {
                @Suppress("DEPRECATION")
                MediaRecorder()
            }
            mediaRecorder.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setAudioEncodingBitRate(96_000)
                setAudioSamplingRate(44_100)
                setOutputFile(file.absolutePath)
                prepare()
                start()
            }
            recorder = mediaRecorder
            recordingFile = file
            true
        } catch (error: Exception) {
            recorder?.release()
            recorder = null
            recordingFile = null
            false
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (requestCode == recordPermissionRequestCode) {
            val result = pendingRecordResult
            pendingRecordResult = null
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            result?.success(if (granted) beginRecording() else false)
            return
        }
        @Suppress("DEPRECATION")
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    private fun stopRecording(result: MethodChannel.Result) {
        val mediaRecorder = recorder
        recorder = null
        val file = recordingFile
        recordingFile = null
        if (mediaRecorder == null) {
            result.success(null)
            return
        }
        try {
            mediaRecorder.stop()
            mediaRecorder.release()
            result.success(file?.absolutePath)
        } catch (error: Exception) {
            try {
                mediaRecorder.release()
            } catch (_: Exception) {
            }
            file?.delete()
            result.error("record_failed", error.message, null)
        }
    }

    private fun playAudio(path: String?, result: MethodChannel.Result) {
        if (path.isNullOrEmpty() || !File(path).exists()) {
            result.success(false)
            return
        }
        stopAudio()
        try {
            val mediaPlayer = MediaPlayer()
            mediaPlayer.setDataSource(path)
            mediaPlayer.setOnCompletionListener { completed ->
                if (player === completed) player = null
                completed.release()
            }
            mediaPlayer.prepare()
            mediaPlayer.start()
            player = mediaPlayer
            result.success(true)
        } catch (error: Exception) {
            stopAudio()
            result.success(false)
        }
    }

    private fun stopAudio() {
        val current = player ?: return
        player = null
        try {
            if (current.isPlaying) current.stop()
        } catch (_: Exception) {
        }
        try {
            current.release()
        } catch (_: Exception) {
        }
    }

    override fun onDestroy() {
        stopAudio()
        try {
            recorder?.release()
        } catch (_: Exception) {
        }
        recorder = null
        super.onDestroy()
    }
}

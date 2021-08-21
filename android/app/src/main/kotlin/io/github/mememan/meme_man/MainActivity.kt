package io.github.mememan.meme_man

import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mememan/share"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "shareTo") {
                val target = call.argument<String>("target")!!
                val imgPath = call.argument<String>("path")!!
                if (target in shareRequester) {
                    shareRequester[target]!!.invoke(imgPath)
                    result.success(0)
                } else {
                    result.error("-1", "Unsupported share target: $target", "")
                }
            }
        }
    }

    private inline fun intent(block: Intent.() -> Unit) {
        Intent().apply {
            action = Intent.ACTION_SEND
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            type = "image/*"
        }.apply(block).let(this::startActivity)
//        startActivity(Intent.createChooser(shareIntent, "Share"))
    }

    private val shareRequester: Map<String, (String) -> Unit> = mapOf(
        "tim" to { path ->
            intent {
                `package` = "com.tencent.tim"
                putExtra(Intent.EXTRA_STREAM, Uri.parse(path))
                component =
                    ComponentName("com.tencent.tim", "com.tencent.mobileqq.activity.JumpActivity")
            }
        },
        "qq" to { path ->
            intent {
                `package` = "com.tencent.mobileqq"
                putExtra(Intent.EXTRA_STREAM, Uri.parse(path))
                component =
                    ComponentName(
                        "com.tencent.mobileqq",
                        "com.tencent.mobileqq.activity.JumpActivity"
                    )
            }
        },
        "wechat" to { path ->
            intent {
                `package` = "com.tencent.mm"
                putExtra(Intent.EXTRA_STREAM, Uri.parse(path))
                component =
                    ComponentName(
                        "com.tencent.mm",
                        "com.tencent.mm.ui.tools.ShareImgUI"
                    )
            }
        }

    )

}

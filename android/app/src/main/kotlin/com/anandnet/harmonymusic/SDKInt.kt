package com.anandnet.harmonymusic

import android.os.Build
import androidx.annotation.Keep

@Keep
class SDKInt {
    @Keep
    companion object{
        fun getSDKInt():Int{
            return Build.VERSION.SDK_INT
        }
    }
}
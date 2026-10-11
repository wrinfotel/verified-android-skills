package com.example.fixtures

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.compose.ui.viewinterop.AndroidView
import androidx.fragment.app.Fragment

// GOOD fixture — must pass every compose-migration check.
// Used by verify.sh --selftest to prove the checks stay quiet on clean code.

class ProfileFragment : Fragment() {
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View {
        return ComposeView(requireContext()).apply {
            setViewCompositionStrategy(
                ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed
            )
            setContent { ProfileHeader(name = "Ada") }
        }
    }
}

@Composable
fun ProfileHeader(name: String) {
    Text(text = name)
}

@Composable
fun LegacyCounter(count: Int) {
    AndroidView(
        factory = { context -> TextView(context) },
        update = { view -> view.text = count.toString() },
    )
}

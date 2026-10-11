package com.example.fixtures

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.viewinterop.AndroidView
import androidx.fragment.app.Fragment

// BAD fixture — deliberately trips all three compose-migration checks.
// Never compiled; smells: ComposeView in a Fragment without a composition
// strategy, an AndroidView factory reading state, and a two-ComposeView
// XML layout without unique IDs (see profile_fragment.xml beside this
// file).

class ProfileFragment : Fragment() {
    private val name = mutableStateOf("Ada")

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View {
        return ComposeView(requireContext()).apply {
            setContent { ProfileHeader(name = name.value) }
        }
    }
}

@Composable
fun ProfileHeader(name: String) {
    Text(text = name)
}

@Composable
fun LegacyCounter(count: State<Int>) {
    AndroidView(
        factory = { context -> TextView(context).apply { text = count.value.toString() } },
    )
}

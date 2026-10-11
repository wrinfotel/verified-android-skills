package com.example.fixtures.data

import retrofit2.Retrofit
import retrofit2.create

// GOOD fixture — the network data source import lives in the data layer:
// repositories own data sources, so this file must stay quiet.

class FeedRepository(
    private val retrofit: Retrofit,
) {
    fun feedStream() = retrofit.create<FeedApi>().observeFeed()
}

package com.example.fixtures

import android.os.Build

// BAD fixture — an expect declaration in a platform source set; expect
// belongs in commonMain. Part of the compose-migration-style layout used
// to trip check_expect_actual_placement and check_expect_actual_balance.

expect fun androidApiLevel(): Int

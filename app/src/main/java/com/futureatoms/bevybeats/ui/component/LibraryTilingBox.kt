package com.futureatoms.bevybeats.ui.component

import android.os.Bundle
import androidx.annotation.StringRes
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.TrendingUp
import androidx.compose.material.icons.filled.Downloading
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Insights
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.futureatoms.bevybeats.R
import com.futureatoms.bevybeats.extension.NonLazyGrid
import com.futureatoms.bevybeats.extension.navigateSafe
import com.futureatoms.bevybeats.ui.theme.typo

@Composable
fun LibraryTilingBox(navController: NavController) {
    val listItem =
        listOf(
            LibraryTilingState.Favorite,
            LibraryTilingState.Followed,
            LibraryTilingState.MostPlayed,
            LibraryTilingState.Downloaded,
        )
    NonLazyGrid(
        columns = 2,
        itemCount = 4,
        modifier =
            Modifier
                .fillMaxWidth()
                .padding(bottom = 10.dp, end = 10.dp),
    ) { number ->
        Box(
            Modifier.padding(start = 10.dp, top = 10.dp),
        ) {
            LibraryTilingItem(
                listItem[number],
                onClick = {
                    when (listItem[number]) {
                        LibraryTilingState.Favorite -> {
                            navController.navigateSafe(R.id.action_bottom_navigation_item_library_to_favoriteFragment)
                        }
                        LibraryTilingState.Followed -> {
                            navController.navigateSafe(
                                R.id.action_bottom_navigation_item_library_to_favoriteFragment,
                                Bundle().apply {
                                    putString("type", "followed")
                                },
                            )
                        }
                        LibraryTilingState.MostPlayed -> {
                            navController.navigateSafe(
                                R.id.action_bottom_navigation_item_library_to_favoriteFragment,
                                Bundle().apply {
                                    putString("type", "most_played")
                                },
                            )
                        }
                        LibraryTilingState.Downloaded -> {
                            navController.navigateSafe(
                                R.id.action_bottom_navigation_item_library_to_favoriteFragment,
                                Bundle().apply {
                                    putString("type", "downloaded")
                                },
                            )
                        }
                    }
                },
            )
        }
    }
}

@Composable
fun LibraryTilingItem(
    state: LibraryTilingState,
    onClick: () -> Unit = {},
) {
    val context = LocalContext.current
    val title = context.getString(state.title)
    
    // Use a Card with shadow for a skeuomorphic 3D effect
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(12.dp),
                ambientColor = Color.Black.copy(alpha = 0.2f),
                spotColor = Color.Black.copy(alpha = 0.3f)
            )
            .clickable {
                onClick.invoke()
            },
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = state.containerColor,
        ),
    ) {
        Row(
            Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                state.icon,
                contentDescription = title,
                modifier = Modifier
                    .size(50.dp)
                    .padding(10.dp),
                tint = state.iconColor,
            )
            Text(
                title,
                style = typo.titleSmall,
                color = state.textColor,
                modifier = Modifier.padding(end = 16.dp)
            )
        }
    }
}

data class LibraryTilingState(
    @StringRes val title: Int,
    val containerColor: Color,
    val icon: ImageVector,
    val iconColor: Color,
    val textColor: Color,
) {
    companion object {
        // Dark background color with slight gradient
        private val darkGrayBackground = Color(0xFF2A2A2A)
        
        val Favorite =
            LibraryTilingState(
                title = R.string.favorite,
                containerColor = darkGrayBackground,
                icon = Icons.Default.Favorite,
                iconColor = Color(0xffFF5252),
                textColor = Color(0xffFF5252)
            )
        val Followed =
            LibraryTilingState(
                title = R.string.followed,
                containerColor = darkGrayBackground,
                icon = Icons.Default.Insights,
                iconColor = Color(0xffFFEB3B),
                textColor = Color(0xffFFEB3B)
            )
        val MostPlayed =
            LibraryTilingState(
                title = R.string.most_played,
                containerColor = darkGrayBackground,
                icon = Icons.AutoMirrored.Filled.TrendingUp,
                iconColor = Color(0xff00BCD4),
                textColor = Color(0xff00BCD4)
            )
        val Downloaded =
            LibraryTilingState(
                title = R.string.downloaded,
                containerColor = darkGrayBackground,
                icon = Icons.Default.Downloading,
                iconColor = Color(0xff4CAF50),
                textColor = Color(0xff4CAF50)
            )
    }
}
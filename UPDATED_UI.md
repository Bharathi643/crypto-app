# Crypto App UI Update

Updated based on the requested behavior:

- Coins/Home header is pinned while scrolling. Crypto App branding, LIVE/CONNECTING status and refresh remain fixed.
- Removed chart/sparkline from individual coin cards on the Coins/Home screen. Charts remain only on Coin Details.
- Removed the Favorites filter pill from the Coins/Home screen. Watchlist stars remain because Watchlist is a task-required feature.
- Market screen previews only the first 4 gainers and losers.
- See All appears when more than 4 gainers/losers are available and opens a dedicated list screen.
- Coin Details chart parser accepts PostgreSQL BIGINT values returned as strings. This fixes the common 'Chart unavailable' issue when the backend returns open_time/openTime as BIGINT text.
- Coin Details has a working Retry action for the chart.
- About this coin supports expandable full description with Read more / Read less.
- Existing official website button remains available and uses url_launcher directly.
- No splash screen was added.

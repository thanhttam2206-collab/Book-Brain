enum AdPlacement {
  appResume,
  homeAfterTrending,
  homeFooter,
  allBooksInline,
  searchLandingFooter,
  searchResultsInline,
  favoritesInline,
  historyInline,
  followingInline,
  rankingAuthorsInline,
  rankingBooksInline,
  previewBookInline,
  readingChapterEndBanner,
  readingChapterEndNative,
  chapterUnlock,
  contentNavigationInterstitial,
}

extension AdPlacementX on AdPlacement {
  String get analyticsName => switch (this) {
    AdPlacement.appResume => 'app_resume',
    AdPlacement.homeAfterTrending => 'home_after_trending',
    AdPlacement.homeFooter => 'home_footer',
    AdPlacement.allBooksInline => 'all_books_inline',
    AdPlacement.searchLandingFooter => 'search_landing_footer',
    AdPlacement.searchResultsInline => 'search_results_inline',
    AdPlacement.favoritesInline => 'favorites_inline',
    AdPlacement.historyInline => 'history_inline',
    AdPlacement.followingInline => 'following_inline',
    AdPlacement.rankingAuthorsInline => 'ranking_authors_inline',
    AdPlacement.rankingBooksInline => 'ranking_books_inline',
    AdPlacement.previewBookInline => 'preview_book_inline',
    AdPlacement.readingChapterEndBanner => 'reading_chapter_end_banner',
    AdPlacement.readingChapterEndNative => 'reading_chapter_end_native',
    AdPlacement.chapterUnlock => 'chapter_unlock',
    AdPlacement.contentNavigationInterstitial =>
      'content_navigation_interstitial',
  };
}

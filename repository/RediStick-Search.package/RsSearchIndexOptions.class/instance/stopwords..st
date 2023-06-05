actions
stopwords: stopwords
    | stopwordsString |
	stopwordsString := ' ' join: stopwords.
    self basicStopwords: stopwords size with: stopwordsString
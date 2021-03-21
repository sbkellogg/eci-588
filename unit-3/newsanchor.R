# ___________________________
# Script name: newsanchor package
# Purpose of script: example for optional meeting
# Author: Shaun Kellogg
# Date Created: 
# ___________________________
# Notes:
# 
# 
# ___________________________



set_api_key(tempdir())


search_terms <- c()


sources <- get_sources()
sources <- sources$results_df

view(sources)

publications <- sources %>%
  filter(country == "us", 
         language == "en",
         category == "general", 
         ! id %in% c("vice-news",
                     "reddit-r-all",
                     "al-jazeera-english",
                     "breitbart-news",
                     "politico")
  )

publications <- publications$id


publications <- c("the-washington-post", "fox-news", "axios", "reuters", )

search_terms <- "covid learning loss"


results <- get_everything_all(query = search_terms,
                              language = "en",
                              sort_by = "relevancy",
                              #sources = publications
)

articles <- results$results_df
view(articles)


metadata <- results$metadata
metadata
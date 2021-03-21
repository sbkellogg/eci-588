# ___________________________
# Script name: Unit 2 Topic Modeling
# Purpose of script: Analysis
# Author: Shaun Kellogg
# Date Created: 03-20-2021
# ___________________________
# Notes:
# 
# 
# ___________________________


# 1. PREPARE ####

## Load Packages ####

library(newsanchor)
library(tidyverse)
library(tidytext)
library(topicmodels)
library(forcats)
library(stm)
library(LDAvis)



#2. WRANNGLE ####

ts_forum_data <- read_csv("unit-3/data/ts_forum_data.csv", 
    col_types = cols(course_id = col_character(),
                     forum_id = col_character(), 
                     discussion_id = col_character(), 
                     discussion_creator = col_character(), 
                     discussion_poster = col_character(), 
                     parent_id = col_character(), 
                     post_id = col_character()
                     )
    )

View(ts_forum_data)

glimpse(ts_forum_data)

## Tidy Text ####

forums_tidy <- ts_forum_data %>%
  unnest_tokens(output = word, input = post_content, format =  "html") %>%
  anti_join(stop_words, by = "word") %>%
  count(course_id, forum_id, word)

forums_dtm <- forums_tidy %>%
  cast_dtm(forum_id, word, n)

view(count(forums_tidy, word, sort = T))


forums_dtm

#3. EXPLORE ####







#4. MODEL ####

## Topic Models ####

forums_lda <- LDA(forums_dtm, k = 10, control = list(seed = 123))

forums_lda

forum_topics <- tidy(forums_lda, matrix = "beta")

forum_top_terms <- 
  forum_topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)


forum_top_terms %>%
  mutate(topic=as.factor(topic),
        term=reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, ncol = 3, scales = "free") +
  coord_flip()


## Structural Topic Models ####

# forums_untidy <- ts_forum_data %>%
#   unnest_tokens(output = word, input = post_content, format =  "html") %>% 
#   nest(word) %>%
#   mutate(text = map(data, unlist), 
#          text = map_chr(text, paste, collapse = " ")) %>%
#   select(!data)
  

forums_untidy <- ts_forum_data %>%
  unnest_tokens(output = word, input = post_content, format =  "html") %>% 
  group_by(course_id, forum_id, discussion_id, post_id) %>% 
  summarise(text = str_c(word, collapse = " ")) %>%
  ungroup()

# see https://stackoverflow.com/questions/49118539/opposite-of-unnest-tokens-in-r

# https://stackoverflow.com/questions/46734501/opposite-of-unnest-tokens


forums_processed <- textProcessor(forums_untidy$text, 
                                  metadata = forums_untidy,
                                  stem = TRUE)

out <- prepDocuments(forums_processed$documents, 
                     forums_processed$vocab, 
                     forums_processed$meta)

docs <- out$documents
vocab <- out$vocab
meta <-out$meta

set.seed(01234)
forums_stm <- stm(documents = out$documents, 
                 vocab = out$vocab,
                 K = 10,
                 max.em.its = 75, 
                 data = out$meta,
                 init.type = "Spectral", 
                 verbose = FALSE)

plot(forums_stm)

findThoughts(forums_stm, 
             texts = forums_untidy$text,
             n = 10, 
             topics = 10)



### Choosing a Value for K ####

findingk <- searchK(out$documents, 
                    out$vocab, K = c(5:15),
                    data = meta, verbose=FALSE)




toLDAvis(mod = forums_stm, docs = out$documents)



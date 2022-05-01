### Term and Document Freq Analysis : TF-IDF
# 1. TF(Term Frequency) : 특정 문서 내에 특정 단어가 얼마나 자주 등장하나
# 2. IDF(Inverse Document Frequency) : 전체 문서에서 특정 단어가 얼마나 자주 등장하나
# Working! 모든 문서에서 전반적으로 자주 등장하는 단어는 패널티
#          해당 문서에서만 자주 등장하는 단어네는 높은 가중치!

library(dplyr)
library(stringr)
library(tidytext)
library(readtext)
library(tidyverse)

load("C:\\Users\\cc933\\Desktop\\hongloumeng.rda")
hongloumeng

cutter <- worker(bylines = T)
chapter_words <- hongloumeng %>% 
  mutate(linenumber = row_number()) %>%
  mutate(chapter = paste("第", 1 + cumsum(str_detect(text, "^第[零一二三四五六七八九十百 ]*([二四六八 ]+十|零) ?一回")), "部分")) %>%
  mutate(text = sapply(segment(text, cutter), function(x){paste(x, collapse = " ")})) %>% 
  ungroup() %>% 
  unnest_tokens(word, text) %>% 
  count(chapter, word, sort=T) %>% 
  ungroup()

total_words <- chapter_words %>% 
  group_by(chapter) %>% 
  summarise(total = sum(n))

chapter_words <- left_join(chapter_words, total_words) %>% 
  mutate(tf = n/total) %>% group_by(chapter) %>% 
  mutate(rank = row_number())

# 많은 단어가 자주나타나지 않고 소수의 단어가 자주 나타남
chapter_words %>%
  ggplot(mapping=aes(x=tf, fill=chapter)) +
  geom_density(show.legend = F) + xlim(NA, 9.0e-5) +
  facet_wrap(~chapter, ncol=2, scales = "free_y")

chapter_words %>% 
  ggplot(mapping=aes(x=rank, y=tf, color=chapter)) + 
  geom_line(size=1.1, alpha=0.8, show.legend = F) +
  geom_abline(intercept = -.9, slope=-0.96, color="gray50", linetype=2) +
  scale_x_log10() + scale_y_log10()

chapter_words <- chapter_words %>% 
  bind_tf_idf(word, chapter, n) %>% arrange(desc(tf_idf))
chapter_words

chapter_words %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>%
  group_by(chapter) %>%
  top_n(15) %>%
  ungroup() %>%
  ggplot(aes(word, tf_idf, fill = chapter)) +
  geom_col(show.legend = FALSE) +
  labs(x = NULL, y = "tf-idf") +
  facet_wrap(~chapter, ncol = 2, scales = "free") +
  coord_flip()


### Gutenberg 문서를 이용한 TF-IDF
library(gutenbergr)
stem <- gutenberg_download(c(26979, 24038, 27292, 25273), 
                           meta_fields = "author")
cutter <- worker(bylines = T)
stem_words <- stem %>%
  mutate(text = sapply(segment(text, cutter),
                       function(x){paste(x, collapse = " ")})) %>% 
  unnest_tokens(word, text) %>% 
  count(author, word, sort=T) %>% 
  ungroup(); stem_words

plot_stem <- stem_words %>% 
  bind_tf_idf(word, author, n) %>% 
  arrange(desc(tf_idf)) %>% 
  mutate(word = factor(word, levels = rev(unique(word)))) %>% 
  mutate(author = factor(author, levels = c("Liu, Hui, 3rd/4th cent.",
                                            "Sunzi, ca. 5th cent.",
                                            "Shen, Kuo",
                                            "Song, Yingxing"))); plot_stem
plot_stem %>% 
  group_by(author) %>% top_n(15, tf_idf) %>% 
  ungroup() %>% 
  ggplot(mapping=aes(x=fct_reorder(word, tf_idf), y=tf_idf, fill=author)) +
  geom_col(show.legend = F) +
  labs(x=NULL, y="tf_idf") + facet_wrap(~author, ncol=2, scales="free") +
  coord_flip()

library(stringr)
mystopwords <- stem_words %>%
  filter(str_detect(word, "^[A-Za-z0-9零一二三四五六七八九十百千萬]+$")) %>%
  select(word) %>%
  as.data.frame()
stem_words <- anti_join(stem_words, mystopwords, by = "word")
plot_stem <- stem_words %>%
  bind_tf_idf(word, author, n) %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>%
  mutate(author = factor(author, levels = c("Liu, Hui, 3rd/4th cent.",
                                            "Sunzi, ca. 5th cent.", 
                                            "Shen, Kuo",
                                            "Song, Yingxing")))
plot_stem %>%
  group_by(author) %>%
  top_n(15, tf_idf) %>%
  ungroup() %>%
  mutate(word = reorder(word, tf_idf)) %>%
  ggplot(aes(word, tf_idf, fill = author)) +
  geom_col(show.legend = FALSE) +
  labs(x = NULL, y = "tf-idf") +
  facet_wrap(~author, ncol = 2, scales = "free") +
  coord_flip()


### Gutenberg를 이용한 ngram 분석
# n-gram : 한 단어 다음에 특정 단어가 오는 빈도를 확인해 단어 간의 관계 모델 구축
library(gutenbergr)
hongloumeng_en <- gutenberg_download(c(9603, 9604), meta_fields = "title")
bigrams <- hongloumeng_en %>%
  mutate(book = cumsum(str_detect(text, regex("HUNG LOU MENG, BOOK [I]+")))) %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2)

bigrams %>% count(bigram, sort=T)

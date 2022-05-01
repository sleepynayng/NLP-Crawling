### Sentiment Analysis with tidy data
# 라이브러리 로딩 및 데이터 준비
library(tidytext)
library(tidyverse)
library(textdata)
sentiments

### 감성분석에는 성향이나 감정을 평가하기 위한 사전이 필요
# --> 세가지 범용 사전 존재 (개별단어를 기반)
# 1. AFINN : 각 단어에 -5~5 사이의 값을 할당 (양수->긍정, 음수->부정)
# 2. bing  : 단어를 이진법으로 긍정적 범주와 부정적 범주로 분류 
# 3. nrc   : 긍정/부정, 분노, 기대, 두려움, 행복 등등을 이진법으로 표시
get_sentiments("afinn")
get_sentiments("bing")
get_sentiments("nrc")


### Sentiment Analysis using inner_join
# 분석을 위한 데이터 준비
library(gutenbergr)
hongloumeng_en <- gutenberg_download(c(9603, 9604), meta_fields = "title")
tidy_books <- hongloumeng_en %>%
  mutate(book = cumsum(str_detect(text, regex("HUNG LOU MENG, BOOK [I]+")))) %>%
  group_by(book) %>%
  mutate(linenumber = row_number(),
         chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc].", 
                                                 ignore_case = TRUE)))) %>%
  ungroup() %>%
  unnest_tokens(word, text)

# nrc 감성 사전 준비
nrc <- get_sentiments("nrc")
head(nrc, 10)

# 감성분석
nrc_joy <- nrc %>% filter(sentiment == "joy")
tidy_books %>% 
  filter(book == "1") %>% 
  inner_join(nrc_joy) %>%
  count(word, sort=T)

net_sentiment <- tidy_books %>% 
  inner_join(get_sentiments("bing")) %>% 
  count(book, index = linenumber %/% 100, sentiment) %>% 
  spread(sentiment, n, fill=0) %>% 
  mutate(sentiment = positive-negative)

ggplot(net_sentiment, mapping=aes(x=index, y=sentiment, fill=book)) +
  geom_col(show.legend = F) + facet_wrap(~book, ncol=2, scales="free_x")

afinn <- get_sentiments("afinn")
afinn <- tidy_books %>% 
  inner_join(afinn) %>%
  group_by(index = linenumber %/% 100) %>%
  summarise(sentiment = sum(value)) %>% 
  mutate(method = "AFINN")

bing_and_nrc <- bind_rows(tidy_books %>% 
                            inner_join(get_sentiments("bing")) %>%
                            mutate(method = "Bing et al."),
                          tidy_books %>% 
                            inner_join(nrc %>% 
                                         filter(sentiment %in% c("positive",
                                                                 "negative"))) %>%
                            mutate(method = "NRC")) %>% 
  count(method, index = linenumber %/% 100, sentiment) %>% 
  spread(sentiment, n, fill=0) %>% 
  mutate(sentiment = positive - negative)

bind_rows(afinn, bing_and_nrc) %>% 
  ggplot(mapping=aes(x=index, y=sentiment, fill=method)) +
  geom_col(show.legend = F) +
  facet_wrap(~method, ncol=1, scales = "free_y")

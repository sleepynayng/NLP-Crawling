### Example : English Text Mining 
library(janeaustenr)
library(tidytext)
library(tidyverse)

# 연습용 문서 다운로드 및 구조변경
original_books <- austen_books() %>% 
  group_by(book) %>% 
  mutate(linenumber = row_number(),
         chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]",
                                                 ignore_case = T)))) %>%
  ungroup(); original_books

# 문장을 단어로 구분(토큰화)
tidy_books <- original_books %>% 
  unnest_tokens(output="word", input="text"); tidy_books

# 불용어 준비 및 anti_join을 이용한 불용어 제거 
data("stop_words")
tidy_books <- tidy_books %>% anti_join(stop_words)

# 단어별 빈도 출력 및 시각화
tidy_books %>% group_by(word)  %>% 
  summarise(n=n()) %>% 
  arrange(desc(n)) %>%
  filter(n>500) %>% 
  ggplot(mapping=aes(x=fct_reorder(word, n), y=n)) +
  geom_col() + coord_flip() + xlab("word") + ylab("freq")

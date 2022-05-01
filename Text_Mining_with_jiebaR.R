### Chinese Text handling with jiebaR
# 깔끔한(tidy) 텍스트 형식 --> 한 줄에 하나의 기호
# 중국어는 단어를 구분하기 위한 공백을 사용하지 않음
# --> 단어 분할 결과가 항상 정확하지 않음 (초점 용어가 중요)
# --> <jiebaR> 사용! (--> 다중 단어 분할 방법 내장 및 불용어 지원)
library(jiebaR)

### R에서 사용하는 형식
# 1. 문자열(strings)   -> 기본적인 형식으로 텍스트 데이터는 메모리 로딩 형식
# 2. 말뭉치(corpus)    -> 추가 메타데이터 및 주식이 포함된 원시 문자열 포함
# 3. 문서용어행렬(dfm) -> 문서당 행 하나와 용어당 열 하나가 있는 문서모음

### Chinese simple Text handling
# apply for simple data
text <- c("床前明月光，",
          "疑是地上霜。",
          "举头望明月，",
          "低头思故乡。")

# 문장 부호 유지 및 문장 분리
cutter <- worker(bylines = T, symbol = T)
text_wb <- sapply(segment(text, cutter), function(x){
  paste(x, collapse = " ")})
print(text_wb)

# tidy 데이터셋 준비를 위한 데이터 프레임으로 분석
library(dplyr)
text_df <- tibble(line=1:4, text=text_wb)
print(text_df)

# unnest_tokens : 중첩된 텍스트에서 개별 토큰으로 분리
library(tidytext)
text_df %>% unnest_tokens(output="token", input="text")





### [Sample] Chinese Text Handling : Gutenbergr book
library(gutenbergr)
gutenberg_works(languages = "zh")


### Chinese Text Handling : 중국 대작을 중심으로
# 데이터 준비
library(mqxsr)
mingqingxiaoshuo <- books()

# 불용어 제거 및 토큰화
# ch_stop <- quanteda::stopwords("zh", source="misc",)
# write.table(x=ch_stop, file="C:\\Users\\cc933\\Desktop\\논문2\\stop_word_zh.txt", row.names=F)
setwd("C:\\Users\\cc933\\Desktop\\논문2")
cutter <- worker(bylines=T, stop_word = "C:\\Users\\cc933\\Desktop\\논문2\\stop_word_zh.txt")
tidy_mingqingxiaoshuo <- mingqingxiaoshuo %>% 
  mutate(text = sapply(segment(text, cutter), function(x){paste(x, collapse = " ")})) %>% 
  unnest_tokens(word, text)

stopwordCN <- read.table("stop_word_zh.txt", col.names = "word")
tidy_mingqingxiaoshuo <- tidy_mingqingxiaoshuo %>% 
  anti_join(stopwordCN, by = c("word"="word"))

# 빈도분석 출력
tidy_mingqingxiaoshuo %>% count(word, sort=T)

# 빈도분석 시각화
library(showtext)
showtext_auto()
tidy_mingqingxiaoshuo %>% 
  count(word, sort=T) %>% filter(n>=4000) %>%
  ggplot(mapping=aes(x=fct_reorder(word, n), y=n)) + geom_col() +
  xlab(NULL) + coord_flip() + theme(text=element_text(family="wqy-microhei"))

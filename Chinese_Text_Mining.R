### Chinese text analysis with quanteda
### 참조 : https://quanteda.io/articles/pkgdown/examples/chinese.html
### quanteda(퀀데다)의 목적 : 감정 분석 + 컨텐츠 분석
### quanteda가 이해하는 텍스트 : corpus, dfm(document-feature Matrix), token
# 1. corpus --> Documents separately from each other
# 2. dfm    --> Analytical unit on which we will perform analysis
#           --> consist of row(=original text) and column(=feature of that text)
# 3. token  --> each individual word in text
library(quanteda)


### Download Chinese Corpus
### 중국 국무원이 발행한 정부 업무 보고서
devtools::install_github("quanteda/quanteda.corpora")
library(quanteda.corpora)
corp <- quanteda.corpora::download(url = "https://www.dropbox.com/s/37ojd5knz1qeyul/data_corpus_chinesegovreport.rds?dl=1")
str(corp) # 49*4 (본문, 문서번호, 연도, 작성자)

### Tokenization
# Chinese stopwords(중국어 불용어) --> 분석에 필요없는 단어
ch_stop <- quanteda::stopwords("zh", source="misc")

# tokenize
ch_toks <- corp %>% 
  tokens(remove_punct = TRUE) %>% 
  tokens_remove(pattern=ch_stop)

# construct a Dfm
ch_dfm <- dfm(ch_toks)
topfeatures(ch_dfm) #가장 많은 특징의 단어

# Word cloud
library("quanteda.textplots")
library(showtext)
showtext_auto()    # for chinese character display
textplot_wordcloud(ch_dfm, min_count = 500, random_order = F,
                   rotation = 0.25, max_words = 150,
                   min_size = 0.5, max_size = 2.8,
                   font = if(Sys.info()["sysname"] == "Darwin") "SimHei" else NULL,
                   color = RColorBrewer::brewer.pal(8, "Dark2"))


### Feature co-occurrence matrix(FCM)
# fcm within the window size of 5
ch17_corp <- corpus_subset(corp, Year=="2017")
ch17_toks <- 
  tokens(ch17_corp, remove_punct = T) %>% 
  tokens_remove(ch_stop)
ch_fcm <- fcm(ch17_toks, context = "window")
topfeatures(ch_fcm["改革", ]) # 개혁과 관련 깊은 단어


### Unsupervised document scaling
library("quanteda.textmodels")
wf <- textmodel_wordfish(ch_dfm)
y <- 1954:2017
y <- y[y<=1964 | y>=1975]
y <- y[!y %in% c(1963, 1961, 1962, 1976, 1977)]
plot(y, wf$theta, xlab="Year", ylab="Position")


### Collocations
# bigrams cross the whole dataset
library("quanteda.textstats")
ch_col <- textstat_collocations(ch_toks, size=2, min_count=20)
knitr::kable(head(ch_col, 10))

# bigrams in 2017 report
ch17_col <- textstat_collocations(ch17_toks, size=2)
knitr::kable(head(ch17_col, 10))

### A Beginner's Guide to Text Analysis with Quanteda
# https://data.library.virginia.edu/a-beginners-guide-to-text-analysis-with-quanteda/
library(quanteda)
library(readtext)

### Get ready for Analysis
# Create a temparary directory to store texts
getwd()
dir.create("tmp")

# Download test texts
download.file(url = "https://www.gutenberg.org/files/1342/1342-0.txt", 
              destfile = "tmp/Pride and Prejudice_Jane Austen_2008_English.txt")
              
download.file(url = "https://www.gutenberg.org/files/98/98-0.txt",
              destfile = "tmp/A Tale of Two Cities_Charles Dickens_2009_English.txt")

# Read in Texts
dataframe <- readtext(file="tmp/*.txt",
                      docvarsfrom = "filenames",
                      docvarnames = c("title", "author",
                                      "year uploaded", "language"),
                      dvsep = "_",
                      encoding = "UTF-8")

# delete tmp directory
# unlink("tmp", recursive = T)



### Making Corpus for Analysis
# corpus is an object that quanteda understands
# we can make corpus object using quanteda::corpus() function
# suammary() show how many "type" and "tokens" in the text
#   1. type   : number of unique tokens a text contains
#   2. tokens : counts the number of words in a text
# process : corpus() --> tokens()
doc.corpus <- corpus(dataframe)
summary(doc.corpus)



### Tokens Cleaning and Creating
# 1. Creating tokens
# --> using quanteda::tokens(doc.corpus, what=c("word, "sentence","character"))
# 2. Cleaning useless tokens will speed up our analysis
# --> remove punctation, numbers, spaces, stem words, stop words
doc.tokens <- tokens(doc.corpus)
doc.tokens <- tokens(doc.tokens, remove_punct = T, remove_numbers = T)
doc.tokens <- tokens_select(doc.tokens, stopwords("english"), selection="remove")
doc.tokens <- tokens_wordstem(doc.tokens)
doc.tokens <- tokens_tolower(doc.tokens)
summary(doc.tokens)

### Converting to a DFM(Document Feature Matrix)
#   --> dfm(doc.tokens)
doc.dfm.final <- dfm(doc.tokens)

### Initial Analysis (초기분석)
# kwic(pattern, window) : 문맥 내 키워드 출력
# --> pattern = 키워드(regexp), window = 출력할 앞/뒤 근접 단어 수
# --> only working doc.token object not doc.dfm object
kwic(doc.tokens, pattern="love", window=3)
kwic(doc.tokens, pattern="sky", window=3)

# topfeature(x, n) : 텍스트에서 가장 많이 사용되는 단어
# --> only working doc.dfm object not doc.token
topfeatures(doc.dfm.final, n=20)

# topfeature Visualization
library(tidyverse)
topfeatures(doc.dfm.final, n=20) %>% 
  as.data.frame() %>% setNames(c("freq"))  %>%
  mutate("word"=rownames(.)) %>% 
  ggplot(mapping=aes(x=fct_reorder(word, freq), y=freq)) + 
  geom_col(fill="skyblue") + coord_flip() +
  xlab("빈도") + ylab("단어")

### R 크롤링
### 크롤링과정
# 1. 데이터 요청하고 응답받는 과정 --> <httr> 패키지
# 2. 응답받은 데이터에서 필요한 내용 추출 과정 --> <rvest> 패키지

library(httr)
library(rvest)
library(tidyverse)
library(tidytext)

### 이론 : 웹 작동방식 
# 인터넷상에서 HTTP(HyperText Transfer Protocol)을 이용해 정보처리
# 클라이언트(의뢰자)가 정보제공을 요청(Request) --> 서버(제공자)가 요청에 응답(Response)
# 모든 웹 서버는 URL이라는 고유의 주소를 가지고 있음
# URL의 구조 : 웹서버이름(hostname) + 웹페이지의 경로(path) + 질의문(Query)
# ex) https://news.naver.com/main/main.nhn?mode=LSD&mid=shm&sid1=101
# 1. hostname = "https://news.naver.com/
# 2. path = "main/main.nhn?"
# 3. query = "mode=LSD&min=shm&sid1=101"


### 연습 : 웹 작동방식
#  https://search.naver.com/ --> hostname
#  search.naver?             --> path
#  where=news&query=%EB%B0%B1%EC%8B%A0 (*query = "백신" = %EB%B0%B1%EC%8B%A0)
#  &sm=tab_opt& sort=0&photo=0&field=0&reporter_article=&pd=3&ds=2020.01.01&
#  de=2020.01.02&docid=&nso=so%3Ar%2Cp%3Afrom20200101to20200102%2Ca%3Aall&
#  mynews=0&refresh_start=0&related=0
#  * ds=시작일, de=종료일, nso=기간설정
#  * 파라미터 값이 없거나 0인경우 지정되지 않은 파라미터



### 이론 : HTTP요청과 응답 <httr>
# 클라이언트가 웹서버의 응답을 HTTP 방식으로 요청할때의 방식
# --> GET, POST, PUT, DELETE 4개의 방식
# 크롤링할때 사용하는 방식 : GET, POST
# 1. GET방식의 요청  : 질의문(query)가 URL에 모두 표시, URL로 요청
# 2. POST방식의 요청 : 질의문(query)가 웹브라우저의 주소창에 나타나지 않음
#                    : 즉, 클라이언트가 요청에 필요한 질의정보를 찾아서 요청


### 적용 : <httr>
# 1. GET() 함수 사용  --> 해당 객체에 응답에 대한 메타데이터 포함
#                     --> status:2xx(성공), 5xx(서버오류), 4xx(클라이언트오류)
wiki_url <-'https://ko.wikipedia.org/wiki/HTML'
response <- GET(wiki_url)
response$status_code 

# 2. POST() 함수 사용 --> 웹브라우저 주소에 질의정보가 없을때 사용
#                     --> 마우스오른쪽버튼->[검사]->[네트워크]->[문서]->Ctrl+R
#                     --> [Form data]에 있는 인수 전달
# * 서버 접속이 지연되면 User-Agent 지정!
host <- 'https://www.kci.go.kr/kciportal/po/search/poTotalSearList.kci'
url <- POST(
  host, body = list(
    poSearchBean.printKeyword = '백신',
    poSearchBean.keyword = '백신',
    poSearchBean.searType = "all",
    poSearchBean.sortDir = 'desc',
    poSearchBean.docsCount = 10,
    poSearchBean.startPg = 1,
    reSrchCondition = 'all',
    reSrchKeyword = '백신',
    from = 'searchFromTotal'))
url$status_code



### 텍스트 추출 : <rvest>
# 1. HTML 문서 불러오기 : read_html()
# 2. HTML 문서에서 HTML 요소 추출하기
#    --> html_node(), html_nodes()
# 3. HTML 요소에서 내용 혹은 속성의 값 추출
#    --> html_text(), html_table(), html_attr(), html_attrs()

### 1. read_html() : HTML문서로 불러오기
url <- GET("https://ko.wikipedia.org/wiki/HTML")
read_html(url)

### 2. html_node()  : 일치하는 요소 하나 만을 추출
###    html_nodes() : 공통적으로 적용되는 여러 요소 추출

### HTML문서 구조 : <head> 섹션 + <body> 섹션
# 1. <head>섹션 : 메타데이터가 포함
# 2. <body>섹션 : 사용자에게 보여지는 내용 포함
read_html(url) %>% html_node("head") # <head>섹션에 있는 HTML 요소 추출
read_html(url) %>% html_node("body") # <body>섹션에 있는 HTML 요소 추출
read_html(url) %>% html_node("div")  # 처음 <div> 구획 안의 HTML 요소 추출
read_html(url) %>% html_nodes("div")
read_html(url) %>% html_node("body") %>% html_node("div")



### HTML 요소(element)의 종류
### HTML 요소 : 태그(tag), 속성(attribute), 속성의 값(value), 내용


### 1. 태그(Tag) : HTML의 구조와 내용을 정함
#   -------------------------------------------------------------------
##  a. 속성(attribute)을 사용하지 않는 태그
#   --> head  : HTML의 헤더, 메타데이터를 담고 있다.
#   --> body  : HTML의 본문, 사용자에게 보여지는 부분
#   --> h~h6  : 제목설정, 숫자가 클수록 크게 표시
#   --> p     : 단락(paragraph) 구분
#   --> br    : 공백(<br>태그는 종료 태그가 없다)
#   -------------------------------------------------------------------
##  b. 속성(attribute)을 함께 사용하는 태그
#   --> a     : 하이퍼링크 정의. URL을 지정하는 href 속성과 함께 사용
#   --> img   : 이미지 정의. 이미지파일을 지정하는 src 속성과 함께 사용
#   --> span  : 본문 안에서 특정 부분 지정. style 속성과 함께 사용
#   -------------------------------------------------------------------
##  c. 목록과 표 구성에 사용되는 태그
#   --> ol    : 목록 지정 (순서 목록)
#   --> ul    : 목록 지정 (순서없는 목록)
#   --> li    : 목록 안의 아이템 (ol, ul태그 안에서 함께 사용)
#   --> table : 표 지정 (tr : 행, th : 행이름, td : 데이터)
#   -------------------------------------------------------------------



### 2. CSS selector(속성 및 값)
# HTML태그는 style 속성과 함께 사용해 웹페이지의 표현방식을 지정
# --> 단일 HTML 요소의 표현 양식만을 지정 
# --> 여러 HTML 요소에 공통적으로 표현양식 지정 필요 --> CSS 사용!
# HTML : 웹페이지의 구조와 내용 정의
# CSS  : 웹페이지의 표현(Style) 방식 지정

# CSS selector  : 웹페이지 하부요소의 표현양식을 지정하는데 사용되나
#               : HTML 문서에서 특정 요소를 찾아 추출하는데 유용
# 속성 -----------------------------------------------------------------------------
# 1. class(클래스) : CSS selector에서 일련의 태그에 공통적으로 지정하는 속성의 이름
#                  : 태그 다음에 "."을 이용해 표기
# ex) div.myDiv인 경우 div 태그 속성의 값이 myDiv인 모든 HTML 요소

# 2. ID(아이디)    : CSS selector에서 특정 HTML 요소의 표현양식만 지정할때 사용
#                  : 속성명을 ID로 지정하면 "#"로 구분 
#                  : 태그명을 같이 지정하지 않는다(해당 웹페이지에서 유일)
# ex) #thisDiv인 경우 ID가 thisDiv인 HTML요소
# ----------------------------------------------------------------------------------

## 예제 : HTML항목에서 div태그에서 속성의 이름이 class이고
#       : 속성의 값이 vector-menu-content인 HTML요소 추출
read_html(url) %>% html_nodes("div.vector-menu-content")

### ">" 서열 구조로 특정 요소에서 요소(태그, 속성)을 선택할때 사용
# ex) #mw-content-text > div.my-parser-output


### HTML요소에서 내용 추출
# 1. 텍스트 내용 추출 : html_text()
read_html(url) %>% 
  html_nodes("#mw-content-text") %>% html_node("p") %>% 
  html_text2()

# 2. HTML요소에서 속성의 내용을 추출 : html_attr(), html_attrs()
#    --> 주로 url이나 사진 지정할때 사용!
#    --> name = "href","class", "title", "id", "style"
# url 크롤링
read_html(url) %>% 
  html_nodes("#mw-content-text > div.mw-parser-output > p:nth-child(9) > a:nth-child(1)") %>% 
  html_attr(name = "href")
# class 속성 값 크롤링
read_html(url) %>% 
  html_nodes("#mw-content-text > div.mw-parser-output > div:nth-child(8)") %>% 
  html_attr(name="class")

# 3.웹페이지의 내용 중에 표로 정리된 부분 : html_table()
url <- "https://www.w3schools.com/html/html_tables.asp"
table_tb <- read_html(url) %>% 
  html_nodes("#main > table") %>%  
  html_table()
table_tb %>% glimpse()


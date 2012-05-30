
###
 * ==========================================================
 * Name:    hackernews-api.js v0.1
 * Author:  Eric E. Lewis
 * Website: http://www.boxy.co
 * ===================================================
 * Copyright 2012 boxyco, LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ==========================================================
###
# config(ish), port to bind to, jquery cdn url
listen_port =  if process.argv[2] == undefined then 1337 else process.argv[2].substring 2
jquery_url  = 'http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'

# ------- required files
jsdom  = require 'jsdom' 
api    = require('express').createServer()

# ------- reused functions
## console logger for debug + tracking
log = (msg) ->
 console.log msg
 return
 
pageScraper = (req, res, errors, window) ->
    # scrape the links with jquery
    $ = window.$
    links = []

    $('td.title:not(:last) a').each -> 
      item = $(this)
      itemSubText = item.parent().parent().next().children '.subtext'
      itemLinkText    = item.next().text().trim()

      links[links.length] =
        href       : if itemLinkText != '' then item.attr('href') else 'http://news.ycombinator.com/' + item.attr 'href'
        title      : item.text()
        subtitle   : itemSubText.text()
        postedby   : itemSubText.children('a:eq(0)').text()
        site       : if itemLinkText != '' then itemLinkText else '(Hacker News)'
        discussid  : itemSubText.children('a:eq(1)').attr('href').substring 8

      return
    

    # get the link for the next page
    nextPageLink = $('td.title:last a').attr 'href' 
    	
    res.json 
      links : links,
      next  : if nextPageLink == 'news2' then nextPageLink else 
              try
               nextPageLink.split("=")[1]
    
    return

commentScraper = (req, res, errors, window) ->
	# set the url to be scrap, add the id if provided
	html  = 'http://news.ycombinator.com/threads?id='
	userid  = req.params.id
	
	# scrap the page now!
	jsdom.env 
	html: html + userid,
	scripts:  [ jquery_url ]
	done: (errors, window) ->
	$ = window.$
	comments = []
	
	$('td .default > span').each ->
		comments[comments.length] = 
			text     : $(this).text()
			indent   : $(this).parent().prev().prev().children('img').attr('width') / 40
			postedby : $(this).parent().children('div').children('span').children('a:eq(0)').text()
			posttime : $(this).parent().children('div').children('span').children('a').remove() and $('td .default > span').parent().children('div').children('span').text().substring(0,14).trim()
		return
	
	res.json comments: comments
	return
					
	return

# ------- redirect / to news
api.get '/', (req,res) -> 
 res.redirect '/news/'
 return


# ------- get news, and get news by pageid
api.get '/news/:page?', (req,res) -> 
 
 # set the url to be scrap, add the id if provided
 html  = 'http://news.ycombinator.com/'
 page  = req.params.page
 
 html += 'x?fnid=' if page != undefined and page != 'news2'
 html += page if page != undefined
 
 # scrap the page now!
 jsdom.env 
   html: html,
   scripts:  [ jquery_url ]
   done: (errors, window) ->
   			pageScraper req, res, errors, window
   			return
	
 return
 
# ------- get post comments by discuss id
api.get '/news/:id/comments', (req,res) ->
 # set the url to be scrap, add the id if provided
 html  = 'http://news.ycombinator.com/item?id='
 userid  = req.params.id
 
 # scrap the page now!
 jsdom.env 
   html: html + userid,
   scripts:  [ jquery_url ]
   done: (errors, window) ->
    commentScraper req, res, errors, window
    return
   				
 return
 
# ------- get news, and get news by pageid
api.get '/news/:page?', (req,res) -> 
 
 # set the url to be scrap, add the id if provided
 html  = 'http://news.ycombinator.com/'
 page  = req.params.page
 
 html += 'x?fnid=' if page != undefined and page != 'news2'
 html += page if page != undefined
 
 # scrap the page now!
 jsdom.env 
   html: html,
   scripts:  [ jquery_url ]
   done: (errors, window) ->
   			pageScraper req, res, errors, window
   			return
	
 return
 
# ------- get ask HN news
api.get '/ask', (req,res) ->
 # set the url to be scrap, add the id if provided
 html  = 'http://news.ycombinator.com/ask'
 
 # scrap the page now!
 jsdom.env 
   html: html,
   scripts:  [ jquery_url ]
   done: (errors, window) ->
    pageScraper req, res, errors, window
    return
   				
 return


# ------- get user profile by id
api.get '/user/:id?', (req,res) -> 
 
 # set the url to be scraped, add the id if provided
 html = 'http://news.ycombinator.com/user?id='
 userid = req.params.id

 if userid != undefined

	 # scrape the page now!
	 jsdom.env 
	   html: html + userid,
	   scripts:  [ jquery_url ]
	   done: (errors, window) ->
		    # scrape the links with jquery
		    $ = window.$
		   
		    profile = $('form tr td:odd')
		    try
			    res.json
			    	username : profile.get(0).innerHTML
			    	created  : profile.get(1).innerHTML
			    	karma    : profile.get(2).innerHTML
			    	average  : profile.get(3).innerHTML
			    	about    : profile.get(4).innerHTML
			    	
		    return
	
	 
 else
  res.json error: 'no userid specified'
  
 return


# ------- get user submissions by user id
api.get '/user/:id/submissions?', (req,res) ->
 
 # set the url to be scraped, add the id if provided
 html   = 'http://news.ycombinator.com/submitted?id='
 userid = req.params.id

 if userid != undefined

	 # scrape the page now!
	 jsdom.env 
	   html: html + userid,
	   scripts:  [ jquery_url ]
	   done: (errors, window) ->
   			pageScraper req, res, errors, window
   			return
	
	 
 else
  res.json error: 'no userid specified' 
  
 return
 
# ------- get user comments by user id
api.get '/user/:id/comments', (req,res) ->
 # set the url to be scrap, add the id if provided
 html  = 'http://news.ycombinator.com/threads?id='
 userid  = req.params.id
 
 # scrap the page now!
 jsdom.env 
   html: html + userid,
   scripts:  [ jquery_url ]
   done: (errors, window) ->
    commentScraper req, res, errors, window
    return
   				
 return
 
# bind the server to the port!
api.listen listen_port 
log 'hackernews api running on port ' + listen_port 
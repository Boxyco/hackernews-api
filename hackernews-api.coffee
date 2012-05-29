
###
 * ==========================================================
 * hackernews-api.js v0.1
 * Eric E. Lewis
 * http://ericlewis.github.com
 * requires: node, express, jsdom, and jQuery 1.7+
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

# config(ish), port to bind to, absolute or relative path to jquery file
listen_port   = 1337
jquery_path = './'

# ------- required files
jsdom  = require 'jsdom' 
jquery = require('fs').readFileSync(jquery_path + "jquery.js").toString()
api    = require('express').createServer()

# ------- reused functions
## console logger for debug + tracking
log = (msg) ->
 console.log msg
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
   src:  [ jquery ]
   done: (errors, window) ->
    # scrape the links with jquery
    $ = window.$
    links = []

    $('td.title:not(:last) a').each -> 
      item = $(this)
      itemSubText = item.parent().parent().next().children '.subtext'
      itemLinkText    = item.next().text().trim()

      links[links.length] =
        href     : if itemLinkText != '' then item.attr('href') else 'http://news.ycombinator.com/' + item.attr 'href'
        title    : item.text()
        subtitle : itemSubText.text()
        postedby : itemSubText.children('a:eq(0)').text()
        site     : if itemLinkText != '' then itemLinkText else '(Hacker News)'
        discuss  : 'http://news.ycombinator.com/' + itemSubText.children('a:eq(1)').attr 'href'

      return
    

    # get the link for the next page
    nextPageLink = $('td.title:last a').attr 'href' 
    	
    res.send JSON.stringify 
      links : links,
      next  : if nextPageLink == 'news2' then nextPageLink else nextPageLink.split("=")[1]
    
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
	   src:  [ jquery ]
	   done: (errors, window) ->
		    # scrape the links with jquery
		    $ = window.$
		   
		    profile = $('form tr td:odd')

		    result =
		    	username : profile.get(0).innerHTML
				created  : profile.get(1).innerHTML
				karma    : profile.get(2).innerHTML
				average  : profile.get(3).innerHTML
				about    : profile.get(4).innerHTML
	
		    res.send JSON.stringify result

		    return
	
	 
 else
  res.send JSON.stringify error: 'no userid specified'
  
 return


# ------- get user submissions by id
api.get '/user/:id/submissions?', (req,res) ->
 
 # set the url to be scraped, add the id if provided
 html   = 'http://news.ycombinator.com/submitted?id='
 userid = req.params.id

 if userid != undefined

	 # scrape the page now!
	 jsdom.env 
	   html: html + userid,
	   src:  [ jquery ]
	   done: (errors, window) ->
		    # scrape the links with jquery
		    $ = window.$
		    links = []
		
		    $('td.title:not(:last) a').each -> 
		      item = $(this)
		      itemSubText = item.parent().parent().next().children '.subtext'
		      itemLinkText    = item.next().text().trim()
		
		      links[links.length] =
		        href     : if itemLinkText != '' then item.attr 'href' else 'http://news.ycombinator.com/' + item.attr 'href'
		        title    : item.text()
		        subtitle : itemSubText.text()
		        postedby : itemSubText.children('a:eq(0)').text()
		        site     : if itemLinkText != '' then itemLinkText else '(Hacker News)'
		        discuss  : 'http://news.ycombinator.com/' + itemSubText.children('a:eq(1)').attr 'href'
		         
		      return
		    
		
		    # get the link for the next page
		    nextPageLink = $('td.title:last a').attr 'href'
		
		    res.send JSON.stringify 
		      links : links,
		      next  : if nextPageLink == 'news2' then nextPageLink else nextPageLink.split("=")[1]
		    
		    
		    return
	
	 
 else
  res.send JSON.stringify error: 'no userid specified' 
  
 return


api.listen listen_port 
log 'hackernews api running on port ' + listen_port 
###
 * ==========================================================
 * Name:    hackernews-api.js v0.2
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

jsdom  = require 'jsdom'
server = require('express').createServer()

config = require('./config')

version = config.server.version

#
# Functions
#
tools =
	commentScraper : (req, res, errors, window) ->
		$ = window.$
		
		comments = []	
		
		$('td .default > span').each ->
			parent = $(this).parent()
			childspan = parent.children('div').children('span')

			comments[comments.length] = 
				comment   : $(this).children('font').html()
				indent    : parseInt parent.prev().prev().children('img').attr('width') / 40
				postedBy  : childspan.children('a:eq(0)').text()
				postedAgo : childspan.children('a').remove() and parent.children('div').children('span').text().substring(0,15).trim()
			return
		
		if comments.length > 0 then res.json comments: comments, requestTime: new Date(), version:version, 200 else res.json error: 'no comments found', requestTime: new Date(), version:version,  404
			
		return
		
		
	pageScraper : (req, res, errors, window) ->
	    # scrape the links with jquery
	    $ = window.$
	    links = []
	
	    $('td.title:not(:last) a').each -> 
	      item = $(this)
	      itemSubText = item.parent().parent().next().children '.subtext'
	      itemLinkText    = item.next().text().trim()

	      links[links.length] =
	        url          : if item.attr('href').indexOf('http') is 0 then item.attr('href') else "#{config.server.base_url}#{item.attr 'href'}"
	        title        : item.text()
	        points    	 : parseInt itemSubText.children('span').text().split(' ')[0]
	        postedBy   	 : itemSubText.children('a:eq(0)').text()
	        postedAgo 	 : itemSubText.text().split(' ').slice(4,-4).join(' ')
	        commentCount : parseInt itemSubText.children('a:eq(1)').text().split(' ')[0]
	        id   	     : parseInt itemSubText.children('a:eq(1)').attr('href')?.substring 8
	        site		 : if item.attr('href').indexOf('http') is 0 then item.parent().children('span').text().trim() else "(ycombinator.com)"
	
	      return
	    
	
	    # get the link for the next page
	    nextPageLink = $('td.title:last a').attr('href')
	    nextPageLink = if nextPageLink != 'news2' then nextPageLink.split('=')[1] else nextPageLink
	    
	    if links.length > 0 then res.json links: links, nextId: nextPageLink, requestTime: new Date(), version:version,  200 else res.json error: 'no links found', requestTime: new Date(), version:version,  404
	    
	    return
	    
	 profileScraper: (req, res, errors, window) ->
	 	# scrape the links with jquery
	    $ = window.$
	
	    item = $('form tr td:odd')

	    profile = 
	    	about      : item.get(4).innerHTML
	    	username   : item.get(0).innerHTML
	    	createdAgo : item.get(1).innerHTML
	    	karma	   : parseInt item.get(2).innerHTML
	    
	    res.json profile: profile, requestTime: new Date(),  version:version, 200
	    
	    return  

# allow any access origin	    
server.get '/*', (req,res,next) ->
    res.header 'Access-Control-Allow-Origin' , '*'
    next()
		
# ------- get post comments by discuss id
server.get '/discuss/:id?', (req, res) ->
	# set the url to be scrap, add the id if provided
	html  = "#{config.server.base_url}item?id="
	thread  = req.params.id
	
	# scrap the page now!
	jsdom.env 
		html: "#{html}#{thread}",
		scripts:  [ config.server.jquery_url ]
		done: (errors, window) ->
			try
				tools.commentScraper req, res, errors, window
			catch err
				res.json error: 'invalid id', requestTime: new Date(), version:version,  404
			return
			
server.get '/profile/:userid?', (req, res) ->
	userid = req.params.userid
	html = "#{config.server.base_url}user?id=#{userid}"
	
	jsdom.env 
		html: html,
		scripts:  [ config.server.jquery_url ]
		done: (errors, window) ->
			try
				tools.profileScraper req, res, errors, window
			catch err
				res.json error: 'invalid username', requestTime: new Date(), version:version,  404
			return	
						
server.get '/profile/:id/comments?', (req, res) ->
	# set the url to be scrap, add the id if provided
	html  = "#{config.server.base_url}threads?id="
	userid  = req.params.id
	
	# scrap the page now!
	jsdom.env 
		html: "#{html}#{userid}",
		scripts:  [ config.server.jquery_url ]
		done: (errors, window) ->
			try
				tools.commentScraper req, res, errors, window
			catch err
				res.json error: 'invalid id', requestTime: new Date(), version:version,  404
			return		

server.get '/profile/:id/submissions?/:page?', (req, res) ->
	# set the url to be scrap, add the id if provided
	html  = "#{config.server.base_url}submitted?id="
	userid  = req.params.id

	# scrap the page now!
	jsdom.env 
		html: "#{html}#{userid}",
		scripts:  [ config.server.jquery_url ]
		done: (errors, window) ->
			try
				tools.pageScraper req, res, errors, window
			catch err
				res.json error: 'invalid username', requestTime: new Date(), version:version,  404
			return		
   			
server.get '/:root/:page?', (req,res) -> 
 
 # set the url to be scrap, add the id if provided
 root   = req.params.root
 page   = req.params.page
 
 html = if not page? then "#{config.server.base_url}#{root}" else if page is 'news2' then "#{config.server.base_url}#{page}" else "#{config.server.base_url}x?fnid=#{page}"

 # scrap the page now!
 jsdom.env 
   html: html,
   scripts:  [ config.server.jquery_url ]
   done: (errors, window) ->
   			try
   				tools.pageScraper req, res, errors, window
   			catch err
   				res.json error: 'invalid nextId', requestTime: new Date(), version:version, 404
   			return		

server.get '*', (req, res)->
	res.json error:'could not find a related method', requestTime: new Date(), version:version, 404

# ------- bind server
server.listen config.server.listen_port 
console.log "Server running on port: #{config.server.listen_port}"
/*
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
*/

var api, commentScraper, jquery_url, jsdom, listen_port, log, pageScraper;

listen_port = process.argv[2] === void 0 ? 1337 : process.argv[2].substring(2);

jquery_url = 'http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js';

jsdom = require('jsdom');

api = require('express').createServer();

log = function(msg) {
  console.log(msg);
};

pageScraper = function(req, res, errors, window) {
  var $, links, nextPageLink;
  $ = window.$;
  links = [];
  $('td.title:not(:last) a').each(function() {
    var item, itemLinkText, itemSubText;
    item = $(this);
    itemSubText = item.parent().parent().next().children('.subtext');
    itemLinkText = item.next().text().trim();
    links[links.length] = {
      href: itemLinkText !== '' ? item.attr('href') : 'http://news.ycombinator.com/' + item.attr('href'),
      title: item.text(),
      subtitle: itemSubText.text(),
      postedby: itemSubText.children('a:eq(0)').text(),
      site: itemLinkText !== '' ? itemLinkText : '(Hacker News)',
      discuss: itemSubText.children('a:eq(1)').attr('href').substring(8)
    };
  });
  nextPageLink = $('td.title:last a').attr('href');
  res.json({
    links: links,
    next: (function() {
      if (nextPageLink === 'news2') {
        return nextPageLink;
      } else {
        try {
          return nextPageLink.split("=")[1];
        } catch (_error) {}
      }
    })()
  });
};

commentScraper = function(req, res, errors, window) {
  var $, comments, html, userid;
  html = 'http://news.ycombinator.com/threads?id=';
  userid = req.params.id;
  jsdom.env;
  ({
    html: html + userid,
    scripts: [jquery_url],
    done: function(errors, window) {}
  });
  $ = window.$;
  comments = [];
  $('td .default > span').each(function() {
    comments[comments.length] = {
      text: $(this).text(),
      indent: $(this).parent().prev().prev().children('img').attr('width') / 40,
      postedby: $(this).parent().children('div').children('span').children('a:eq(0)').text(),
      posttime: $(this).parent().children('div').children('span').children('a').remove() && $('td .default > span').parent().children('div').children('span').text().substring(0, 14).trim()
    };
  });
  res.json({
    comments: comments
  });
  return;
};

api.get('/', function(req, res) {
  res.redirect('/news/');
});

api.get('/news/:page?', function(req, res) {
  var html, page;
  html = 'http://news.ycombinator.com/';
  page = req.params.page;
  if (page !== void 0 && page !== 'news2') {
    html += 'x?fnid=';
  }
  if (page !== void 0) {
    html += page;
  }
  jsdom.env({
    html: html,
    scripts: [jquery_url],
    done: function(errors, window) {
      pageScraper(req, res, errors, window);
    }
  });
});

api.get('/news/:page?', function(req, res) {
  var html, page;
  html = 'http://news.ycombinator.com/';
  page = req.params.page;
  if (page !== void 0 && page !== 'news2') {
    html += 'x?fnid=';
  }
  if (page !== void 0) {
    html += page;
  }
  jsdom.env({
    html: html,
    scripts: [jquery_url],
    done: function(errors, window) {
      pageScraper(req, res, errors, window);
    }
  });
});

api.get('/news/ask', function(req, res) {
  var html;
  html = 'http://news.ycombinator.com/ask';
  userid = req.params.id;
  jsdom.env({
    html: html,
    scripts: [jquery_url],
    done: function(errors, window) {
      pageScraper(req, res, errors, window);
    }
  });
});

api.get('/user/:id?', function(req, res) {
  var html, userid;
  html = 'http://news.ycombinator.com/user?id=';
  userid = req.params.id;
  if (userid !== void 0) {
    jsdom.env({
      html: html + userid,
      scripts: [jquery_url],
      done: function(errors, window) {
        var $, profile;
        $ = window.$;
        profile = $('form tr td:odd');
        try {
          res.json({
            username: profile.get(0).innerHTML,
            created: profile.get(1).innerHTML,
            karma: profile.get(2).innerHTML,
            average: profile.get(3).innerHTML,
            about: profile.get(4).innerHTML
          });
        } catch (_error) {}
      }
    });
  } else {
    res.json({
      error: 'no userid specified'
    });
  }
});

api.get('/user/:id/submissions?', function(req, res) {
  var html, userid;
  html = 'http://news.ycombinator.com/submitted?id=';
  userid = req.params.id;
  if (userid !== void 0) {
    jsdom.env({
      html: html + userid,
      scripts: [jquery_url],
      done: function(errors, window) {
        pageScraper(req, res, errors, window);
      }
    });
  } else {
    res.json({
      error: 'no userid specified'
    });
  }
});

api.get('/user/:id/comments', function(req, res) {
  var html, userid;
  html = 'http://news.ycombinator.com/threads?id=';
  userid = req.params.id;
  jsdom.env({
    html: html + userid,
    scripts: [jquery_url],
    done: function(errors, window) {
      commentScraper(req, res, errors, window);
    }
  });
});

api.listen(listen_port);

log('hackernews api running on port ' + listen_port);
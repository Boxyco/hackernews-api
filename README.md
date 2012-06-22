# Hacker News API

RESTful http://news.ycombinator.com API written in Coffeescript for node.js, utilizing jQuery, JsDOM, and express.
####live demo url:
http://hnapi.boxy.co:1337

## Routes
### Retrieve Front Page News
#### URL: http://localhost:1337/news or http://localhost:1337/news/{nextId}
#### Method: GET
#### Returns: nextId: ID for next page of links
#### items: array of links {commentCount, id, points, postedAgo, postedBy, title, url}


## Developers
####Node.js dependencies
+ Our script depends on jsdom and express. To install, just run the following commands in npm:

```
$ npm install express
```

```
$ npm install jsdom
```

####Compiling Instructions
+ Compiling requires coffeescript, doesn't matter what flavor. If you are using npm:
```
$ npm install -g coffee-script
```

+ Compiling for production
```
$ coffee --compile hackernews-api.coffee
```
+ Or live compiling
```
$ coffee --watch --compile hackernews-api.coffee
```
+ Then run it!
```
$ nodejs hackernews-api.js -p1337
```

## Author(s)

**Eric Lewis**

+ http://twitter.com/ericlewis
+ http://github.com/ericlewis

## Copyright and license
Copyright 2012 boxyco, LLC.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
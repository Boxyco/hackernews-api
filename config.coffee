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

config = 
	server :
		listen_port	: 1337
		base_url	: 'http://news.ycombinator.com/'
		jquery_url	: 'http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'
		
module.exports = config
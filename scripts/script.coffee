class TRSW
	constructor: (@divname,@lastid=0,@tweetUsers=[],@buildString="",@tweetlist=[],@last_key=undefined,@time_out_id = 0,@delta=5000,@first_time=true) ->
		@first_time = true
	
#	[new_one,one,show,GetMatchingStatuses,FormatTweets,TweetTick,formatTwitString,relativeTime] = [null,null,null,null,null,null,null,null]
		
	one: (user, key) =>
#		console.log "::one top"
#		$(@divname).html ""	if @tweetUsers[0] isnt user	if @tweetUsers.length
#		$(@divname).html ""	if @last_key isnt key
		$(@divname).html " "
		$(@divname).html " "
		@last_key = key
		@lastID = 0
		clearTimeout @time_out_id
		$("#tweet-container").html ""
#		console.log "::one, user " + user + " key " + key
		@tweetUsers[0] = user
		@tweetUsers.length = 0	if user is ""
		@buildString = encodeURI(key)
		if @tweetUsers.length
			@buildString += "+from"
			i = 0
			while i < @tweetUsers.length
				@buildString += "+OR+"	unless i is 0
				@buildString += "%3A" + encodeURI(@tweetUsers[i])
				i++
#		console.log "::one about to call getmatching statuses and tweettick"
		@GetMatchingStatuses @buildString
#		console.log "::one called getmatching statuses about to call tweettick"
		@TweetTick()
		null

	show: (text, target) =>
		out = $("#" + target)
		out.hide()
		out.html text
		out.fadeIn()
		null

	GetMatchingStatuses: (qString) =>
		twitterapiurl = "http://search.twitter.com/search.json?since_id=" + @lastID + "&q=" + qString + "&rpp=100&callback=?"
		@show("GetMatchingStatuses first " + @first_time + " apiurl " + twitterapiurl, "info-console")
		$.getJSON twitterapiurl, (data) =>
#			console.log "::GetmatchingStatuses returned from ajax call to twitterapiurl"
			@FormatTweets data
#			console.log "::GetmatchingStatuses got past formatting tweets,first time #{@first_time}"
			@first_time = false	if @first_time is true	
			null	
		null	

	FormatTweets: (data) =>
		newlist = []
		container = $("#{@divname}")
		dr = $(data.results).sort((a, b) ->
			a.id - b.id
		)
		
		context_par = this;
		relTimeFunc = @relativeTime
		formStrFunc = @formatTwitString
		divName = @divname
		firstTimeIn = @first_time
		newTweets = false
		lastID = null
		plastID = @lastID

#		console.log  "plastID #{plastID} @lastID #{@lastID}"
		dr.each (el) ->
#			console.log "inspect this " + JSON.stringify(this)
			if not plastID or @id > plastID
				lastID = @id
				TimeForThisCall = @created_at
				str = """
					<div class="tweet">
						<div class="avatar"><a href="http://twitter.com/#{@from_user}" target="_blank">
							<img src="#{@profile_image_url}" alt="#{@from_user}"></a>
						</div>
						<div class="user"><a href="http://twitter.com/#{@from_user}" target="_blank">#{@from_user}</a></div>
						<div class="time" rel="#{TimeForThisCall}">#{relTimeFunc(TimeForThisCall)}</div>
						<div class="txt">#{formStrFunc(@text)}</div>
					</div>
				"""
				container.prepend str
				newTweets = true
		@lastID = lastID if lastID
		container.find(".tweet").each (i,el) ->
		    $(this).remove() if i > 50
		        
		    
		
		
		container.find("> .tweet").first().hide().slideDown()	if firstTimeIn is false and newTweets

		container.find("> .tweet>.time").each (el) ->
			$this = $(this)
			TimeForThisCall = $this.attr("rel")
			newTime = relTimeFunc(TimeForThisCall)
			$this.text newTime
			
#		@first_time = false	if @first_time is true
		null

	TweetTick: =>
#		console.log "::TweetTick, buildstring #{@buildString}"
		@GetMatchingStatuses @buildString
#		console.log "::TweetTick returned from get matching statuses, buildstring #{@buildString}"
		@time_out_id = setTimeout( @TweetTick, @delta)
#		console.log "::TweetTick after timeout, buildstring #{@buildString}"
		null

	formatTwitString: (str) =>
		str = " " + str
		str = str.replace(/((ftp|https?):\/\/([-\w\.]+)+(:\d+)?(\/([\w/_\.]*(\?\S+)?)?)?)/g, "<a href=\"$1\" target=\"_blank\">$1</a>")
		str = str.replace(/([^\w])\@([\w\-]+)/g, "$1@<a href=\"http://twitter.com/$2\" target=\"_blank\">$2</a>")
		str = str.replace(/([^\w])\#([\w\-]+)/g, "$1<a href=\"http://twitter.com/search?q=%23$2\" target=\"_blank\">#$2</a>")
		str

	relativeTime: (pastTime) =>
		origStamp = Date.parse(pastTime)
		curDate = new Date()
		currentStamp = curDate.getTime()
		difference = parseInt((currentStamp - origStamp) / 1000)
		return "Just now"	if difference <= 5
		return parseInt(difference) + " seconds ago"	if difference <= 60
		return parseInt(difference / 60) + " minutes ago"	if difference < 3600
		return "One hour ago"	if difference <= 1.5 * 3600
		return Math.round(difference / 3600) + " hours ago"	if difference < 23.5 * 3600
		return "One day ago"	if difference < 1.5 * 24 * 3600
		dateArr = pastTime.split(" ")
		dateArr[4].replace(/\:\d+$/, "") + " " + dateArr[2] + " " + dateArr[1] + (if dateArr[3] isnt curDate.getFullYear() then " " + dateArr[3] else "")

window.TRSW = TRSW

getUrlVars = ->
	vars = []
	hash = undefined
	hashes = window.location.href.slice(window.location.href.indexOf("?") + 1).split("&")
#	console.log "::getUrlVars hashes #{hashes}"
	i = 0
	while i < hashes.length
		hash = hashes[i].split("=")
#		console.log "::getUrlVars hash after splitting #{hash} hash0 #{hash[0]} and hash1 #{hash[1]}"
		vars.push hash[0]
		vars[hash[0]] = hash[1]
		i++
#	console.log "::getUrlVars vars #{vars['q']}"		
	vars
window.getUrlVars = getUrlVars

love_and_hate = (user,skey,love,neutral,hate) ->
	console.log "::love_and_hate call user (#{user}), skey (#{skey})"
	[love.first_time,neutral.first_time,hate.first_time] = [true,true,true]
	love.one user,"loves "+skey
	neutral.one user,skey
	hate.one user,"hates "+skey
	$("#ltitle").html ""
	$("#ntitle").html ""
	$("#htitle").html ""
	$("#ltitle").prepend "<h2 style=\"text-align:center;\">Loves #{skey}</h2>"
	$("#ntitle").prepend "<h2 style=\"text-align:center;\">#{skey}</h2>"
	$("#htitle").prepend "<h2 style=\"text-align:center;\">Hates #{skey}</h2>"
#	console.log "::love_and_hate finished"
	false
window.love_and_hate = love_and_hate



var tweetUsers = [];
var buildString = "";
var lastID = 0;
var tweetlist = [];
var last_key;
var time_out_id = 0;
var delta = 5000;


function one(user,key) {
	last_key = key;
	lastID = 0;
	clearTimeout(time_out_id);
	$('#tweet-container').html('');
    show('in one, user ' + user + ' key '+ key, 'info-console');
    tweetUsers[0] = user;
    if (user == '') tweetUsers.length = 0;
    buildString = encodeURI(key);
    if (tweetUsers.length) {
	    buildString += "+from";
        for (var i = 0; i < tweetUsers.length; i++) {
            if (i != 0) buildString += '+AND+';
            buildString += '%3A' + encodeURI(tweetUsers[i]);
        }
    }
    GetMatchingStatuses(buildString);
    TweetTick();
}

function show(text, target) {
    var out = $('#' + target);
    out.hide();
    out.html(text);
    out.fadeIn();
}



function GetMatchingStatuses(buildString) {
    var twitterapiurl = "http://search.twitter.com/search.json?since_id=" + lastID + "&q=" + buildString + "&rpp=100&callback=?";
    show("GetMatchingStatuses apiurl " + twitterapiurl, 'info-console');
    $.getJSON(twitterapiurl, function(ob) {
        FormatTweets(ob);
    });
}

function FormatTweets(data) {
    var newlist = [];
    var container = $('#tweet-container');
    $(data.results).sort(function(a, b) {
        return (a.id - b.id);
    }).each(function(el) {
        if (!lastID || this.id > lastID) {
            lastID = this.id;
            var TimeForThisCall = this.created_at;

            var str = '<div class="tweet">\
                <div class="avatar"><a href="http://twitter.com/' + this.from_user + '" target="_blank"><img src="' + this.profile_image_url + '" alt="' + this.from_user + '" /></a></div>\
                <div class="user"><a href="http://twitter.com/' + this.from_user + '" target="_blank">' + this.from_user + '</a></div>\
                <div class="time" rel="' + TimeForThisCall + '">' + relativeTime(TimeForThisCall) + '</div>\
                <div class="txt">' + formatTwitString(this.text) + '</div>\
                </div>';
            container.prepend(str);
        }
    });
    // Update tweet times...
    $(".tweet>.time").each(function(el) {
        var $this = $(this);
        var TimeForThisCall = $this.attr("rel");
        var newTime = relativeTime(TimeForThisCall);
        $this.text(newTime);
    });
    //  container.jScrollPane();
};

function TweetTick() {
    //            alert("TweetTick lastID"+lastID);
    GetMatchingStatuses(buildString);
    time_out_id = setTimeout(TweetTick, delta);
}

function formatTwitString(str) {
    str = ' ' + str;
    str = str.replace(/((ftp|https?):\/\/([-\w\.]+)+(:\d+)?(\/([\w/_\.]*(\?\S+)?)?)?)/gm, '<a href="$1" target="_blank">$1</a>');
    str = str.replace(/([^\w])\@([\w\-]+)/gm, '$1@<a href="http://twitter.com/$2" target="_blank">$2</a>');
    str = str.replace(/([^\w])\#([\w\-]+)/gm, '$1<a href="http://twitter.com/search?q=%23$2" target="_blank">#$2</a>');
    var match = new RegExp(last_key, "ig");     
    str = str.replace(match,'<span class="highlight">'+last_key+'</span>');
//    show("formatTwitString lastkey " + last_key + ' final str '+str, 'info-console');
    return str;
}

function relativeTime(pastTime) {
    var origStamp = Date.parse(pastTime);
    var curDate = new Date();
    var currentStamp = curDate.getTime();

    var difference = parseInt((currentStamp - origStamp) / 1000);

    //if(difference < 0) return false;
    if (difference <= 5) return "Just now";
    //    if(difference <= 20)            return "Seconds ago";
    if (difference <= 60) return parseInt(difference) + " seconds ago";
    if (difference < 3600) return parseInt(difference / 60) + " minutes ago";
    if (difference <= 1.5 * 3600) return "One hour ago";
    if (difference < 23.5 * 3600) return Math.round(difference / 3600) + " hours ago";
    if (difference < 1.5 * 24 * 3600) return "One day ago";

    var dateArr = pastTime.split(' ');
    return dateArr[4].replace(/\:\d+$/, '') + ' ' + dateArr[2] + ' ' + dateArr[1] + (dateArr[3] != curDate.getFullYear() ? ' ' + dateArr[3] : '');
}
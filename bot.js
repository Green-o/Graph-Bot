var Twit = require('twit');
var config = require('./config');
var fs = require('fs');
var exec = require('child_process').exec;

var T = new Twit(config);
console.log("Bot booted");

// Grab USA's trending data from Twitter
// Cache said data in a .json file
function fetchTrends() {
  var fetched = false;
  var requests = 0;
  var WOEIDs = [1,23424977]; // Earth and USA WOEIDs
  while(!fetched && requests < 15) {
    T.get('trends/place', {id:WOEIDs[1]}, function(err, data, response) {
      var d = JSON.stringify(data, null, 2); // Object -> JSON String
      if(err) {
        console.log("GET error: "+err);
      }else {
        fetched = true;
        fs.writeFileSync('./trend-data/raw-data.json', d);
      }
    });
    requests++;
  }
  console.log("Trends fetched");
  compileTrends();
}

// Sort out trends with less than 10,000 cumulative tweets
// Sort trends in descending order by tweet volume
function compileTrends() {
  var raw = fs.readFileSync('./trend-data/raw-data.json', 'utf-8');
  var data = JSON.parse(raw); // JSON String -> Object
  var allTrends = data[0].trends.filter(function(trend) {return trend.tweet_volume !== null;});
  var topTrends = allTrends.sort(function(a,b) {return b.tweet_volume-a.tweet_volume;});
  var formattedTopTrends = "";
  for(var i = 0; i < topTrends.length; i++) { // Object data -> .txt file
    var trendName = topTrends[i].name;
    var trendTotal = topTrends[i].tweet_volume;
    formattedTopTrends += trendName+":"+trendTotal+"\n"; // trend:tweets
  }
  fs.writeFileSync('./trend-data/processing-data.txt', formattedTopTrends);
  console.log("Trends compiled");
  generateImage();
}

// Execute a processing sketch through the Command Line Interface
function generateImage() {
  var cmd = './Graph_Generator/Graph_Generator';
  exec(cmd);
  console.log("Image generated");
  setTimeout(postTrends,30000); // Allow the image to generate
}

// Post the generated graph to Twitter under the handle @6thHourTrends
function postTrends() {
  var b64 = fs.readFileSync('./Graph_Generator/output.png', {encoding: 'base64'});
  T.post('media/upload', {media_data: b64}, function(err, data, response) {
    var id = data.media_id_string;
    var tweet = { // Status and attached image
      status: "",
      media_ids: [id]
    }
    T.post('statuses/update', tweet, function(err, data, response) {
      if(err) {console.log("POST error: "+err);}
      else {console.log("POST successful.");}
    });
  });
  console.log("Trends Posted");
}

fetchTrends();
setInterval(fetchTrends,21600000); // Execute bot function every 6 hours

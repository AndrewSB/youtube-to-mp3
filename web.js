var app, convert_and_send, express, ffmpeg, fs, http, mkdirp, path, qs, server, ytdl;

express = require('express');

ffmpeg = require('fluent-ffmpeg');

http = require('http');

ytdl = require('ytdl');

path = require('path');

fs = require('fs');

qs = require('querystring');

mkdirp = require('mkdirp');

app = express();

server = http.createServer(app);

app.set('port', process.env.PORT || 3000);

app.set('views', "" + __dirname + "/views");

app.set('view engine', 'jade');

app.use(express["static"](__dirname + "/public"));

server.listen(app.get('port'), function() {
  return console.log("Express server listening on port " + (app.get('port')));
});

app.get('/', function(req, res) {
  console.log("rendering");
  return res.render('index');
});

app.get('/convert', function(req, res) {
  var url;
  res.contentType('mp3');
  url = req.query.url;
  console.log(url);
  return ytdl.getInfo(url, function(err, info) {
    var pathToMovie, size;
    if (err != null) {
      console.log(err.message);
      return;
    }
    pathToMovie = path.join(__dirname, 'public', 'tmp', info.video_id);
    console.log(pathToMovie);
    console.log("downloading and converting");
    size = 0;
    return mkdirp(pathToMovie, function(err) {
      var download, file;
      file = fs.createWriteStream(pathToMovie + "/video.mp4");
      download = ytdl(url);
      download.pipe(file, {
        end: false
      });
      download.on('data', function(chunk) {
        size += chunk.length;
        return console.log(size);
      });
      return download.on('end', function() {
        console.log("Download done");
        return convert_and_send(pathToMovie, res, info.video_id);
      });
    });
  });
});

convert_and_send = function(pathToMovie, res, videoId) {
  console.log("converting");
  return new ffmpeg(pathToMovie + "/video.mp4").audioCodec('libmp3lame').format('mp3').on('end', function() {
    console.log("end");
    return res.send(200, "/tmp/" + videoId + "/music.mp3");
  }).saveToFile(pathToMovie + "/music.mp3", {
    end: true
  });
};

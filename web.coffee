express = require 'express'
ffmpeg  = require 'fluent-ffmpeg'
http    = require 'http'
ytdl    = require 'ytdl'
path    = require 'path'
fs      = require 'fs'
qs      = require 'querystring'
mkdirp  = require 'mkdirp'

app = express()
server = http.createServer(app)

app.set 'port', process.env.PORT || 3000
app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use express.static(__dirname + "/public")

server.listen app.get('port'), ->
  console.log "Express server listening on port #{app.get 'port'}"

app.get '/', (req, res)     ->
  console.log "rendering"
  res.render 'index'

# app.post '/play', (req, res) ->
#   ytdl.getInfo url, (err, info) ->
#     if err?
#       success = false
#     else
#       success = true
#       title = info.title
#       thumb = info.thumbnail_url
#
#     res.render 'play', yt_url: url, title: title, thumb: thumb, success: success

app.get '/convert', (req, res) ->
  res.contentType('mp3')
  url = req.query.url
  console.log url
  ytdl.getInfo url, (err, info) ->
    if err?
      console.log err.message
      return

    pathToMovie = path.join( __dirname, 'public', 'tmp', info.video_id )
    console.log pathToMovie
    # if fs.existsSync("#{pathToMovie}/music.mp3")
    #   console.log "already downloaded"
    #   res.sendfile("#{pathToMovie}/music.mp3")
    # else if fs.existsSync("#{pathToMovie}/video.mp4")
    #   convert_and_send(pathToMovie, res)
    # else
    console.log "downloading and converting"
    size = 0
    mkdirp pathToMovie, (err) ->
      file = fs.createWriteStream(pathToMovie + "/video.mp4")
      download = ytdl(url)
      download.pipe file, {end: false}
      download.on 'data', (chunk) ->
        size += chunk.length
        console.log size
      download.on 'end', () ->
        console.log "Download done"
        convert_and_send pathToMovie, res, info.video_id

convert_and_send = (pathToMovie, res, videoId) ->
  console.log "converting"
  new ffmpeg(pathToMovie + "/video.mp4")
    #.setFfmpegPath(__dirname + "/ffmpeg")
    .audioCodec('libmp3lame')
    .format('mp3')
    .on 'end', () ->
      console.log "end"
      res.send 200, "/tmp/#{videoId}/music.mp3"
    .saveToFile pathToMovie + "/music.mp3", {end: true}

writeToFile = (name) ->
  fs.appendFile('log.txt', name)

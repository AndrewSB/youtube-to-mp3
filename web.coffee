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

server.listen app.get('port'), ->
  console.log "Express server listening on port #{app.get 'port'}"

app.get '/', (req, res)     -> res.render 'index'
app.get '/play', (req, res) ->
  ytdl.getInfo req.query.url, (err, info) ->
    if err?
      success = false
    else
      success = true
      title = info.title
      thumb = info.thumbnail_url

    res.render 'play', yt_url: req.query.url, title: title, thumb: thumb, success: success

app.get '/convert', (req, res) ->
  console.log "processing #{req.query.url}"

  res.contentType('mp3')
  dest = path.join( __dirname, 'tmp', req.query.url )

  ytdl.getInfo req.query.url, (err, info) ->
    if err?
      console.log err.message
      return

    pathToMovie = path.join( __dirname, 'tmp', info.video_id )
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
      download = ytdl(req.query.url)
      download.pipe file, {end: false}
      download.on 'data', (chunk) ->
        size += chunk.length
      download.on 'end', () ->
        console.log "Download done"
        convert_and_send pathToMovie, res

convert_and_send = (pathToMovie, res) ->
  console.log "converting"
  file = fs.createWriteStream(pathToMovie + "/music.mp3")
  ffmpeg("#{pathToMovie}/video.mp4")
    .audioCodec('libmp3lame')
    .format('mp3')
    .on 'end', () ->
      console.log "All Done"
    .saveToFile "#{pathToMovie}/music.mp3"

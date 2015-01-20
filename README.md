 youtube-to-mp3
==============

Simple (but much needed) roll your own youtube video to mp3 downloader. You'll have to either run this locally or an a server of your own.

Currently the API is set to just return a link to the mp3 downloaded, but if you look at the tmp directory you'll see that a video is also available

`ffmpeg` is a dependency, so you will need it installed on the machine

## Installation
1. `git clone` or download this repository to your machine
2. run `npm install` to get all of the dependencies (except ffmpeg, you'll need to install ffmpeg on your machine using some other installer)
3. run `node web.js` to start the server. You can now go to `http://localhost:3000` to see a demo or use an http request to the `/covert` endpoint for programmatic access

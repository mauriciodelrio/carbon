{ google } = require 'googleapis'
fs = require 'fs'
key = require './carbon-7615cf89f04e.json'
drive = google.drive 'v3'
jwtClient = new google.auth.JWT(
  key.client_email,
  key.client_id,
  key.private_key,
  ['https://www.googleapis.com/auth/drive'],
  null
)

module.exports = () ->
  authorize: (req, res, cb) ->
    jwtClient.authorize (authErr) => 
      if authErr
        console.log authErr
        return
      drive.files.list { auth: jwtClient }, (listErr, resp) => 
        if listErr 
          console.log listErr
          return
        resp.data.files.forEach (file) =>
          console.log "#{file.name} (#{file.mimeType})", file

  uploadFile: (req, res, cb) ->
    jwtClient.authorize (authErr) => 
      if authErr
        console.log authErr
        return
      console.log "req bodyyyyyyyyyyyyyyyy", req.body
      fileMetadata = {
        name: req.body.file.name
        parents:['1FmETv_GE8ZFregCQvLnu-89221hVBn9n']
      }
      media = {
        mimeType: req.body.file.type,
        body: fs.createReadStream req.body.file
      }
      drive.files.create {
        auth: jwtClient,
        resource: fileMetadata,
        media,
        fields: 'id'
      }, (err, file) =>
        if err 
          cb? status: 'ERROR', data: 'ERROR al cargar el archivo'
        else
          cb? status: 'OK', data: "#{file.data.id}"


  downloadFile: (req, res, cb) ->
    fileId = '1DzQi__6if6Kak7W42jXTlsCc8UgRUWZA'
    drive.files.get {
      fileId: fileId
      auth: jwtClient
    }, (err, resp) ->
      if not err
        console.log "aaaaaaaaaaaaaa", resp.config, resp.data
        res.send status: 'OK', data: {headers: resp.config.headers, url: "#{resp.config.url}?alt=media", name: resp.data.name, mimeType: resp.data.mimeType}
      else
        res.send status: 'ERROR', data: 'ERROR al descargar el archivo'
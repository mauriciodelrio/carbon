Mimetype = new (require('../../lib/pgconn').Mimetype)()
_ = require 'lodash'
moment = require 'moment'

module.exports = () ->

  all_mimetypes: (req, res) ->
    Mimetype.connect (client) ->
      Mimetype.get_mimetypes client, (mimetypes) ->
        res.send status: 'OK', data: mimetypes

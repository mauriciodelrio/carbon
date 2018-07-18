Keyword = new (require('../../lib/pgconn').Keyword)()
_ = require 'lodash'
moment = require 'moment'

module.exports = () ->

  all_keywords: (req, res) ->
    Keyword.connect (client) ->
      Keyword.get_keywords client, (keywords) ->
        res.send status: 'OK', data: keywords

  new_keyword: (req, res) ->
    Keyword.connect (client) ->
      Keyword.new_keyword client, req.body?.name, (keyword) ->
        res.send status: 'OK', data: keyword
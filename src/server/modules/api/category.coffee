Category = new (require('../../lib/pgconn').Category)()
_ = require 'lodash'
moment = require 'moment'

module.exports = () ->

  all_categories: (req, res) ->
    Category.connect (client) ->
      Category.get_categories client, (categories) ->
        client.end()
        res.send status: 'OK', data: categories

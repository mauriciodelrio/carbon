_ = require 'lodash'
module.exports = () ->
  index: (req, res) ->
    res.status(200).send {status: 200, data: "hola mundo!"}
###
    Cache.get 'opta-teams:', (cache_data) ->
      if cache_data
        res.status(200).send { status: 200, data: cache_data }
      else
        res.status(400).send { status: 404, data: 'No hay data en cache' }
###
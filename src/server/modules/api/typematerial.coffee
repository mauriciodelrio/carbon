Typematerial = new (require('../../lib/pgconn').Typematerial)()
_ = require 'lodash'
moment = require 'moment'

module.exports = () ->

  all_typematerials: (req, res) ->
    Typematerial.connect (client) ->
      Typematerial.get_typematerials client, (typematerials) ->
        client.end()
        res.send status: 'OK', data: typematerials
  
  new_typematerial: (req, res) ->
    Typematerial.connect (client) ->
      Typematerial.new_typematerial client, req.body?.name, (typematerial) ->
        client.end()
        res.send status: 'OK', data: typematerial

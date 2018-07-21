Career = new (require('../../lib/pgconn').Career)()
_ = require 'lodash'
moment = require 'moment'

module.exports = () ->

  all_careers: (req, res) ->
    Career.connect (client) ->
      Career.get_careers client, (careers) ->
        res.send status: 'OK', data: careers

  get_careers_by_departament: (req, res) ->
    Career.connect (client) ->
      Career.get_careers_by_departament client, req.params.departament_id, (careers) ->
        res.send status: 'OK', data: careers
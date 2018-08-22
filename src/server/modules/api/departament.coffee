Departament = new (require('../../lib/pgconn').Departament)()
_ = require 'lodash'
moment = require 'moment'

module.exports = () ->

  all_departaments: (req, res) ->
    Departament.connect (client) ->
      Departament.get_departaments client, (departaments) ->
        client.end()
        res.send status: 'OK', data: departaments

  get_departaments_by_institution: (req, res) ->
    Departament.connect (client) ->
      Departament.get_departaments_by_institution client, req.params.ins_id, (departaments) ->
        client.end()
        res.send status: 'OK', data: departaments

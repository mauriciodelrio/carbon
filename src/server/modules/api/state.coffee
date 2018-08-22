State = new (require('../../lib/pgconn').State)()
_ = require 'lodash'
moment = require 'moment'

module.exports = () ->

  all_states: (req, res) ->
    State.connect (client) ->
      State.get_states client, (states) ->
        client.end()
        res.send status: 'OK', data: states

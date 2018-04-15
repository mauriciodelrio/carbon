_ = require 'lodash'
module.exports = () ->
  index: (req, res) ->
    if req
      res.status(200).send {status: 200, data: {
        user_id: "1245435413",
        user_name: "usach",
        description: {title: "hay toma", description: "mañana paro"}
      }}
    else
      res.status(400).send {status: 400, data: "404 not found"}
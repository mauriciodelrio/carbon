_ = require 'lodash'
module.exports = () ->
  index: (req, res) ->
    if req.query.id?
      res.status(200).send {status: 200, data: {
        user_id: "2124321",
        user_name: "jon",
        user_lastname: "snow",
        bday: "380",
        description: {title: "winter is here", description: "hola"}
      }}
    else
      res.status(400).send {status: 400, data: "404 not found"}
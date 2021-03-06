require('./_env') if require('fs').existsSync './_env.coffee'
CONFIG =
  NAME: 'Carbon'
  URL: process.env.URL or ''
  STATIC_URL: process.env.STATIC_URL or '' # do not include ending slash
  ROOT: __dirname
  DB:
    REDIS:
      HOST: process.env.DB_REDIS_HOST or '127.0.0.1'
      PORT: process.env.DB_REDIS_PORT or 6379
      USER: process.env.DB_REDIS_USER or ''
      PASSWORD: process.env.DB_REDIS_PASSWORD or ''
      URL: process.env.REDIS_URL or ''
      PREFIX: 'carbon:'
  EXPRESS:
    SESSION:
      KEY: 'carbon.s'
      SECRET: '7s0ARiQ0kh7U8kYlwTcOBLyNtQHoUVkO740yrjB5I1gHxarMHqWD2dPesMaJ'
  MAIL:
    SENDER_ADDRESS: 'Carbon <noreply@carbon.cl>'
    TEMPLATES:
      'bienvenida':
        subject: 'Bienvenid@ a Carbon!'
        text: "Hola {{name}},\n\nEsta es tu primera vez en Carbon, gracias por ser parte de nuestro servicio"
      SIGNATURE: "\n\n--\nSaludos\nEl Equipo de Carbon\nhttps://carbon.cl/\n"

exports.CONFIG = CONFIG
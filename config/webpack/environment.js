const { environment } = require('@rails/webpacker')
const sass =  require('./loaders/sass')

environment.loaders.prepend('sass', sass)
module.exports = environment

const { environment } = require('@rails/webpacker')
const sass =  require('./loaders/sass')
const less =  require('./loaders/less')

environment.loaders.prepend('sass', sass)
environment.loaders.prepend('less', less)
module.exports = environment

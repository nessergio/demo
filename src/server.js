const express = require('express')
const routes = require('./routes')

function createServer() {
    const app = express()
    app.use("/", routes.helloRoute)
    return app
}

module.exports = createServer
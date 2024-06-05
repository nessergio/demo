const createServer = require('./server')

const port = 3000
const app = createServer() 

app.listen(port, () => {
    console.log("Server has started on port " + port)
})
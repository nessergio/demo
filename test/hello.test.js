const request = require('supertest');
const createServer = require('../src/server');

const app = createServer();

describe('API Endpoints', () => {
  it('should output "Hello World!"', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.text).toEqual('Hello World!');
  });
});
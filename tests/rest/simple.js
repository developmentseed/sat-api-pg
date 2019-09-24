import { restService } from './common';

describe('root endpoint', function () {
  it('returns json', function (done) {
    restService()
      .get('/')
      .expect('Content-Type', /json/)
      .expect(200, done);
  });
});

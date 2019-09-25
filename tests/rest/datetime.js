import { restService, resetdb } from './common';
import should from 'should'; // eslint-disable-line no-unused-vars

describe('datetime filter', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('Handles date range queries', function (done) {
    restService()
      .post('search')
      .send({
        datetime: '2019-04-01T12:00/2019-08-21T14:02'
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(1);
      });
  });

  it('wat', function (done) {
    restService()
      .get('items')
      .query({
        datetime: '2019-04-01T12:00/2019-08-21T14:02'
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(1);
      });
  });
});

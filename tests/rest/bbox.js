import { restService, resetdb } from './common';
import should from 'should'; // eslint-disable-line no-unused-vars

describe('bbox filter', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('Handles bbox filter for search endpoint with POST', function (done) {
    restService()
      .post('search')
      .send({
        bbox: [-114.18578, 30.64594, -111.68488, 32.81955]
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(1);
      });
  });

  it('Global bbox selects all the items', function (done) {
    restService()
      .post('search')
      .send({
        bbox: [-180, -90, 180, 90]
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.be.above(1);
      });
  });

  it('Handles bbox filter for items endpoint with GET and query parameter',
    function (done) {
      restService()
        .get('items')
        .query({
          bbox: '[-180, -90, 180, 90]'
        })
        .expect('Content-Type', /json/)
        .expect(200, done)
        .expect(r => {
          r.body.features.length.should.be.above(1);
        });
    });
});

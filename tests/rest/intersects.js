import { restService, resetdb } from './common';
import should from 'should'; // eslint-disable-line no-unused-vars
import { searchPath, itemsPath } from './constants';
import intersectPolygon from './intersects.json';

describe('intersects filter', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('Handles intersects filter for search endpoint with POST', function (done) {
    restService()
      .post(searchPath)
      .send({
        intersects: intersectPolygon
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(1);
      });
  });

  it('Handles intersects filter for items endpoint with GET and query parameter',
    function (done) {
      restService()
        .get(itemsPath)
        .query({
          intersects: JSON.stringify(intersectPolygon)
        })
        .expect('Content-Type', /json/)
        .expect(200, done)
        .expect(r => {
          r.body.features.length.should.equal(1);
        });
    });
});

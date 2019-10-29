import { restService, resetdb } from './common';
import should from 'should'; // eslint-disable-line no-unused-vars
import { searchPath, itemsPath, wfsItemsPath } from './constants';

describe('collections filter', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('Collections filter for search endpoint', function (done) {
    restService()
      .post(searchPath)
      .send({
        collections: ['landsat-8-l1']
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.be.above(1);
      });
  });

  it('Collections filter as query parameter for items GET', function (done) {
    restService()
      .get(itemsPath)
      .query({
        collections: 'landsat-8-l1'
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.be.above(1);
      });
  });

  it('Collections can be passed as query parameter in GET for wfs items', function (done) {
    restService()
      .get(wfsItemsPath)
      .query({
        collections: 'landsat-8-l1'
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.be.above(1);
      });
  });
});

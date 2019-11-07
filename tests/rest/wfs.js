import { restService, resetdb } from './common';
import should from 'should'; // eslint-disable-line no-unused-vars
import { collectionsPath } from './constants';

describe('wfs endpoints', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('Returns specific collection as object', function (done) {
    restService()
      .get(`${collectionsPath}/landsat-8-l1`)
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.id.should.equal('landsat-8-l1');
      });
  });

  it('Returns items form a collection as a feature collection', function (done) {
    restService()
      .get(`${collectionsPath}/landsat-8-l1/items`)
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.forEach((feature) => {
          feature.collection.should.equal('landsat-8-l1');
        });
      });
  });

  it('Returns the specified item id', function (done) {
    restService()
      .get(`${collectionsPath}/landsat-8-l1/items/LC80320392019263`)
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.id.should.equal('LC80320392019263');
      });
  });
});

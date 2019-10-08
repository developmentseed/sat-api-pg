import { restService, resetdb } from './common';
import should from 'should'; // eslint-disable-line no-unused-vars
import { searchPath } from './constants';

describe('query extension', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('Uses collection properties and item properties for query', function (done) {
    restService()
      .post(searchPath)
      .send({
        query: {
          'eo:gsd': {
            eq: 15
          }
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.be.above(1);
        r.body.features[0].properties.should.not.have.property('eo:gsd');
      });
  });

  it('Handles queries with no bbox or intersects', function (done) {
    restService()
      .post(searchPath)
      .send({
        query: {
          'eo:cloud_cover': {
            eq: 26
          }
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(1);
      });
  });

  it('gte lte operators', function (done) {
    restService()
      .post(searchPath)
      .send({
        query: {
          'eo:cloud_cover': {
            gte: 26,
            lte: 40
          }
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(1);
      });
  });

  it('in operator', function (done) {
    restService()
      .post(searchPath)
      .send({
        query: {
          'eo:column': {
            in: ['032', '037']
          }
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(2);
      });
  });
});

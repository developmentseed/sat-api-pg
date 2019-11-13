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

  it('in operator with strings', function (done) {
    restService()
      .post(searchPath)
      .send({
        query: {
          'landsat:column': {
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

  it('in operator with numbers', function (done) {
    restService()
      .post(searchPath)
      .send({
        query: {
          'eo:cloud_cover': {
            in: [0]
          }
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(1);
      });
  });

  it('in operator with numbers', function (done) {
    restService()
      .post(searchPath)
      .send({
        query: {
          'eo:epsg': {
            in: [32610, 32613]
          }
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(2);
      });
  });

  it('Json field queries with numbers', function (done) {
    restService()
      .post(searchPath)
      .send({
        query: {
          'eo:cloud_cover': {
            lt: 100
          }
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(3);
      });
  });

  it('Json field queries with strings', function (done) {
    restService()
      .post(searchPath)
      .send({
        query: {
          'landsat:row': {
            eq: '039'
          }
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(1);
      });
  });

  it('Handles multiple query properties', function (done) {
    restService()
      .post(searchPath)
      .send({
        query: {
          'eo:cloud_cover': {
            lt: 6
          },
          'eo:sun_azimuth': {
            lt: 50
          }
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(1);
      });
  });
});

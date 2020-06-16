import { restService, resetdb } from './common';
import should from 'should'; // eslint-disable-line no-unused-vars
import { searchPath, itemsPath, wfsItemsPath } from './constants';

describe('ids filter', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('Ids filter for search endpoint', function (done) {
    restService()
      .post(searchPath)
      .send({
        ids: ['LC80370382019170', 'LC81392162019261']
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(2);
      });
  });

  it('Ids filter as query parameter for items GET', function (done) {
    restService()
      .get(itemsPath)
      .query({
        ids: 'LC80370382019170,LC81392162019261'
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(2);
      });
  });

  it('Ids can be passed as query parameter in GET for wfs items', function (done) {
    restService()
      .get(wfsItemsPath)
      .query({
        ids: 'LC80370382019170,LC81392162019261'
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(2);
      });
  });

  it('Ids filter works with the fields filter', function (done) {
    restService()
      .post(searchPath)
      .send({
        ids: ['LC80370382019170', 'LC81392162019261'],
        fields: {
          exclude: ['assets']
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(2);
        should.not.exist(r.body.features[0].assets);
      });
  });

  it('Ids filter ignores further query parameter', function (done) {
    restService()
      .post(searchPath)
      .send({
        ids: ['LC80370382019170', 'LC81392162019261'],
        fields: {
          exclude: ['assets']
        },
        query: {
          'eo:cloud_cover': {
            gt: 10
          }
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(2);
        should.not.exist(r.body.features[0].assets);
      });
  });
});

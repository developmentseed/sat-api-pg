import { restService, resetdb } from './common';
import should from 'should'; // eslint-disable-line no-unused-vars
import { searchPath, itemsPath } from './constants';

describe('sort extension', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('Default sort by datetime for search POST', function (done) {
    restService()
      .post(searchPath)
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        const firstDate = Date.parse(r.body.features[0].properties.datetime);
        const secondDate = Date.parse(r.body.features[1].properties.datetime);
        const thirdDate = Date.parse(r.body.features[2].properties.datetime);
        firstDate.should.be.above(secondDate);
        secondDate.should.be.above(thirdDate);
      });
  });

  it('Default sort by datetime for items GET', function (done) {
    restService()
      .get(itemsPath)
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        const firstDate = Date.parse(r.body.features[0].properties.datetime);
        const secondDate = Date.parse(r.body.features[1].properties.datetime);
        const thirdDate = Date.parse(r.body.features[2].properties.datetime);
        firstDate.should.be.above(secondDate);
        secondDate.should.be.above(thirdDate);
      });
  });

  it('Search sorts desc by nested property', function (done) {
    restService()
      .post(searchPath)
      .send({
        sort: [{
          field: 'properties.eo:cloud_cover',
          direction: 'desc'
        }]
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        const firstcc = r.body.features[0].properties['eo:cloud_cover'];
        const secondcc = r.body.features[1].properties['eo:cloud_cover'];
        const thirdcc = r.body.features[2].properties['eo:cloud_cover'];
        firstcc.should.be.above(secondcc);
        secondcc.should.be.above(thirdcc);
      });
  });

  it('Search sorts asc by nested property', function (done) {
    restService()
      .post(searchPath)
      .send({
        sort: [{
          field: 'properties.eo:cloud_cover',
          direction: 'asc'
        }]
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        const firstcc = r.body.features[0].properties['eo:cloud_cover'];
        const secondcc = r.body.features[1].properties['eo:cloud_cover'];
        const thirdcc = r.body.features[2].properties['eo:cloud_cover'];
        firstcc.should.be.below(secondcc);
        secondcc.should.be.below(thirdcc);
      });
  });
});

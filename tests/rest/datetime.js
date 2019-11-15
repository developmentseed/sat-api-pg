import { restService, resetdb } from './common';
import should from 'should'; // eslint-disable-line no-unused-vars
import { searchPath, itemsPath, wfsItemsPath } from './constants';

describe('datetime filter', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('Handles date range queries', function (done) {
    restService()
      .post(searchPath)
      .send({
        datetime: '2019-04-01T12:00/2019-08-21T14:02'
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(1);
      });
  });

  it('Handles dates not in range', function (done) {
    restService()
      .post(searchPath)
      .send({
        datetime: '2018-04-01T12:00/2018-08-21T14:02'
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(0);
      });
  });
  it('Datetime can be passed as query parameter in GET', function (done) {
    restService()
      .get(itemsPath)
      .query({
        datetime: '2019-04-01T12:00/2019-08-21T14:02'
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(1);
      });
  });

  it('Datetime can be passed as query parameter in GET for wfs items', function (done) {
    restService()
      .get(wfsItemsPath)
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

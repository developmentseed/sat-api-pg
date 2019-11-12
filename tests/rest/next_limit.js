import { restService, resetdb } from './common';
import should from 'should'; // eslint-disable-line no-unused-vars
import { searchPath, itemsPath } from './constants';

describe('next and limit filters', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('Limits response search POST', function (done) {
    restService()
      .post(searchPath)
      .send({
        next: 1,
        limit: 2
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(2);
      });
  });

  it('Limits response for items GET', function (done) {
    restService()
      .get(itemsPath)
      .query({
        next: 0,
        limit: 2
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features.length.should.equal(2);
      });
  });

  it('Prefer header returns current range and totals for item GET',
    function (done) {
      restService()
        .get(itemsPath)
        .query({
          next: 0,
          limit: 2
        })
        .set('Prefer', 'count=exact')
        .expect('Content-Type', /json/)
        // Should be a 206 Partial Content
        .expect(206, done)
        .expect(r => {
          const range = r.headers['content-range'].split('/')[0];
          range.should.equal('0-1');
        });
    });

  it('Prefer header returns current range and totals for search POST',
    function (done) {
      restService()
        .post(searchPath)
        .send({
          next: 0,
          limit: 2
        })
        .set('Prefer', 'count=exact')
        .expect('Content-Type', /json/)
        .expect(200, done)
        .expect(r => {
          const range = r.headers['content-range'].split('/')[0];
          range.should.equal('0-1');
        });
    });
});

/* eslint no-unused-expressions: 0 */
import { restService, resetdb } from './common';
import should from 'should'; // eslint-disable-line no-unused-vars
const proxy = process.env.SERVER_PROXY_URI;

describe('root endpoint', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('Returns the correct object structure', function (done) {
    restService()
      .get('')
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.id.should.exist;
        r.body.title.should.exist;
        r.body.description.should.exist;
        r.body.stac_version.should.exist;
        r.body.links.should.containDeep(
          [{
            href: `${proxy}collections`,
            rel: 'data',
            type: 'application/json',
            title: null
          },
          {
            href: `${proxy}conformance`,
            rel: 'conformance',
            type: 'application/json',
            title: null
          },
          {
            href: proxy.slice(0, -1),
            rel: 'self',
            type: 'application/json',
            title: null
          }]);
      });
  });
});

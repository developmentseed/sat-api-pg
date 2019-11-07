import should from 'should'; // eslint-disable-line no-unused-vars
import { restService, resetdb } from './common';
import { collectionsPath } from './constants';
import landsat8l2Collection from './landsat8l2Collection.json';
const proxy = process.env.SERVER_PROXY_URI;

describe('collections', function () {
  beforeEach(function (done) { resetdb(); done(); });
  afterEach(function (done) { resetdb(); done(); });

  it('Initial insert of a collection returns 201', function (done) {
    restService()
      .post(collectionsPath)
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .withRole('application')
      .send(landsat8l2Collection)
      .expect(201, done);
  });

  it('Insert a collection without a valid JWT or role returns 401', function (done) {
    restService()
      .post(collectionsPath)
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .send(landsat8l2Collection)
      .expect(401, done);
  });

  it('Inserting a collection with a duplicate id returns 409', function (done) {
    restService()
      .post(collectionsPath)
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .withRole('application')
      .send(landsat8l2Collection)
      .end(() => {
        restService()
          .post(collectionsPath)
          .set('Prefer', 'return=minimal')
          .set('Content-Type', 'application/json')
          .withRole('application')
          .send(landsat8l2Collection)
          .expect(409, done);
      });
  });

  it('Adds self and root links based on apiUrl value', function (done) {
    restService()
      .get(collectionsPath)
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.collections[0].links.length.should.equal(2);
        r.body.collections[0].links.should.containDeep([{
          href: `${proxy}collections/landsat-8-l1`,
          rel: 'self',
          type: 'application/json',
          title: null
        },
        {
          href: `${proxy}collections/landsat-8-l1`,
          rel: 'root',
          type: 'application/json',
          title: null
        }]);
      });
  });

  it('Merges derived_from link if included in inserted collection', function (done) {
    restService()
      .post(collectionsPath)
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .withRole('application')
      .send(landsat8l2Collection)
      .end(() => {
        restService()
          .get(collectionsPath)
          .expect('Content-Type', /json/)
          .expect(200, done)
          .expect(r => {
            r.body.collections[1].links.length.should.equal(3);
            r.body.collections[1].links.should.containDeep([{
              href: `${proxy}collections/landsat-8-l2`,
              rel: 'self',
              type: 'application/json',
              title: null
            },
            {
              href: `${proxy}collections/landsat-8-l2`,
              rel: 'root',
              type: 'application/json',
              title: null
            },
            {
              href: 'derived',
              rel: 'derived_from',
              type: null,
              title: null
            }]);
          });
      });
  });
});

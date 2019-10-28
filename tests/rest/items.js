import { restService, resetdb } from './common';
import landsatItem from './landsatItem.json';
import landsatItems from './landsatItems.json';
import { itemsPath } from './constants';

const proxy = process.env.SERVER_PROXY_URI;
describe('items', function () {
  beforeEach(function (done) { resetdb(); done(); });
  afterEach(function (done) { resetdb(); done(); });
  it('Initial insert of an item returns 201', function (done) {
    restService()
      .post(itemsPath)
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .withRole('application')
      .send(landsatItem)
      .expect(201, done);
  });

  it('Insert an item without a valid JWT or role returns 401', function (done) {
    restService()
      .post(itemsPath)
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .send(landsatItem)
      .expect(401, done);
  });

  it('Inserting an item with a duplicate id returns 409', function (done) {
    restService()
      .post(itemsPath)
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .withRole('application')
      .send(landsatItem)
      .end(() => {
        restService()
          .post(itemsPath)
          .set('Prefer', 'return=minimal')
          .set('Content-Type', 'application/json')
          .withRole('application')
          .send(landsatItem)
          .expect(409, done);
      });
  });

  it('Adds self and parent links based on apiUrl value', function (done) {
    restService()
      .get(itemsPath)
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features[0].links.length.should.equal(2);
        r.body.features[0].links.should.containDeep([{
          rel: 'self',
          href: `${proxy}collections/landsat-8-l1/LC80320392019263`,
          type: 'application/geo+json',
          title: null
        },
        {
          rel: 'parent',
          href: `${proxy}collections/landsat-8-l1`,
          type: 'application/json',
          title: null
        }]);
      });
  });

  it('Merges derived_from link if included in inserted item', function (done) {
    restService()
      .post(itemsPath)
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .withRole('application')
      .send(landsatItem)
      .end(() => {
        restService()
          .get(itemsPath)
          .expect('Content-Type', /json/)
          .expect(200, done)
          .expect(r => {
            r.body.features[2].links.length.should.equal(3);
            r.body.features[2].links.should.containDeep([
              {
                rel: 'self',
                href: `${proxy}collections/landsat-8-l1/LC81152062019205`,
                type: 'application/geo+json',
                title: null
              },
              {
                rel: 'parent',
                href: `${proxy}collections/landsat-8-l1`,
                type: 'application/json',
                title: null
              },
              {
                rel: 'derived_from',
                href: 'derived',
                type: null,
                title: null
              }]);
          });
      });
  });

  it('Insert an array of items', function (done) {
    restService()
      .post(itemsPath)
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .withRole('application')
      .send(landsatItems)
      .end(() => {
        restService()
          .get(itemsPath)
          .set('Content-Type', 'application/json')
          .expect(200, done)
          .expect(r => {
            r.body.features.length.should.equal(5);
          });
      });
  });

  it('Delete is restricted', function (done) {
    restService()
      .delete(itemsPath)
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .withRole('application')
      .expect(405, done);
  });
});

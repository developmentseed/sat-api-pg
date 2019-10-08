import { restService } from './common';
import { collectionsPath } from './constants';
import landsat8l2Collection from './landsat8l2Collection.json';

describe('collections', function () {
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
      .expect(409, done);
  });
});

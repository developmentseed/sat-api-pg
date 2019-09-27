import { restService } from './common';
import landsatItem from './landsatItem.json';
import { itemsPath } from './constants';

describe('items', function () {
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
      .expect(409, done);
  });
});

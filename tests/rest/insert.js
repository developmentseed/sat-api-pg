import { rest_service, resetdb } from './common';
import should from 'should';
import landsatItem from './landsatItem.json';

describe('items insert', function () {
  it('Initial insert of an item returns 201', function (done) {
    rest_service()
      .post('items')
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .withRole('application')
      .send(landsatItem)
      .expect(201, done)
  });

  it('Inserting an item with a duplicate id returns 409', function (done) {
    rest_service()
      .post('items')
      .set('Prefer', 'return=minimal')
      .set('Content-Type', 'application/json')
      .withRole('application')
      .send(landsatItem)
      .expect(409, done)
  });
});

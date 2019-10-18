import should from 'should'; // eslint-disable-line no-unused-vars
import { restService, resetdb } from './common';
import { searchPath } from './constants';

describe('fields extension', function () {
  before(function (done) { resetdb(); done(); });
  after(function (done) { resetdb(); done(); });

  it('includes default fields when include and exclude are null', function (done) {
    restService()
      .post(searchPath)
      .send({
        fields: {}
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features[0].should.have.property('id');
        r.body.features[0].should.have.property('type');
        r.body.features[0].should.have.property('geometry');
        r.body.features[0].should.have.property('properties');
        r.body.features[0].should.have.property('assets');
        r.body.features[0].properties.should.have.property('datetime');
      });
  });

  it('includes default fields when include and exclude are empty', function (done) {
    restService()
      .post(searchPath)
      .send({
        fields: {
          include: [],
          exclude: []
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features[0].should.have.property('id');
        r.body.features[0].should.have.property('type');
        r.body.features[0].should.have.property('geometry');
        r.body.features[0].should.have.property('properties');
        r.body.features[0].should.have.property('assets');
        r.body.features[0].properties.should.have.property('datetime');
      });
  });

  it('if only include is specified, properties are added to the defaults',
    function (done) {
      restService()
        .post(searchPath)
        .send({
          fields: {
            include: [
              'properties.landsat:row',
              'properties.eo:cloud_cover'
            ]
          }
        })
        .expect('Content-Type', /json/)
        .expect(200, done)
        .expect(r => {
          r.body.features[0].properties.should.have.property('datetime');
          r.body.features[0].properties.should.have.property('landsat:row');
          r.body.features[0].properties.should.have.property('eo:cloud_cover');
        });
    });

  it('if only exclude is specified excluded fields are subtracted from' +
      ' the defaults.  May result in an invalid item',
  function (done) {
    restService()
      .post(searchPath)
      .send({
        fields: {
          exclude: [
            'assets'
          ]
        }
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect(r => {
        r.body.features[0].should.not.have.property('assets');
        r.body.features[0].properties.should.have.property('datetime');
      });
  });

  it('if the same field is specified in include and exclude, the include wins',
    function (done) {
      restService()
        .post(searchPath)
        .send({
          fields: {
            include: [
              'properties.landsat:row'
            ],
            exclude: [
              'properties.landsat:row'
            ]
          }
        })
        .expect('Content-Type', /json/)
        .expect(200, done)
        .expect(r => {
          r.body.features[0].properties.should.have.property('landsat:row');
        });
    });
});

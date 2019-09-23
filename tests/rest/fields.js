import { rest_service, resetdb } from './common'
import should from 'should'

describe('fields extension', function () {
  before(function (done) { resetdb(); done() })
  after(function (done) { resetdb(); done() })

  it('includes default fields when include and exclude are null', function (done) {
    rest_service()
      .post('search')
      .send({
        "fields":{}
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
      })
  })

  it('includes default fields when include and exclude are empty', function (done) {
    rest_service()
      .post('search')
      .send({
        "fields":{
           "include": [],
           "exclude": []
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
      })
  })

  it('if only include is specified, properties are added to the defaults',
    function (done) {
      rest_service()
        .post('search')
        .send({
          "fields":{
            "include": [
              "properties.eo:row",
              "properties.eo:cloud_cover"
            ]
          }
        })
        .expect('Content-Type', /json/)
        .expect(200, done)
        .expect(r => {
          r.body.features[0].properties.should.have.property('datetime');
          r.body.features[0].properties.should.have.property('eo:row');
          r.body.features[0].properties.should.have.property('eo:cloud_cover');
        })
  })

  it('if only exclude is specified excluded fields are subtracted from' +
      ' the defaults.  May result in an invalid item',
    function (done) {
      rest_service()
        .post('search')
        .send({
          "fields":{
            "exclude": [
              "assets"
            ]
          }
        })
        .expect('Content-Type', /json/)
        .expect(200, done)
        .expect(r => {
          r.body.features[0].should.not.have.property('assets');
          r.body.features[0].properties.should.have.property('datetime');
        })
  })

  it('if the same field is specified in include and exclude, the include wins',
    function (done) {
      rest_service()
        .post('search')
        .send({
          "fields":{
            "include": [
              "properties.eo:row"
            ],
            "exclude": [
              "properties.eo:row"
            ]
          }
        })
        .expect('Content-Type', /json/)
        .expect(200, done)
        .expect(r => {
          r.body.features[0].properties.should.have.property('eo:row');
        })
  })

});
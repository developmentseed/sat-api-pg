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

  it('basic', function (done) {
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
        r.body.features.length.should.equal(1)
        Object.keys(r.body.features[0].properties).length.should.equal(2)
      })
  })
})

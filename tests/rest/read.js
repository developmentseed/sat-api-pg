import { rest_service, resetdb } from './common'
import should from 'should'

describe('read', function () {
  before(function (done) { resetdb(); done() })
  after(function (done) { resetdb(); done() })

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

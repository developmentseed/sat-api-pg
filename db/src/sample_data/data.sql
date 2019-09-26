INSERT INTO data.collections(id, description, properties)
VALUES(
  'landsat-8-l1',
  'Landat 8 imagery radiometrically calibrated and orthorectified using gound points and Digital Elevation Model (DEM) data to correct relief displacement.',
  '{
    "eo:gsd": 15,
    "eo:platform": "landsat-8",
    "eo:instrument": "OLI_TIRS",
    "eo:off_nadir": 0,
    "eo:bands": [
        {
            "name": "B1",
            "common_name": "coastal",
            "gsd": 30,
            "center_wavelength": 0.44,
            "full_width_half_max": 0.02
        },
        {
            "name": "B2",
            "common_name": "blue",
            "gsd": 30,
            "center_wavelength": 0.48,
            "full_width_half_max": 0.06
        },
        {
            "name": "B3",
            "common_name": "green",
            "gsd": 30,
            "center_wavelength": 0.56,
            "full_width_half_max": 0.06
        },
        {
            "name": "B4",
            "common_name": "red",
            "gsd": 30,
            "center_wavelength": 0.65,
            "full_width_half_max": 0.04
        },
        {
            "name": "B5",
            "common_name": "nir",
            "gsd": 30,
            "center_wavelength": 0.86,
            "full_width_half_max": 0.03
        },
        {
            "name": "B6",
            "common_name": "swir16",
            "gsd": 30,
            "center_wavelength": 1.6,
            "full_width_half_max": 0.08
        },
        {
            "name": "B7",
            "common_name": "swir22",
            "gsd": 30,
            "center_wavelength": 2.2,
            "full_width_half_max": 0.2
        },
        {
            "name": "B8",
            "common_name": "pan",
            "gsd": 15,
            "center_wavelength": 0.59,
            "full_width_half_max": 0.18
        },
        {
            "name": "B9",
            "common_name": "cirrus",
            "gsd": 30,
            "center_wavelength": 1.37,
            "full_width_half_max": 0.02
        },
        {
            "name": "B10",
            "common_name": "lwir11",
            "gsd": 100,
            "center_wavelength": 10.9,
            "full_width_half_max": 0.8
        },
        {
            "name": "B11",
            "common_name": "lwir12",
            "gsd": 100,
            "center_wavelength": 12,
            "full_width_half_max": 1
        }
    ]
  }');
INSERT INTO data.items_string_geometry(id, collection, type, properties, geometry, assets)
VALUES(
  'LC80370382019170',
  'landsat-8-l1',
  'Feature',
  '{
      "datetime": "2019-06-19T18:04:15.625209+00:00",
      "eo:platform": "landsat-8",
      "eo:instrument": "OLI_TIRS",
      "eo:off_nadir": 0,
      "eo:sun_azimuth": 107.44278551,
      "eo:sun_elevation": 68.69325853,
      "eo:cloud_cover": 0,
      "eo:row": "038",
      "eo:column": "037",
      "landsat:product_id": "LC08_L1TP_037038_20190619_20190619_01_RT",
      "landsat:scene_id": "LC80370382019170LGN00",
      "landsat:processing_level": "L1TP",
      "landsat:tier": "RT",
      "landsat:revision": "00",
      "eo:epsg": 32612
  }',
  '{
    "type": "Polygon",
    "coordinates": [
        [
            [
                -113.67504227390168,
                32.8173594322106
            ],
            [
                -111.68609681980705,
                32.39808677367999
            ],
            [
                -112.19525531923246,
                30.648409820140177
            ],
            [
                -114.1825942059299,
                31.07348632191278
            ],
            [
                -113.67504227390168,
                32.8173594322106
            ]
        ]
    ]
  }',
  '{
      "index": {
          "type": "text/html",
          "title": "HTML index page",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_MTL.txt"
      },
      "thumbnail": {
          "title": "Thumbnail image",
          "type": "image/jpeg",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_thumb_large.jpg"
      },
      "B1": {
          "type": "image/x.geotiff",
          "eo:bands": [
              0
          ],
          "title": "Band 1 (coastal)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_B1.TIF"
      },
      "B2": {
          "type": "image/x.geotiff",
          "eo:bands": [
              1
          ],
          "title": "Band 2 (blue)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_B2.TIF"
      },
      "B3": {
          "type": "image/x.geotiff",
          "eo:bands": [
              2
          ],
          "title": "Band 3 (green)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_B3.TIF"
      },
      "B4": {
          "type": "image/x.geotiff",
          "eo:bands": [
              3
          ],
          "title": "Band 4 (red)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_B4.TIF"
      },
      "B5": {
          "type": "image/x.geotiff",
          "eo:bands": [
              4
          ],
          "title": "Band 5 (nir)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_B5.TIF"
      },
      "B6": {
          "type": "image/x.geotiff",
          "eo:bands": [
              5
          ],
          "title": "Band 6 (swir16)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_B6.TIF"
      },
      "B7": {
          "type": "image/x.geotiff",
          "eo:bands": [
              6
          ],
          "title": "Band 7 (swir22)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_B7.TIF"
      },
      "B8": {
          "type": "image/x.geotiff",
          "eo:bands": [
              7
          ],
          "title": "Band 8 (pan)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_B8.TIF"
      },
      "B9": {
          "type": "image/x.geotiff",
          "eo:bands": [
              8
          ],
          "title": "Band 9 (cirrus)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_B9.TIF"
      },
      "B10": {
          "type": "image/x.geotiff",
          "eo:bands": [
              9
          ],
          "title": "Band 10 (lwir)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_B10.TIF"
      },
      "B11": {
          "type": "image/x.geotiff",
          "eo:bands": [
              10
          ],
          "title": "Band 11 (lwir)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_B11.TIF"
      },
      "ANG": {
          "title": "Angle coefficients file",
          "type": "text/plain",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_ANG.txt"
      },
      "MTL": {
          "title": "original metadata file",
          "type": "text/plain",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_MTL.txt"
      },
      "BQA": {
          "title": "Band quality data",
          "type": "image/x.geotiff",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/037/038/LC08_L1TP_037038_20190619_20190619_01_RT/LC08_L1TP_037038_20190619_20190619_01_RT_BQA.TIF"
      }
  }'
);
INSERT INTO data.items_string_geometry(id, collection, type, properties, geometry, assets)
VALUES(
  'LC81392162019261',
  'landsat-8-l1',
  'Feature',
  '{
      "eo:instrument": "OLI_TIRS",
      "eo:off_nadir": 0,
      "datetime": "2019-09-18T05:46:06.899022+00:00",
      "eo:sun_azimuth": -41.99592743,
      "eo:sun_elevation": -33.41081542,
      "eo:cloud_cover": 5,
      "eo:row": "216",
      "eo:column": "139",
      "landsat:product_id": "LC08_L1GT_139216_20190918_20190918_01_RT",
      "landsat:scene_id": "LC81392162019261LGN00",
      "landsat:processing_level": "L1GT",
      "landsat:tier": "RT",
      "landsat:revision": "00",
      "eo:epsg": 32610
  }',
  '{
    "type": "Polygon",
    "coordinates": [
      [
          [
              -120.35233737469743,
              45.39295372924591
          ],
          [
              -122.7820425809571,
              44.93025774783343
          ],
          [
              -123.46442213945537,
              46.65682657241263
          ],
          [
              -121.02974790789995,
              47.111778278320045
          ],
          [
              -120.35233737469743,
              45.39295372924591
          ]
      ]
    ]
  }',
  '{
    "index": {
        "type": "text/html",
        "title": "HTML index page",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_MTL.txt"
    },
    "thumbnail": {
        "title": "Thumbnail image",
        "type": "image/jpeg",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_thumb_large.jpg"
    },
    "B1": {
        "type": "image/x.geotiff",
        "eo:bands": [
            0
        ],
        "title": "Band 1 (coastal)",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_B1.TIF"
    },
    "B2": {
        "type": "image/x.geotiff",
        "eo:bands": [
            1
        ],
        "title": "Band 2 (blue)",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_B2.TIF"
    },
    "B3": {
        "type": "image/x.geotiff",
        "eo:bands": [
            2
        ],
        "title": "Band 3 (green)",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_B3.TIF"
    },
    "B4": {
        "type": "image/x.geotiff",
        "eo:bands": [
            3
        ],
        "title": "Band 4 (red)",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_B4.TIF"
    },
    "B5": {
        "type": "image/x.geotiff",
        "eo:bands": [
            4
        ],
        "title": "Band 5 (nir)",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_B5.TIF"
    },
    "B6": {
        "type": "image/x.geotiff",
        "eo:bands": [
            5
        ],
        "title": "Band 6 (swir16)",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_B6.TIF"
    },
    "B7": {
        "type": "image/x.geotiff",
        "eo:bands": [
            6
        ],
        "title": "Band 7 (swir22)",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_B7.TIF"
    },
    "B8": {
        "type": "image/x.geotiff",
        "eo:bands": [
            7
        ],
        "title": "Band 8 (pan)",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_B8.TIF"
    },
    "B9": {
        "type": "image/x.geotiff",
        "eo:bands": [
            8
        ],
        "title": "Band 9 (cirrus)",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_B9.TIF"
    },
    "B10": {
        "type": "image/x.geotiff",
        "eo:bands": [
            9
        ],
        "title": "Band 10 (lwir)",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_B10.TIF"
    },
    "B11": {
        "type": "image/x.geotiff",
        "eo:bands": [
            10
        ],
        "title": "Band 11 (lwir)",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_B11.TIF"
    },
    "ANG": {
        "title": "Angle coefficients file",
        "type": "text/plain",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_ANG.txt"
    },
    "MTL": {
        "title": "original metadata file",
        "type": "text/plain",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_MTL.txt"
    },
    "BQA": {
        "title": "Band quality data",
        "type": "image/x.geotiff",
        "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/139/216/LC08_L1GT_139216_20190918_20190918_01_RT/LC08_L1GT_139216_20190918_20190918_01_RT_BQA.TIF"
    }
  }'
);
INSERT INTO data.items_string_geometry(id, collection, type, properties, geometry, assets)
VALUES(
  'LC80320392019263',
  'landsat-8-l1',
  'Feature',
  '{
    "eo:instrument": "OLI_TIRS",
    "eo:off_nadir": 0,
    "datetime": "2019-09-20T17:34:12.746729+00:00",
    "eo:sun_azimuth": 142.76178893,
    "eo:sun_elevation": 54.89633722,
    "eo:cloud_cover": 26,
    "eo:row": "039",
    "eo:column": "032",
    "landsat:product_id": "LC08_L1TP_032039_20190920_20190920_01_RT",
    "landsat:scene_id": "LC80320392019263LGN00",
    "landsat:processing_level": "L1TP",
    "landsat:tier": "RT",
    "landsat:revision": "00",
    "eo:epsg": 32613
  }',
  '{
    "type": "Polygon",
    "coordinates": [
      [
          [
              -106.31458249702669,
              31.359142341561896
          ],
          [
              -104.36212438567114,
              30.969643603518936
          ],
          [
              -104.83155634182356,
              29.23408289106474
          ],
          [
              -106.78203397164981,
              29.63016456454236
          ],
          [
              -106.31458249702669,
              31.359142341561896
          ]
      ]
    ]
  }',
  '{
      "index": {
          "type": "text/html",
          "title": "HTML index page",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_MTL.txt"
      },
      "thumbnail": {
          "title": "Thumbnail image",
          "type": "image/jpeg",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_thumb_large.jpg"
      },
      "B1": {
          "type": "image/x.geotiff",
          "eo:bands": [
              0
          ],
          "title": "Band 1 (coastal)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_B1.TIF"
      },
      "B2": {
          "type": "image/x.geotiff",
          "eo:bands": [
              1
          ],
          "title": "Band 2 (blue)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_B2.TIF"
      },
      "B3": {
          "type": "image/x.geotiff",
          "eo:bands": [
              2
          ],
          "title": "Band 3 (green)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_B3.TIF"
      },
      "B4": {
          "type": "image/x.geotiff",
          "eo:bands": [
              3
          ],
          "title": "Band 4 (red)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_B4.TIF"
      },
      "B5": {
          "type": "image/x.geotiff",
          "eo:bands": [
              4
          ],
          "title": "Band 5 (nir)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_B5.TIF"
      },
      "B6": {
          "type": "image/x.geotiff",
          "eo:bands": [
              5
          ],
          "title": "Band 6 (swir16)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_B6.TIF"
      },
      "B7": {
          "type": "image/x.geotiff",
          "eo:bands": [
              6
          ],
          "title": "Band 7 (swir22)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_B7.TIF"
      },
      "B8": {
          "type": "image/x.geotiff",
          "eo:bands": [
              7
          ],
          "title": "Band 8 (pan)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_B8.TIF"
      },
      "B9": {
          "type": "image/x.geotiff",
          "eo:bands": [
              8
          ],
          "title": "Band 9 (cirrus)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_B9.TIF"
      },
      "B10": {
          "type": "image/x.geotiff",
          "eo:bands": [
              9
          ],
          "title": "Band 10 (lwir)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_B10.TIF"
      },
      "B11": {
          "type": "image/x.geotiff",
          "eo:bands": [
              10
          ],
          "title": "Band 11 (lwir)",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_B11.TIF"
      },
      "ANG": {
          "title": "Angle coefficients file",
          "type": "text/plain",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_ANG.txt"
      },
      "MTL": {
          "title": "original metadata file",
          "type": "text/plain",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_MTL.txt"
      },
      "BQA": {
          "title": "Band quality data",
          "type": "image/x.geotiff",
          "href": "https://landsat-pds.s3.amazonaws.com/c1/L8/032/039/LC08_L1TP_032039_20190920_20190920_01_RT/LC08_L1TP_032039_20190920_20190920_01_RT_BQA.TIF"
      }
  }'
);

require 'test/unit'

require 'rubygems'
require 'fastr/compress'

class CompressTest < Test::Unit::TestCase
  def test_compress_no_accept_encoding
    resp = :myresponse
    env = {}
    after_resp = Fastr::Compress.after_dispatch(nil, env, resp)
    assert_equal(resp, after_resp)
  end

  def test_compress_no_acceptable_encodings
    resp = :myresponse
    env = {'HTTP_ACCEPT_ENCODING' => 'a,invalid,b'}
    after_resp = Fastr::Compress.after_dispatch(nil, env, resp)
    assert_equal(resp, after_resp)
  end

  def test_compress_multiple_encodings_gzip
    resp_body = 'test response'
    resp = [200, {}, [resp_body]]
    env = {'HTTP_ACCEPT_ENCODING' => 'a,b,gzip,c'}
    code, hdrs, body = Fastr::Compress.after_dispatch(nil, env, resp)

    sio = StringIO.new(body[0])
    gz = Zlib::GzipReader.new(sio)
    decompressed = gz.read
    gz.close

    assert_equal(resp_body, decompressed)
    assert_equal('gzip', hdrs['Content-Encoding'])
  end

  def test_compress_multiple_encodings_deflate
    resp_body = 'test response'
    resp = [200, {}, [resp_body]]
    env = {'HTTP_ACCEPT_ENCODING' => 'a,b,deflate,gzip'}
    code, hdrs, body = Fastr::Compress.after_dispatch(nil, env, resp)

    zstream = Zlib::Inflate.new
    decompressed = zstream.inflate(body[0])
    zstream.finish
    zstream.close

    assert_equal('deflate', hdrs['Content-Encoding'])
    assert_equal(resp_body, decompressed)
  end
end

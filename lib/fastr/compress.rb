begin
  require 'zlib'
  HAS_ZLIB = true
rescue
  HAS_ZLIB = false
end

require 'stringio'
require 'fastr/logger'

module Fastr::Compress
  include Fastr::Log

  ACCEPTABLE_ENCODINGS = [:gzip, :deflate]

  def self.after_boot(app)
    if HAS_ZLIB
      logger.debug "Compression plugin loaded."
    else
      logger.error "Compression plugin could not be loaded (zlib not found)."
    end
  end

  def self.compress(response, encoding)
    code, hdrs, body = response

    # Set the content encoding header
    hdrs['Content-Encoding'] = encoding.to_s

    case encoding
    when :gzip
      fake_io = StringIO.new
      gz = Zlib::GzipWriter.new(fake_io, Zlib::DEFAULT_COMPRESSION, Zlib::DEFAULT_STRATEGY)
      gz.write(body.join(""))
      gz.close
      [code, hdrs, [fake_io.string]]
    when :deflate
      z = Zlib::Deflate.new(Zlib::DEFAULT_COMPRESSION)
      dst = z.deflate(body.join(""), Zlib::FINISH)
      z.close
      [code, hdrs, [dst.to_s]]
    else
      raise StandardError.new("not an acceptable encoding format: #{encoding}")
    end
  end

  def self.after_dispatch(app, env, response)
    return response if not HAS_ZLIB
    return response if env['HTTP_ACCEPT_ENCODING'].nil?

    code, hdrs, body = response

    # Check to see what the acceptable content encodings are
    accept_encodings = env['HTTP_ACCEPT_ENCODING'].split(/,/).collect { |e| e.downcase.to_sym }
    encoding_format = nil

    accept_encodings.each do |enc|
      if ACCEPTABLE_ENCODINGS.include? enc
        encoding_format = enc
        break
      end
    end

    return response if encoding_format.nil?

    compress(response, encoding_format)
  end
end

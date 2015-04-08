# encoding: utf-8
require 'sanitize'

module HTML
  class Pipeline

    # HTML filter with sanization routines and whitelists. This module defines
    # what HTML is allowed in user provided content and fixes up issues with
    # unbalanced tags and whatnot.
    #
    # See the Sanitize docs for more information on the underlying library:
    #
    # https://github.com/rgrove/sanitize/#readme
    #
    # Context options:
    #   :whitelist - The sanitizer whitelist configuration to use. This can be one
    #                of the options constants defined in this class or a custom
    #                sanitize options hash.
    #
    # This filter does not write additional information to the context.
    class SanitizationFilter < Filter

      # The main sanitization whitelist. Only these elements and attributes are
      # allowed through by default.
      WHITELIST = {
        :elements => %w(a abbr b blockquote br cite code dd del dfn div dl dt em
                        h1 h2 h3 h4 h5 h6 hr i img ins kbd li mark meter ol p pre
                        q s samp small source span strong sub sup table tbody td
                        tfooter th thead tr time ul var video wbr),
        :remove_contents => ['script'],
        :attributes => {
          :all         => ['data-after', 'data-id', 'id', 'title', 'class'],
          'a'          => ['href', 'name'],
          'blockquote' => ['cite'],
          'img'        => ['alt', 'height', 'src', 'width'],
          'q'          => ['cite'],
          'source'     => ['src', 'type', 'media'],
          'time'       => ['datetime'],
          'video'      => ['src', 'controls']
        },
        :protocols => {
          'a'          => {'href' => ['ftp', 'http', 'https', 'irc', 'mailto', 'xmpp', 'ed2k', 'magnet', :relative]},
          'blockquote' => {'cite' => ['http', 'https', :relative]},
          'img'        => {'src'  => ['http', 'https', :relative]},
          'q'          => {'cite' => ['http', 'https', :relative]}
        }
      }

      # A more limited sanitization whitelist. This includes all attributes,
      # protocols, and transformers from WHITELIST but with a more locked down
      # set of allowed elements.
      LIMITED = WHITELIST.merge(
        :elements => %w(b i strong em a pre code img ins del sup sub p ol ul li))

      # Strip all HTML tags from the document.
      FULL = { :elements => [] }

      # Match unicode chars encoded on 4 bytes in UTF-8
      MB4_REGEXP = /[^\u{9}-\u{ffff}]/

      # Remove utf-8 characters encoded on 4 bytes,
      # because MySQL doesn't handle them.
      def encode_mb4(doc)
        doc.search("text()").each do |node|
          node.content = node.content.gsub(MB4_REGEXP) { |c| "&##{c.unpack('U')[0]};" }
        end
        doc
      end

      # Sanitize markup using the Sanitize library.
      def call
        encode_mb4 Sanitize.node!(doc, whitelist)
      end

      # The whitelist to use when sanitizing. This can be passed in the context
      # hash to the filter but defaults to WHITELIST constant value above.
      def whitelist
        context[:whitelist] || WHITELIST
      end
    end

  end
end

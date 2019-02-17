# encoding: utf-8
module HTML
  class Pipeline

    class LinuxFr
      CONTEXT = {
        toc_minimal_length: 5000,
        toc_header: "<h2 class=\"sommaire\">Sommaire</h2>\n",
        svgtex_url: "http://localhost:16000",
        host: "linuxfr.org",
        whitelist: {
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
            'a'          => {'href' => ['ftp', 'http', 'https', 'irc', 'mailto', 'xmpp', 'ed2k', 'magnet', 'tel', :relative]},
            'blockquote' => {'cite' => ['http', 'https', :relative]},
            'img'        => {'src'  => ['http', 'https', :relative]},
            'q'          => {'cite' => ['http', 'https', :relative]}
          }
        }
      }

      def self.render(text)
        pipeline = HTML::Pipeline.new [
          HTML::Pipeline::SVGTeX::PreFilter,
          HTML::Pipeline::MarkdownFilter,
          HTML::Pipeline::SanitizationFilter,
          HTML::Pipeline::TableOfContentsFilter,
          HTML::Pipeline::SVGTeX::PostFilter,
          HTML::Pipeline::SyntaxHighlightFilter,
          HTML::Pipeline::RelativeLinksFilter,
          HTML::Pipeline::CustomLinksFilter,
        ], CONTEXT
        result = pipeline.call text
        result[:output].to_s
      end

      def self.sanitize(html)
        return "" if html.nil?
        pipeline = HTML::Pipeline.new [HTML::Pipeline::SanitizationFilter]
        result = pipeline.call html
        result[:output].to_s
      end
    end

  end
end

# encoding: utf-8

require_relative "filter"
require_relative "sanitization_filter"

module HTML
  class Pipeline

    class LinuxFr
      CONTEXT = {
        toc_minimal_length: 5000,
        toc_header: "<h2 class=\"sommaire\">Sommaire</h2>\n",
        svgtex_url: "http://localhost:16000",
        host: "linuxfr.org",
        whitelist: HTML::Pipeline::SanitizationFilter::WHITELIST.merge(
          :protocols => {
            'a'          => {'href' => ['tel']}
              }
        ),
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

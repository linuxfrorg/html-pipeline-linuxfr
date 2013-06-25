# encoding: utf-8
module HTML
  class Pipeline

    class LinuxFr
      CONTEXT = {
        toc_minimal_length: 5000,
        toc_header: "<h2 class=\"sommaire\">Sommaire</h2>\n",
        host: "linuxfr.org"
      }

      def self.render(text)
        pipeline = HTML::Pipeline.new [
          HTML::Pipeline::MarkdownFilter,
          HTML::Pipeline::TableOfContentsFilter,
          HTML::Pipeline::SyntaxHighlightFilter,
          HTML::Pipeline::RelativeLinksFilter,
          HTML::Pipeline::CustomLinksFilter,
          HTML::Pipeline::SanitizationFilter
        ], CONTEXT
        result = pipeline.call text
        result[:output].to_s
      end

      def self.sanitize(text)
        pipeline = HTML::Pipeline.new [HTML::Pipeline::SanitizationFilter], CONTEXT
        result = pipeline.call text
        result[:output].to_s
      end
    end

  end
end

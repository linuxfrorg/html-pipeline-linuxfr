# encoding: utf-8
require 'redcarpet'
require 'cgi'

module HTML
  class Pipeline

    # LinuxFr Flavored Markdown
    class LFMarkdown < Redcarpet::Render::HTML
      attr_accessor :image_class

      PARSER_OPTIONS = {
        :no_intra_emphasis  => true,
        :tables             => true,
        :fenced_code_blocks => true,
        :autolink           => true,
        :strikethrough      => true,
        :superscript        => true,
        :footnotes          => true,
      }

      HTML_OPTIONS = {
        :filter_html        => true,
        :no_styles          => true,
        :hard_wrap          => true,
        :xhtml              => true,
      }

      def initialize(extensions={})
        super extensions.merge(HTML_OPTIONS)
      end

      def header(text, header_level)
        l = header_level + 1
        "<h#{l}>#{text}</h#{l}>\n"
      end

      def strikethrough(text)
        "<s>#{text}</s>"
      end

      def image(link, title, alt_text)
        return "" if link.blank?
        ::Image.new(link, title, alt_text).to_html  # FIXME
      end

      def normal_text(text)
        text = CGI.escapeHTML(text)
        text.gsub!('« ', '«&nbsp;')
        text.gsub!(/ ([:;»!?])/, '&nbsp;\1')
        text.gsub!(' -- ', '—')
        text.gsub!('...', '…')
        text
      end

    end


    # HTML Filter that converts Markdown text into HTML and converts into a
    # DocumentFragment. This is different from most filters in that it can take a
    # non-HTML as input. It must be used as the first filter in a pipeline.
    #
    # This filter does not write any additional information to the context hash.
    class MarkdownFilter < TextFilter
      def initialize(text, context = nil, result = nil)
        super text, context, result
        @text = @text.gsub "\r", ''
      end

      # Convert Markdown to HTML using the best available implementation
      # and convert into a DocumentFragment.
      def call
        lfm = Redcarpet::Markdown.new LFMarkdown, LFMarkdown::PARSER_OPTIONS
        lfm.render @text
      end
    end

  end
end

require 'pygments'

module HTML
  class Pipeline

    # HTML Filter that syntax highlights code blocks wrapped
    # in <pre lang="...">.
    class SyntaxHighlightFilter < Filter
      def call
        doc.search('code').each do |node|
          next unless lang = node['class']
          lexer = Pygments::Lexer[lang]

          if lexer
            text = node.inner_text

            html = highlight_with_timeout_handling(lexer, text)
            next if html.nil?

            node.child.replace(html)
          else
            node.remove_attribute 'class'
          end
        end
        doc
      end

      def highlight_with_timeout_handling(lexer, text)
        lexer.highlight(text, options: { nowrap: true })
      rescue Timeout::Error
        nil
      end
    end

  end
end

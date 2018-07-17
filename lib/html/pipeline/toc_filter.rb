module HTML
  class Pipeline

    # HTML filter that adds a 'name' attribute to all headers
    # in a document, so they can be accessed from a table of contents
    #
    # Context options:
    #   :toc_minimal_length (required) - Only add the table of contents to text with this number of characters
    #   :toc_header (required) - Introduce the table of contents with this header
    #
    class TableOfContentsFilter < Filter

      def call
        headers = Hash.new 0
        was = 1
        toc = ""
        doc.css('h2, h3, h4, h5, h6').each do |node|
          level = node.name.scan(/\d/).first.to_i
          name = node.text.downcase
          name.gsub!(/[^\p{Word}\- ]/u, '') # remove punctuation
          name.gsub!(' ', '-') # replace spaces with dash

          uniq = (headers[name] > 0) ? "-#{headers[name]}" : ''
          headers[name] += 1
          node['id'] = "toc-#{name}#{uniq}"

          if was < level
            while was < level
              toc << "<ul>\n<li>"
              was += 1
            end
          else
            toc << "</li>\n"
            while was > level
              toc << "</ul></li>\n"
              was -= 1
            end
            toc << "<li>"
          end
          toc << "<a href=\"#toc-#{name}#{uniq}\">#{node.inner_html}</a>"
        end

        length = 0
        doc.traverse {|node| length += node.text.length if node.text? }
        return doc unless length >= context[:toc_minimal_length]

        while was > 1
          toc << "</li>\n</ul>\n"
          was -= 1
        end
        toc.sub!('<ul>', '<ul class="toc">')

        unless headers.empty?
          first_child = doc.child
          first_child.add_previous_sibling context[:toc_header]
          first_child.add_previous_sibling toc
        end
        doc
      end

      def validate
        needs :toc_minimal_length, :toc_header
      end
    end

  end
end

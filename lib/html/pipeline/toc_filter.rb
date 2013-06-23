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
        length = 0
        doc.traverse {|node| length += node.text.length if node.text? }
        return doc unless length >= context[:toc_minimal_length]

        headers = Hash.new 0
        nodeset = Nokogiri::XML::NodeSet.new doc.document
        doc.css('h1, h2, h3, h4, h5, h6').each do |node|
          name = node.text.downcase
          name.gsub!(/[^\w\- ]/, '') # remove punctuation
          name.gsub!(' ', '-') # replace spaces with dash
          name = EscapeUtils.escape_uri(name) # escape extended UTF-8 chars

          uniq = (headers[name] > 0) ? "-#{headers[name]}" : ''
          headers[name] += 1
          node['id'] = "#{name}#{uniq}"
          # TODO
          li = doc.document.parse "<li><a href=\"##{name}#{uniq}\">#{node.inner_html}</a></li>"
          nodeset << li.first
        end

        unless nodeset.empty?
          first_child = doc.child
          first_child.add_previous_sibling(context[:toc_header])
          first_child.add_previous_sibling('<ul class="toc">' + nodeset.to_html + '</ul>')
        end
        doc
      end

      def validate
        needs :toc_minimal_length, :toc_header
      end
    end

  end
end

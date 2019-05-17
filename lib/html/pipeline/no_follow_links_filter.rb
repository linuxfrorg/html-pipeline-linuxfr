module HTML
  class Pipeline

    # Add rel="nofollow" to <a> links if enabled in the context to avoid giving
    # SEO juice to potential spam links.
    class NoFollowLinksFilter < Filter

      def call
        return doc unless context[:nofollow]

        doc.css("a[href]").each do |element|
          element['rel'] = 'nofollow'
        end
        doc
      end

    end

  end
end

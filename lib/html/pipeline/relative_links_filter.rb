module HTML
  class Pipeline

    # HTML Filter for replacing http and https urls with protocol relative versions.
    class RelativeLinksFilter < Filter

      def call
        h = context[:host]
        doc.css("a[href^=\"http://#{h}\"],a[href^=\"https://#{h}\"]").each do |element|
          element['href'] = element['href'].sub(/^https?:/, '')
        end
        doc
      end

    end

  end
end

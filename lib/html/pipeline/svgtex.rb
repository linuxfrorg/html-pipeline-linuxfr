# encoding: utf-8
require 'base64'
require 'digest/sha1'
require 'patron'

module HTML
  class Pipeline
    class SVGTeX

      class PreFilter < TextFilter
        def initialize(text, context = nil, result = nil)
          super text, context, result
          @text = @text.gsub "\r", ''
          @codemap = {}
        end

        def call
          extract_code!
          @text.gsub!(/^\$\$([^$]+)\$\$\s*$/) do
            "\n\n```mathjax\n\\displaystyle{#{$1.gsub "\\", "\\\\\\\\"}}\n```\n\n"
          end
          extract_code!
          @text.gsub!(/\$([^$\n]+)\$/) do
            "`{mathjax} #{$1}`"
          end
          reinsert_code!
          @text
        end

        # Code taken from gollum (http://github.com/github/gollum)
        def extract_code!
          @text.gsub!(/^``` ?(.*?)\r?\n(.+?)\r?\n```\r?$/m) do
            id = Digest::SHA1.hexdigest($2)
            @codemap[id] = { :lang => $1, :code => $2 }
            id
          end
        end

        def reinsert_code!
          @codemap.each do |id, spec|
            @text.gsub!(id, "```#{spec[:lang]}\n#{spec[:code]}\n```")
          end
        end
      end

      class PostFilter < Filter
        def call
          doc.search('code.mathjax').each do |node|
            eqn = node.inner_text
            rsp = session.post(context[:svgtex_url], :q => eqn)
            if rsp.status == 200
              node.parent.replace rsp.body.gsub(/margin-(left|right): 0px; /, "")
            else
              node.remove_attribute 'class'
            end
          end
          doc.search('code:not([class])').each do |node|
            eqn = node.inner_text
            next unless eqn.sub!(/\A\{mathjax\} /, '')
            rsp = session.post(context[:svgtex_url], :q => eqn)
            if rsp.status == 200
              node.replace "<img class='mathjax' src='data:image/svg+xml;base64,#{Base64.encode64 rsp.body}' alt='#{CGI.escape_html eqn}' />"
            else
              node.inner_text = eqn
            end
          end
          doc
        end

        def session
          @session ||= Patron::Session.new
        end
      end

    end
  end
end

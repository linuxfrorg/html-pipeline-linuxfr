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
          @inline = {}
          @codemap = {}
        end

        def call
          extract_fenced_code!
          extract_indented_code!
          @text.gsub!(/^\$\$([^$]+)\$\$\s*$/) do
            "\n\n```mathjax\n\\displaystyle{#{$1.gsub "\\", "\\\\\\\\"}}\n```\n\n"
          end
          extract_fenced_code!
          extract_inline_code!
          @text.gsub!(/\$([^$\n]+)\$/) do
            "`{mathjax} #{$1}`"
          end
          reinsert_code!
          @text
        end

        def extract_inline_code!
          @text.gsub!(/`(.*)`/) do
            id = Digest::SHA1.hexdigest($1)
            @inline[id] = $1
            id
          end
        end

        def extract_indented_code!
          @text.gsub!(/(\A|\n\r?\n)(((\t|\s{4}).*(\n|\Z))+)(\r?\n|\Z)/) do
            code = $2.gsub(/^(\t|\s{4})/, '').sub(/\r?\n\Z/, '')
            id = Digest::SHA1.hexdigest(code)
            @codemap[id] = { :code => code }
            "\n#{id}"
          end
        end

        # Code taken from gollum (http://github.com/github/gollum)
        def extract_fenced_code!
          @text.gsub!(/^``` ?(.*?)\r?\n(.+?)\r?\n```\r?$/m) do
            id = Digest::SHA1.hexdigest($2)
            @codemap[id] = { :lang => $1, :code => $2 }
            id
          end
        end

        def reinsert_code!
          @inline.each do |id, code|
            @text.gsub!(id) { "`#{code}`" }
          end
          @codemap.each do |id, spec|
            @text.gsub!(id) { "```#{spec[:lang]}\n#{spec[:code]}\n```" }
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
              node.replace "<img style='display: inline; max-height: 1em;' class='mathjax' src='data:image/svg+xml;base64,#{Base64.encode64 rsp.body}' alt='#{CGI.escape_html eqn}' />"
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

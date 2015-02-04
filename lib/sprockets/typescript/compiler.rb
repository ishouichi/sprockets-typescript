require "sprockets"
require 'typescript-node'

module Sprockets
  module Typescript
    class Compiler
      def replace_relative_references(ts_path, source)
        ts_dir = File.dirname(File.expand_path(ts_path))
        escaped_dir = ts_dir.gsub(/["\\]/, '\\\\\&') # "\"" => "\\\"", '\\' => '\\\\'

        # Why don't we just use gsub? Because it display odd behavior with File.join on Ruby 2.0
        # So we go the long way around.
        output = (source.each_line.map do |l|
          if l.start_with?('///') && !(m = %r!^///\s*<reference\s+path="([^"]+)"\s*/>\s*!.match(l)).nil?
            l = l.sub(m.captures[0], File.join(escaped_dir, m.captures[0]))
          end
          next l
        end).join

        output
      end

      def compile(path, content, options = nil)
        options ||= %w(--target ES5)
        TypeScript::Node.compile(replace_relative_references(path, content), *options)
      end
    end
  end
end

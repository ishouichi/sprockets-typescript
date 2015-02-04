require "tilt"
require "sprockets/typescript/compiler"

module Sprockets
  module Typescript
    class Template < ::Tilt::Template
      self.default_mime_type = "text/javascript"

      def prepare
        @compiler = Compiler.new
      end

      def evaluate(context, locals, &block)
        @compiler.compile(context.pathname.to_s, data)
      end
    end
  end
end

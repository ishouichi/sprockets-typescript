require "sprockets"
require "v8"

module Sprockets
  module Typescript
    class Compiler
      DEFAULT_LIB_PATH = File.expand_path("../../../../bundledjs/lib.d.ts", __FILE__)

      class Console
        def log(s)
          $stderr.puts(s)
        end
      end

      class Unit
        attr_reader :path, :content

        def initialize(path, content = nil)
          @path = path
          @content = content
        end
      end

      class Context
        def initialize(context)
          @context = context
        end

        def resolve(path)
          if path == DEFAULT_LIB_PATH
            path
          else
            @context.resolve(path, :content_type => :self).to_s
          end
        end

        def evaluate(path)
          pathname = Pathname.new(path)
          attributes = @context.environment.attributes_for(path)
          processors = attributes.processors
          processors = processors.reject { |p| p == Sprockets::Typescript::Template }
          if defined?(Sprockets::CommonJS)
            processors = processors.reject { |p| p == Sprockets::CommonJS }
          end

          context = @context.environment.context_class.new(@context.environment, attributes.logical_path, pathname)
          content = context.evaluate(pathname, :processors => processors)
          { :content => content, :context => self.class.new(context) }
        end

        def depends_on(path)
          @context.depend_on_asset(path)
        end

        def require(path)
          @context.require_asset(path)
        end
      end

      def initialize
        @ctx = V8::Context.new
        %w(typescript.patched compiler).each do |filename|
          @ctx.load(File.expand_path("../../../../bundledjs/#{filename}.js", __FILE__))
        end
      end

      def eval(*args)
        @ctx.eval(*args)
      end

      def compile(path, content, context = nil)
        libdts = Unit.new(DEFAULT_LIB_PATH, File.read(DEFAULT_LIB_PATH))
        additional_units = [libdts]
        @ctx["Ruby"] = {
          "source" => Unit.new(path, content),
          "additionalUnits" => additional_units,
          "context" => context.nil? ? nil : Context.new(context),
          "console" => Console.new
        }
        @ctx.eval("Compiler.compile()")
      end
    end
  end
end

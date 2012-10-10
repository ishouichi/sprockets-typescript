require "spec_helper"

describe Sprockets::Typescript::Compiler do
  context "#new" do
    it { expect { described_class.new }.to_not raise_error }
  end

  context "instance" do
    let(:instance) { described_class.new }

    context "#eval('typeof TypeScript')" do
      subject { instance.eval("typeof TypeScript") }
      it { should eql "object" }
    end

    context "#compile source " do
      context "Math.abs(<number>-5);" do
        subject { instance.compile("test.ts", "Math.abs(<number>-5);").chomp }
        it { should eql "Math.abs(-5);" }
      end

      context "Math.abs('hello');" do
        let(:source) { "Math.abs('hello');" }
        it "should raise error" do
          expect { instance.compile("test.ts", source) }.to raise_error
        end

        context "exception message" do
          subject do
            begin
              instance.compile("test.ts", source)
            rescue V8::JSError => e
              e.message
            end
          end
          it { should eql "TypeScript compiler: test.ts (1,18): Supplied parameters do not match any signature of call target" }
        end
      end
    end
  end
end

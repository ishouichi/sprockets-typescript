require "spec_helper"

describe Sprockets::Environment do
  let(:environment) { described_class.new(File.expand_path("../../", __FILE__)) }

  context "assets/template1 directory" do
    before(:all) do
      environment.clear_paths
      environment.append_path("spec/assets/template1")
    end

    context "#find_asset('foo')" do
      subject { environment.find_asset("foo") }
      it { should_not be_nil }
      it { subject.to_s.should eql "var add = function (x, y) {\n    return x + y;\n};\n" }
    end

    context "#find_assets('bar')" do
      subject { environment.find_asset("bar") }
      it { should_not be_nil }
      it { subject.to_s.should eql "var x = 5;\n" }
    end
  end

  context "assets/template2 directory" do
    before(:all) do
      environment.clear_paths
      environment.append_path("spec/assets/template2")
    end

    context "#find_asset('foo')" do
      subject { environment.find_asset("foo") }
      it { should_not be_nil }
      it { subject.to_s.should eql "Moo.moo();\n" }
    end
  end

  context "assets/template3 directory" do
    before(:all) do
      environment.clear_paths
      environment.append_path("spec/assets/template3")
    end

    context "#find_asset('foo')" do
      subject { environment.find_asset("foo") }
      it { should_not be_nil }
      it { subject.to_s.should eql "function moo() {\n    return \"moo\";\n}\nexports.moo = moo;\n\nvar foo = require(\"./bar\")\nfoo.moo();\n\n" }
    end
  end

  context "assets/template4 directory" do
    before(:all) do
      environment.clear_paths
      environment.append_path("spec/assets/template4")
    end

    context "#find_asset('foo')" do
      subject { environment.find_asset("foo") }
      it { should_not be_nil }
      it { subject.to_s.should eql "Bar.bar();\n" }
    end

    context "#find_asset('moo')" do
      subject { environment.find_asset("moo") }
      it { should_not be_nil }
      it { subject.to_s.should eql "var Bar;\n(function (Bar) {\n    function bar() {\n        return \"bar\";\n    }\n    Bar.bar = bar;\n})(Bar || (Bar = {}));\n\nBar.bar();\n" }
    end
  end
end

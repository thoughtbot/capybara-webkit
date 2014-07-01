require 'spec_helper'
require 'capybara_webkit_builder'

describe CapybaraWebkitBuilder do
  let(:builder) { CapybaraWebkitBuilder }

  it "will use the env variable for #make_bin" do
    with_env_vars("MAKE" => "fake_make") do
      expect(builder.make_bin).to eq("fake_make")
    end
  end

  it "will use the env variable for #qmake_bin" do
    with_env_vars("QMAKE" => "fake_qmake") do
      expect(builder.qmake_bin).to eq("fake_qmake")
    end
  end

  it "will use the env variable for #os_spec" do
    with_env_vars("SPEC" => "fake_os_spec") do
      expect(builder.spec).to eq("fake_os_spec")
    end
  end

  it "defaults the #make_bin" do
    with_env_vars("MAKE_BIN" => nil) do
      expect(builder.make_bin).to eq('make')
    end
  end

  it "defaults the #qmake_bin" do
    with_env_vars("QMAKE" => nil) do
      expect(builder.qmake_bin).to eq('qmake')
    end
  end

  it "defaults #spec to the #os_specs" do
    with_env_vars("SPEC" => nil) do
      expect(builder.spec).to eq(builder.os_spec)
    end
  end
end


# Imported from the MacRuby sources

class Mock
  def call!
    @called = true
  end

  def called?
    @called
  end
end

class TestMappings < MiniTest::Unit::TestCase

  include HotCocoa

  def teardown
    Mappings.mappings[:klass] = nil
    Mappings.frameworks["theframework"] = nil
    Mappings.loaded_frameworks.delete('theframework')
  end

  def test_should_have_two_Hash_attributes_named #mappings and #frameworks" do
    assert Mappings.mappings.is_a?(Hash)
    assert Mappings.frameworks.is_a?(Hash)
  end

  def test_should_create_a_mapping_to_a_class_with_a_Class_instance_given_to #map" do
    Mappings.map(:klass => SampleClass) {}
    assert_equal SampleClass, Mappings.mappings[:klass].control_class
  end

  def test_should_create_a_mapping_to_a_class_with_a_string_name_of_the_class_given_to_map
    Mappings.map(:klass => 'SampleClass') {}
    assert_equal SampleClass, Mappings.mappings[:klass].control_class
  end

  def test_should_create_a_mapping_to_a_class_with_a_symbol_name_of_the_class_given_to_map
    Mappings.map(:klass => :SampleClass) {}
    assert_equal SampleClass, Mappings.mappings[:klass].control_class
  end

  def test_should_register_the_key_in_the_options_given_to_map_as_the_builder_method
    Mappings.map(:klass => SampleClass) {}
    assert_equal Mappings.mappings[:klass].builder_method, :klass
  end

  def test_should_use_the_block_given_to_map_as_the_control_module_body
    Mappings.map(:klass => SampleClass) do
      def a_control_module_instance_method; end
    end

    assert Mappings.mappings[:klass].control_module.
            instance_methods.include?(:a_control_module_instance_method)
  end

  def test_should_create_a_mapping_to_a_class_in_a_framework_with_map
    mock = Mock.new

    Mappings.map(:klass => 'SampleClass', :framework => 'TheFramework') do
      mock.call!
    end
    Mappings.frameworks["theframework"].last.call

    assert mock.called?
  end

  def test_should_execute_the_frameworks_callbacks_when_framework_loaded_is_called
    mocks = Array.new(2) { Mock.new }

    mocks.each do |mock|
      Mappings.on_framework('TheFramework') { mock.call! }
    end
    Mappings.framework_loaded('TheFramework')

    mocks.each { |mock| assert mock.called? }
  end

  def test_should_do_nothing_if_the_framework_loaded_is_not_registered
    assert_nothing_raised do
      Mappings.framework_loaded('FrameworkDoesNotExist')
    end
  end

  def test_should_resolve_a_constant_when_a_framework_thats_registered_with #map, is loaded" do
    assert_nothing_raised(NameError) do
      Mappings.map(:klass => 'ClassFromFramework', :framework => 'TheFramework') {}
    end

    # The mapping should not yet exist
    assert_nil Mappings.mappings[:klass]

    # now we actually define the class and fake the loading of the framework
    eval "class ::ClassFromFramework; end"
    Mappings.framework_loaded('TheFramework')

    # It should be loaded by now
    assert_equal ClassFromFramework, Mappings.mappings[:klass].control_class
  end

  def test_should_keep_a_unique_list_of_loaded_frameworks
    assert_difference("Mappings.loaded_frameworks.length", +1) do
      Mappings.framework_loaded('TheFramework')
      Mappings.framework_loaded('TheFramework')
    end

    assert Mappings.loaded_frameworks.include?('theframework')
  end

  def test_should_return_whether_or_not_a_framework_has_been_loaded_yet
    Mappings.framework_loaded('TheFramework')
    assert Mappings.loaded_framework?('TheFramework')

    assert !Mappings.loaded_framework?('IHasNotBeenLoaded')
    assert !Mappings.loaded_framework?(nil)
    assert !Mappings.loaded_framework?('')
  end

  def test_reload
    flunk 'Pending.'
  end
end
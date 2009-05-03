require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AMC::Acts::Importable do
  
  it "should include instance methods" do
    Legacy::Thing.new.should be_kind_of(AMC::Acts::Importable::InstanceMethods)
  end
  
  it "should extend singleton methods" do
    Legacy::Thing.should be_kind_of(AMC::Acts::Importable::SingletonMethods)
  end
  
  describe "importing from an instance of a single model" do
    before(:each) do
      @legacy_thing = create_legacy_thing
    end
    
    it "should build the new model using the legacy model's to_model method" do
      @legacy_thing.should_receive(:to_model)
      @legacy_thing.import
    end
    
    it "should assign the legacy model's ID to the legacy_id attribute in the new model" do
      new_model = @legacy_thing.import
      new_model.legacy_id.should == @legacy_thing.id
    end
    
    it "should assign the legacy model's class name to the legacy_class attribute of the new model" do
      new_model = @legacy_thing.import
      new_model.legacy_class.should == @legacy_thing.class.to_s
    end
    
    it "should save the new model" do
      new_model = @legacy_thing.import
      new_model.should_not be_new_record
    end
  end
  
  describe "importing a single model" do
    before(:each) do
      @legacy_thing = mock(Legacy::Thing, :import => nil)
      Legacy::Thing.stub!(:find).and_return(@legacy_thing)
    end
    
    it "should find the legacy model" do
      Legacy::Thing.should_receive(:find).with(123)
      Legacy::Thing.import(123)
    end
    
    it "should import the legacy model" do
      @legacy_thing.should_receive(:import)
      Legacy::Thing.import(123)
    end
  end
  
  describe "importing all models" do
    before(:each) do
      @legacy_thing_1 = mock(Legacy::Thing, :import => nil)
      @legacy_thing_2 = mock(Legacy::Thing, :import => nil)
      Legacy::Thing.stub!(:all).and_return([@legacy_thing_1, @legacy_thing_2])
    end
    
    it "should find all legacy models" do
      Legacy::Thing.should_receive(:all)
      Legacy::Thing.import_all
    end
    
    it "should import each of the legacy models" do
      @legacy_thing_1.should_receive(:import)
      @legacy_thing_2.should_receive(:import)
      Legacy::Thing.import_all
    end
  end
  
  describe "looking up legcy IDs for already imported models" do
    before(:all) do
      @legacy_thing   = create_legacy_thing
      @imported_thing = @legacy_thing.import
    end
    
    before(:each) do
      Legacy::Thing.flush_lookups!
    end
    
    it "should attempt to find the imported model by legacy_id" do
      Thing.should_receive(:first).with(:conditions => {:legacy_id => 123, :legacy_class => 'Legacy::Thing'})
      Legacy::Thing.lookup(123)
    end
    
    it "should return the ID of the imported model with a matching legacy_id" do
      Legacy::Thing.lookup(@legacy_thing.id).should == @imported_thing.id
    end
    
    it "should memoize the mapping from the legacy_id to the imported model's ID" do
      Thing.should_receive(:first).and_return(@imported_thing)
      Legacy::Thing.lookup(@legacy_thing.id).inspect
      Thing.should_not_receive(:find_by_legacy_id)
      Legacy::Thing.lookup(@legacy_thing.id).inspect
    end
  end
  
  describe "looking up legacy IDs for already imported models when importing to a model with a different class name to the legacy model" do
    before(:all) do
      @other_legacy_thing = create_other_legacy_thing
    end
    
    before(:each) do
      Legacy::Thing.flush_lookups!
    end
    
    it "should attempt to find the imported model with the specified class name by legacy_id" do
      Thing.should_receive(:first).with(:conditions => {:legacy_id => 123, :legacy_class => 'Legacy::OtherThing'})
      Legacy::OtherThing.lookup(123)
    end
  end
  
end
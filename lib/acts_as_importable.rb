module AMC
  module Acts
    module Importable
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        
        def acts_as_importable(options = {})
          # Store the import target class with the legacy class
          write_inheritable_attribute :importable_to, options[:to]
          
          # Don't extend or include twice. This will allow acts_as_importable to be called multiple times.
          # eg. once in a parent class and once again in the child class, where it can override some options.
          extend  AMC::Acts::Importable::SingletonMethods unless self.methods.include?('import') && self.methods.include?('import_all')
          include AMC::Acts::Importable::InstanceMethods unless self.included_modules.include?(AMC::Acts::Importable::InstanceMethods)
        end
        
      end # ClassMethods
      
      module SingletonMethods
        def import(id)
          find(id).import
        end

        def import_all
          all.each do |legacy_model|
            legacy_model.import
          end
        end
        
        # This requires a numeric primary key for the legacy tables
        def import_all_in_batches
          each do |legacy_model|
            legacy_model.import
          end
        end

        def lookup(id)
          lookup_class = read_inheritable_attribute(:importable_to) || "#{self.to_s.split('::').last}"
          lookups[id] ||= Kernel.const_get(lookup_class).first(:conditions => {:legacy_id => id, :legacy_class => self.to_s}).try(:id__)
        end

        def flush_lookups!
          @lookups = {}
        end

        private

        def lookups
          @lookups ||= {}
        end

      end # SingletonMethods
      
      module InstanceMethods
        
        def import
          returning to_model do |new_model|
            if new_model
              new_model.legacy_id     = self.id         if new_model.respond_to?(:"legacy_id=")
              new_model.legacy_class  = self.class.to_s if new_model.respond_to?(:"legacy_class=")
              
              if !new_model.save
                p new_model.errors
                # TODO log an error that the model failed to save
                # TODO remove the raise once we're out of the development cycle
                raise
              end
            end
          end
        end
      end # InstanceMethods
      
    end
  end
end
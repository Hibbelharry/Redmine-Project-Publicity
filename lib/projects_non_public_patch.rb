module ProjectPublicity
  module ProjectsNonPublicPatch
    def self.included(base)
      base.class_eval do
        def create
          
        end
        
        def update
          
        end
      end
    end
  end 
end

module ShaneAndPeterDesign
  module ApplicationControllerPatch
    def self.included(base)
      base.class_eval do
        helper :shane_and_peter_design
      end
    end
  end
end

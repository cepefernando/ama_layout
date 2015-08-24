module AmaLayout
  class Navigation
    include ActiveModel::Model
    include Draper::Decoratable

    attr_accessor :user, :current_url

    cattr_accessor :member do
      "member"
    end
    cattr_accessor :non_member do
      "non-member"
    end
    cattr_accessor :member_in_renewal do
      "member-in-renewal"
    end
    cattr_accessor :member_in_renewal_late do
      "member-in-renewal-late"
    end

    def items
      navigation_items.fetch(user.try(:navigation), []).map do |n|
        NavigationItem.new n.merge({ current_url: current_url})
      end
    end

  private
    def navigation_items
      file = File.join Gem.loaded_specs["ama_layout"].full_gem_path, "lib", "ama_layout", "navigation.yml"
      YAML.load ERB.new(File.read file).result
    end
  end
end
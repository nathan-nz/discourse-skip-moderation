#plugin.rb
# name: discourse-skip-moderation
# about: Skip posts from specified categories and groups to go through moderation.
# version: 0.4
# authors: Leo Davidson, Nathan Kershaw
# url: https://github.com/leodavidson/discourse-skipmoderation

enabled_site_setting :skip_moderation_enabled

after_initialize do
  module ::DiscourseSkipModeration
    def post_needs_approval?(manager)
      superResult = super
      Rails.logger.info("Skip moderation: superResult = #{superResult}")
      return superResult if ((!(SiteSetting.skip_moderation_enabled)) || (superResult != :skip))

      if SiteSetting.skip_moderation_groups_categories.is_a? String
        groupName = manager.user.groups.pluck(:name).map(&:downcase)
        Rails.logger.info("Skip moderation: groupName = #{groupName}")
        categoryName = manager.args[:category].downcase
        Rails.logger.info("Skip moderation: categoryName = #{categoryName}")
        groupCategoryArray = SiteSetting.skip_moderation_groups_categories.downcase.split("|")
        Rails.logger.info("Skip moderation: groupCategoryArray = #{groupCategoryArray}")
        groupCategoryArray.each do |groupCategory|
          group, category = groupCategory.split(":")
          return :skip if groupName.include?(group) && category == categoryName
        end
      end

      return :trust_level
    end
  end

  NewPostManager.singleton_class.prepend ::DiscourseSkipModeration
end

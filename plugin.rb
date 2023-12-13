#plugin.rb
# name: discourse-skip-moderation
# about: Skip posts from specified categories and groups to go through moderation.
# version: 0.4
# authors: Leo Davidson, Nathan Kershaw
# url: https://github.com/leodavidson/discourse-skipmoderation

enabled_site_setting :skip_moderation_enabled

after_initialize do
  module ::DiscourseSkipModeration
    def create_post
      if SiteSetting.skip_moderation_enabled && SiteSetting.skip_moderation_groups_categories.is_a?(String)
        groupName = @opts[:user].groups.pluck(:name).map(&:downcase)
        Rails.logger.info("Skip moderation: groupName = #{groupName}")
        categoryName = @opts[:category].downcase
        Rails.logger.info("Skip moderation: categoryName = #{categoryName}")
        groupCategoryArray = SiteSetting.skip_moderation_groups_categories.downcase.split("|")
        Rails.logger.info("Skip moderation: groupCategoryArray = #{groupCategoryArray}")
        groupCategoryArray.each do |groupCategory|
          group, category = groupCategory.split(":")
          if groupName.include?(group) && category == categoryName
            @opts[:skip_validations] = true
            break
          end
        end
      end
      super
    end
  end

  PostCreator.prepend ::DiscourseSkipModeration
end

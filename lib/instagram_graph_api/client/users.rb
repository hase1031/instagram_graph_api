module InstagramGraphApi
  class Client
    module Users

      ACCOUNT_METRIC_HASH = {
        day: 'email_contacts,follower_count,get_directions_clicks,impressions,phone_call_clicks,profile_views,reach,text_message_clicks,website_clicks',
        week: 'impressions,reach',
        days_28: 'impressions,reach',
        lifetime: 'audience_city,audience_country,audience_gender_age,audience_locale,online_followers'
      }


      def ig_business_accounts(fields = nil)
        fields ||= 'id,name,biography,ig_id,followers_count,profile_picture_url,username'
        accounts = get_pages("?fields=instagram_business_account{#{fields}}")
        accounts.map do |a|
          a["instagram_business_account"].merge(page_id: a["id"]) if a["instagram_business_account"]
        end.compact
      end

      def connected_ig_accounts(fields = nil)
        fields ||= 'id,name,biography,ig_id,followers_count,profile_picture_url,username'
        accounts = get_pages("?fields=connected_instagram_account{#{fields}}")
        accounts.map do |a|
          a["connected_instagram_account"].merge(page_id: a["id"]) if a["connected_instagram_account"]
        end.compact
      end

      def get_account_info(ig_account_id, fields = nil)
        fields ||= "biography,followers_count,ig_id,name,profile_picture_url,username,id"
        get_connections(ig_account_id , "?fields=#{fields}")
      end

      def get_account_insights(ig_account_id, period = 'day', since_time, until_time, metrics: nil)
        metrics ||= ACCOUNT_METRIC_HASH[period.to_sym]
        if period == 'lifetime'
          get_connections(ig_account_id, "insights?metric=#{metrics}&period=#{period}")
        else
          get_connections(ig_account_id, "insights?metric=#{metrics}&since=#{since_time.to_i}&until=#{until_time.to_i}&period=#{period}")
        end
      end

      private

      def get_pages(params="")
        begin
          get_connections('me', "accounts#{params}")
        rescue Exception => e
          puts e.message
          []
        end
      end

      def get_business_account_id
        ig_business_accounts.first.dig('id')
      end
    end
  end
end

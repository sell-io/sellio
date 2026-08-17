namespace :alerts do
  desc "Email each saved search's owner about new matching listings since it was last checked. Intended to run daily via cron - see BACKUP_README.md for how this app's other cron job (db:backup) is set up."
  task saved_searches: :environment do
    puts "Checking #{SavedSearch.count} saved searches for new listings..."

    sent = 0
    SavedSearch.find_each do |saved_search|
      since = saved_search.last_notified_at || saved_search.created_at
      listings = saved_search.matching_listings(since: since)

      if listings.any?
        SavedSearchMailer.new_listings(saved_search, listings).deliver_now
        saved_search.update!(last_notified_at: Time.current)
        sent += 1
        puts "  Sent #{listings.count} new listing(s) for \"#{saved_search.name}\" to #{saved_search.user.email}"
      end
    end

    puts "Done. #{sent} digest email(s) sent."
  end
end

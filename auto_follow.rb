require 'watir'
require 'rb-readline'
require 'awesome_print'
require 'pry'
require 'ruby-instagram-scraper'
require 'rubygems'
require 'json'
require 'nokogiri'
require 'active_support'
require 'active_support/time'


# Add your username and password in place of 'ENV['USERNAME']' or go and add those variables in your own .env file.
username = ENV['USERNAME']
password = ENV['PASSWORD']
@follow_counter = 0
@unfollow_counter = 0
@my_followers = []

# Set this to the max amount of follows or unfollows you are wanting per hour.
MAX_UNFOLLOWS = 160
MAX_FOLLOWS = 160

@usernames = []
@keywords = ["entrepreneur", "cool", "workhard", "hardwork", "MLM", "hardworker", "boss", "startup", "CEO", "Founder", "founder", "ceo", "funding", "san jose", "design agency", "web development", "businesses", "logo design", "branding"]
@users = ["bwzyco", "tailopez", "mcuban", "garyvee", "lewishowes", "marieforleo", "lawofambition", "timferriss", "ariannahuff", "gerardadams", "tonyrobbins", "andyfrisella", "brenebrown", "peterjvoogd", "kevinrose", "gabbybernstein", "alexisohanian", "arvinsworld", "calebmaddix", "sarablakely"]
@page_ids = []

def scrape_usernames
  @keywords.each do |keyword|
    results = RubyInstagramScraper.search("#{keyword}")
    results["users"].each do |t|
      @usernames << t["user"]["username"]
    end
  end
end

def counter_checker
  if @unfollow_counter >= MAX_UNFOLLOWS
    @end_time = Time.now
    ap "Followed #{@follow_counter} users and unfollowed #{@unfollow_counter} in #{((@end_time - @start_time)/60).round(2)} minutes"
    ap "[SLEEP] - We're now waiting an hour until we can follow/unfollow some more."
    @unfollow_counter = 0
    #Sleep for an hour
    sleep(3600)
    ap "...."
  elsif @follow_counter >= MAX_FOLLOWS
    @end_time = Time.now
    ap "Followed #{@follow_counter} users and unfollowed #{@unfollow_counter} in #{((@end_time - @start_time)/60).round(2)} minutes"
    ap "[SLEEP] - We're now waiting an hour until we can follow/unfollow some more."
    @follow_counter = 0
    #Sleep for an hour
    sleep(3600)
    ap "...."
  end
end

# Open Browser, Navigate to Login Page
@browser = Watir::Browser.new :chrome

@browser.goto "instagram.com/accounts/login"

# Navigate to Username and Password Fields, Inject info
ap "Logging in..."
@browser.text_field(:name => "username").set "#{username}"
@browser.text_field(:name => "password").set "#{password}"
sleep(2)

# Click Login button@browser.button(:class => ['_qv64e', '_gexxb', '_4tgw8', '_njrw0']).click
ap "You did it. Welcome."
sleep(2)

@start_time = Time.now

# Scrape for Usernames
scrape_usernames

ap "Following or Unfollowing based on your keywords."

# Follow or Unfollow
loop do
  @usernames.shuffle.each do |username|
    # Navigate to User
  @browser.goto "instagram.com/#{username}/"
    # If not following, then Follow
    if@browser.button(:class => ['_qv64e', '_gexxb', '_r9b8f', '_njrw0']).exists?
      if @my_followers.include?(username)
        ap "#{username} is already following you. We won't follow them again."
        usernames.delete(username)
        # Checks if needing to quit program
        counter_checker
      elsif !@my_followers.include?(username)
      @browser.button(:class => ['_qv64e', '_gexxb', '_r9b8f', '_njrw0']).click
        @follow_counter += 1
        ap "Followed #{username}, since they haven't followed you yet."
        # Checks if needing to quit program
        counter_checker
      end
    # If following, Unfollow
  elsif @browser.button(:class => ['_qv64e', '_t78yp', '_r9b8f', '_njrw0']).exists?
    @browser.button(:class => ['_qv64e', '_t78yp', '_r9b8f', '_njrw0']).click
      @unfollow_counter += 1
      ap "Unfollowed #{username}"
      # Checks if needing to quit program
      counter_checker
    end
  end
end

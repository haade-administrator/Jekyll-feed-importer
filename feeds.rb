require 'rubygems'
require 'feed-normalizer'
require 'time'
require 'yaml'
require 'to_slug'
require 'sanitize'

feed_file = "../_site/exporters/feeds.yml"
output_location = "../_topics"

feed = YAML.load_file(feed_file) 
feed.each do |feeditem|
	
	feed_url = feeditem["feed"]
    	name = feeditem["name"]

	rss = FeedNormalizer::FeedNormalizer.parse URI.open(feed_url)
	rss.parser = "SimpleRSS"   

	rss.entries.each do |entry|
		title = entry.title.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '-').gsub(":", " -")
		body = entry.content
		authors = entry.authors.join(', ') rescue ''
		entry_url = entry.urls.first
		dateadded = Time.new
		date = entry.date_published
		updated = entry.last_updated
		date = updated if date.nil?
		date = dateadded if date.nil?

		filename = "#{output_location}/#{title.to_slug.sub(/-\Z/,"")}.md"
		description = if entry.description.nil?
            	Sanitize.fragment(entry.content)
          	else
            	Sanitize.fragment(entry.description)
          	end
	
		if File.exist?(filename)
			next
		else
			file = File.new(filename, "w+")
			file.puts "---"
			file.puts "title: \"#{title}\""
			file.puts "date: #{date}"
			file.puts "dateadded: #{dateadded}"
			file.puts "description: \"#{description}\""
			file.puts "link: \"#{entry_url}\""
			file.puts "category:"
			file.puts "---"
			file.close
		end
	end  
end

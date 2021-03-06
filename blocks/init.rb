#!/usr/bin/env ruby

init_msg = "<link href=\"../boot/bootstrap.css\" rel=\"stylesheet\">
<strong><br /><br />Please Read The \"README\" file first to run the script and generate the results.</strong>"

blocks = [
     "comments_block.html",
     "followers_block_1.html",
     "followers_block_2.html",
     "numbers_block.html",
     "posts_block.html",
     "top_commenters_block.html",
     "top_likers_block.html",
     "top_commented_posts.html",
     "top_liked_posts.html"
]

blocks.each do |block|
     block_ = File.new(block, 'w')
     block_.puts init_msg
end

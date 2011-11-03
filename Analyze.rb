#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'builder'

posts_dates_record   = Hash.new
comments_dates_record = Hash.new

likers_record = Hash.new
commenters_record = Hash.new
like_per_post = Hash.new
comment_per_post = Hash.new
commenters_badges = Hash.new
commenters_badges['1'] = "label important"
commenters_badges['2'] = "label notice"
commenters_badges['3'] = "label notice"
commenters_badges['4'] = "label Default"
commenters_badges['5'] = "label Default"

likers_badges = Hash.new
likers_badges['1'] = "label success"
likers_badges['2'] = "label warning"
likers_badges['3'] = "label warning"
likers_badges['4'] = "label Default"
likers_badges['5'] = "label Default"

rankes = Array.new
rankes[1] = "Top"
rankes[2] = "2nd"
rankes[3] = "3rd"
rankes[4] = "4th"
rankes[5] = "5th"

#------------------------
likes_limit_for_post = 30
comments_limit_for_post = 30
likes_limit_for_follower = 20
comments_limit_for_follower = 20
#------------------------
total_likes = 0
total_comments = 0
#------------------------

posts = Array.new

#------------------------
months = Array.new
years  = Array.new

years  = ["2010","2011"]
months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

#-----------------------

posts = Dir.entries("./buzz")
posts_num = 0

posts.each do |post|

     if post == "." || post == ".."
         next
     end

     posts_num += 1

     doc = Nokogiri::HTML(File.open("./buzz/"+post.to_s))

     likers = doc.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "vcard", " " )) and contains(concat( " ", @class, " " ), concat( " ", "url", " " ))]//*[contains(concat( " ", @class, " " ), concat( " ", "fn", " " ))]')

     post_date = doc.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "activity", " " ))]//*[contains(concat( " ", @class, " " ), concat( " ", "updated", " " ))]')

     comments_dates = doc.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "comment", " " ))]//*[contains(concat( " ", @class, " " ), concat( " ", "updated", " " ))]')

     if comments_dates.size != 0
          comments_dates.each  do |comment_date|
               month = comment_date.text.split(',')[0].split(' ')[0].strip
               year = comment_date.text.split(',')[1].strip
               if comments_dates_record.has_key? year + month
                    comments_dates_record[year + month] += 1
               else
                    comments_dates_record[year + month] = 1
               end

          end
     end


    month = post_date.text.split(',')[0].split(' ')[0].strip
    year = post_date.text.split(',')[1].strip

     if posts_dates_record.has_key? year + month
          posts_dates_record[year + month] += 1
     else
          posts_dates_record[year + month] = 1
     end

     likers.each do |liker|

          liker = liker.text.strip

          if likers_record.has_key? liker
               likers_record[liker] += 1
          else
               likers_record[liker] = 1
          end

           if like_per_post.has_key? post
               like_per_post[post] += 1
          else
               like_per_post[post] = 1
          end
          total_likes += 1
     end

     commenters = doc.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "comment", " " ))]//*[contains(concat( " ", @class, " " ), concat( " ", "fn", " " ))]')

     commenters.each do |commenter|

          commenter = commenter.text.strip

          if   commenters_record.has_key? commenter
               commenters_record[commenter] += 1
          else
               commenters_record[commenter] = 1
          end

           if  comment_per_post.has_key? post
               comment_per_post[post] += 1
          else
               comment_per_post[post] = 1
          end
          total_comments += 1
     end

end

####################################################################################################
style = "<link href=\"../boot/bootstrap.css\" rel=\"stylesheet\">"

block = File.new("blocks/top_commenters_block.html", 'w')

block.puts style

commenters_record__ = commenters_record.sort{|value , key| key[1]<=>value[1]}

index = 1
commenters_record__.each do |commenter , num|
     xm = Builder::XmlMarkup.new(:indent => 2)
     xm.div("class"=>"well") {
          xm.img("src"=>"buzz.png", "width"=>"35", "height"=>"35", "align"=>"middle")
          xm.b(commenter)
          xm.br
          xm.text "#{commenters_record[commenter]} Comments"
          xm.br
          xm.span("class"=>"#{commenters_badges[index.to_s]}"){xm.text "#{rankes[index]} Commenter"}
          index += 1
     }
          block.puts xm.div
          if index == 6
               break
          end
end
################################################
block = File.new("blocks/top_likers_block.html", 'w')


block.puts style

likers_record__ = likers_record.sort{|value , key| key[1]<=>value[1]}

index = 1
likers_record__.each do |liker , num|
     xm = Builder::XmlMarkup.new(:indent => 2)
     xm.div("class"=>"well") {
          xm.img("src"=>"buzz.png", "width"=>"35", "height"=>"35", "align"=>"middle")
          xm.b(liker)
          xm.br
          xm.text "#{likers_record[liker]} Likes"
          xm.br
          xm.span("class"=>"#{likers_badges[index.to_s]}"){xm.text "#{rankes[index]} Liker"}
          index += 1
     }
          block.puts xm.div
          if index == 6
               break
          end
end
################################################
style = "<link href=\"../boot/bootstrap.css\" rel=\"stylesheet\">"

block_1 = File.new("blocks/followers_block_1.html", 'w')
block_2 = File.new("blocks/followers_block_2.html", 'w')

block_1.puts style
block_2.puts style

active_followers_record = Hash.new

active_followers_record = likers_record
active_followers_record = active_followers_record.merge(commenters_record)
active_followers_record = active_followers_record.sort_by{|key , value| key}

flag = 1

active_followers_record.each do |follower , num|

if flag == 1

xm = Builder::XmlMarkup.new(:indent => 2)
     xm.div("class"=>"well") {
          xm.img("src"=>"buzz.png", "width"=>"35", "height"=>"35", "align"=>"middle")
          xm.b(follower)
          xm.br
          if likers_record.has_key? follower
               xm.text "#{likers_record[follower]} Likes, "
          else
               xm.text "0 Likes, "
          end

          if commenters_record.has_key? follower
               xm.text "#{commenters_record[follower]} Comments"
          else
               xm.text "0 Comments"
          end

          xm.br
     }
          block_1.puts xm.div

flag = 0

elsif flag == 0

xm = Builder::XmlMarkup.new(:indent => 2)
     xm.div("class"=>"well") {
          xm.img("src"=>"buzz.png", "width"=>"35", "height"=>"35", "align"=>"middle")
          xm.b(follower)
          xm.br
          if likers_record.has_key? follower
               xm.text "#{likers_record[follower]} Likes, "
          else
               xm.text "0 Likes, "
          end

          if commenters_record.has_key? follower
               xm.text "#{commenters_record[follower]} Comments"
          else
               xm.text "0 Comments"
          end


          xm.br
     }
          block_2.puts xm.div

flag = 1
end
end
################################################
style = "<link href=\"../boot/bootstrap.css\" rel=\"stylesheet\">"

block = File.new("blocks/posts_block.html", 'w')
block.puts style

xm = Builder::XmlMarkup.new(:indent => 2)
xm.table("class" => "zebra-striped"){

     xm.thead{
          xm.tr{
               xm.th{
                    xm.text "."
               }
               years.each do |year|
                    xm.th{
                              xm.text "#{year}"
                         }
               end
               xm.th{xm.text "Total"}
               }
          }

     xm.tbody{
          total_in_2010 = 0
          total_in_2011 = 0

          months.each do |month|
               xm.tr{
                    total_per_month = 0
                    xm.td {xm.text "#{month}"}
                    years.each do |year|
                         temp = 0
                         if posts_dates_record.has_key? year+month
                              temp = posts_dates_record[year+month]
                         end
                         total_per_month += temp
                         if year == "2010"
                              total_in_2010 += temp
                         elsif year == "2011"
                              total_in_2011 += temp
                         end
                         xm.td {xm.text "#{temp}"}
                    end
                    xm.td { xm.text "#{total_per_month}" }
               }
          end
          xm.tr{
               @total_posts = total_in_2010 + total_in_2011
               xm.td{ xm.b "Total"}
               xm.td{ xm.text "#{total_in_2010}"}
               xm.td{ xm.text "#{total_in_2011}"}
               xm.td{ xm.b "#{@total_posts}"}
          }
     }
}
block.puts "#{xm.table}"
################################################
style = "<link href=\"../boot/bootstrap.css\" rel=\"stylesheet\">"

block = File.new("blocks/comments_block.html", 'w')
block.puts style

xm = Builder::XmlMarkup.new(:indent => 2)
xm.table("class" => "zebra-striped"){

     xm.thead{
          xm.tr{
               xm.th{
                    xm.text "."
               }
               years.each do |year|
                    xm.th{
                              xm.text "#{year}"
                         }
               end
               xm.th{xm.text "Total"}
               }
          }

     xm.tbody{
          total_in_2010 = 0
          total_in_2011 = 0

          months.each do |month|
               xm.tr{
                    total_per_month = 0
                    xm.td {xm.text "#{month}"}
                    years.each do |year|
                         temp = 0
                         if comments_dates_record.has_key? year+month
                              temp = comments_dates_record[year+month]
                         end
                         total_per_month += temp
                         if year == "2010"
                              total_in_2010 += temp
                         elsif year == "2011"
                              total_in_2011 += temp
                         end
                         xm.td {xm.text "#{temp}"}
                    end
                    xm.td { xm.text "#{total_per_month}" }
               }
          end
          xm.tr{
               total_comments = total_in_2010 + total_in_2011
               xm.td{ xm.b "Total"}
               xm.td{ xm.text "#{total_in_2010}"}
               xm.td{ xm.text "#{total_in_2011}"}
               xm.td{ xm.b "#{total_comments}"}
          }
     }
}
block.puts "#{xm.table}"
################################################
style = "<link href=\"../boot/bootstrap.css\" rel=\"stylesheet\">"

block_ = File.new("blocks/numbers_block.html", 'w')
block_.puts style

xm = Builder::XmlMarkup.new(:indent => 2)
xm.ul{
     xm.li{ xm.text "Total Likes : #{total_likes}"}
     xm.li{ xm.text "Total Comments : #{total_comments}"}
     xm.li{ xm.text "Total Posts : #{@total_posts}"}
     avg_likes = total_likes/@total_posts
     avg_comments = total_comments/@total_posts
     xm.li{ xm.text "Average Like/Post : #{avg_likes}"}
     xm.li{ xm.text "Average Comment/Post : #{avg_comments}"}
}
block_.puts  "#{xm.ul}"
################################################
style = "<link href=\"../boot/bootstrap.css\" rel=\"stylesheet\">"

block = File.new("blocks/top_liked_posts.html", 'w')
block.puts style


like_per_post = like_per_post.sort{|value , key| key[1]<=>value[1]}

xm = Builder::XmlMarkup.new(:indent => 2)
index = 0

like_per_post.each do |post,value|

     xm.iframe("src"=>"../buzz/#{post}","frameborder"=>"0", "scrolling"=>"yes", "class"=>"span11"){}

     index +=1

     if index == 5
          break
     end
end
block.puts "#{xm.br}"
################################################
style = "<link href=\"../boot/bootstrap.css\" rel=\"stylesheet\">"

block = File.new("blocks/top_commented_posts.html", 'w')
block.puts style


comment_per_post = comment_per_post.sort{|value , key| key[1]<=>value[1]}

xm = Builder::XmlMarkup.new(:indent => 2)
index = 0

comment_per_post.each do |post,value|

     xm.iframe("src"=>"../buzz/#{post}","frameborder"=>"0", "scrolling"=>"yes", "class"=>"span11"){}

     index +=1

     if index == 5
          break
     end
end
block.puts "#{xm.br}"

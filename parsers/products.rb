# Parsing elemen2 di halaman produk
nokogiri = Nokogiri.HTML(content)

# initialize an empty hash
product = {}

#save the url
product['url'] = page['vars']['url']

#save the category
product['category'] = page['vars']['category']

#extract the asin
asin_path = 'link[rel=canonical]'
product['asin'] = "" # Just in case kalo kosong
canonical_link = nokogiri.at_css(asin_path)["href"] unless nokogiri.at_css(asin_path).nil? 
unless canonical_link.nil?
    product['asin'] = canonical_link.split("/").last
end

#extract title
product['title'] = ""
product['title'] = nokogiri.at_css('span#productTitle').text.strip unless nokogiri.at_css('span#productTitle').nil?

#extract seller/author
product['seller'] = ""
product['author'] = ""

seller_node = nokogiri.at_css('a#bylineInfo')
if seller_node
  product['seller'] = seller_node.text.strip
else
  product['author'] = nokogiri.css('a.contributorNameID').text.strip
end

#extract number of reviews
product['reviews_count'] = ""
reviews_node = nokogiri.at_css('span#acrCustomerReviewText') # ambil node
reviews_count = reviews_node ? reviews_node.text.strip.split(' ').first.gsub(',','') : nil #kalo ada valuenya kita ambil angkanya, kalo ga ada pasang nil
product['reviews_count'] = reviews_count =~ /^[0-9]*$/ ? reviews_count.to_i : 0 # kalo ga ada angka atau format bukan angka, kita pasang 0

#extract rating, valuenya float
rating_node = nokogiri.at_css('#averageCustomerReviews span.a-icon-alt') #cari node rating
stars_num = rating_node ? rating_node.text.strip.split(' ').first : nil # kalo ketemu nodenya, ambil kata pertama
product['rating'] = stars_num =~ /^[0-9.]*$/ ? stars_num.to_f : nil # kalo kata pertamanya bukan angka, pasang nil

#extract price
price_node = nokogiri.at_css('input#attach-base-product-price') #cari node
if price_node #kalo ketemu edit stringnya
    product['price'] = price_node["value"].strip.gsub(/[\$,]/,'').to_f
else
    product['price'] = nil #case kalo ga ketemu samsek
end

#extract availability, formatnya boolean
availability_node = nokogiri.at_css('#availability') #cari node dlu
# cek ketemu/tidak nodenya
if availability_node
    # Kalo ketemu, Jika in stock pasang true
    product['available'] = availability_node.text.strip == 'In Stock.' ? true : false
else
    product['available'] = nil
end

#extract product description
description = ''
nokogiri.css('#feature-bullets li').each do |li|
  unless li['id'] || (li['class'] && li['class'] != 'showHiddenFeatureBullets')
    description += li.text.strip + ' '
  end
end
product['description'] = description.strip

# specify the collection where this record will be stored
product['_collection'] = "products"

# save the product to the job’s outputs
outputs << product
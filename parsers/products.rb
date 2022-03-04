# Parsing elemen2 di halaman produk
nokogiri = Nokogiri.HTML(content)

# initialize an empty hash
product = {}

#save the url
product['url'] = page['vars']['url']

#save the category
product['category'] = page['vars']['category']

#extract the asin
product['asin'] = ""
# canonical_link = nokogiri.at_css('head > link:nth-child(22)').find{|link| link.attributes['rel'].value.strip == 'canonical' }
canonical_link = nokogiri.at_css('head > link:nth-child(22)')
product['asin'] = canonical_link
# unless canonical_link.nil?
#     product['asin'] = canonical_link.split("/").last
# end

# specify the collection where this record will be stored
product['_collection'] = "products"

# save the product to the job’s outputs
outputs << product
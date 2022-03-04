nokogiri = Nokogiri.HTML(content)

# Cari link semua produk di halaman
products = nokogiri.css('div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > h2:nth-child(1) > a:nth-child(1)')
products.each do |product|
    url = "https://www.amazon.com" + product['href']
    pages << {
          url: url,
          page_type: 'products',
          vars: {
            category: page['vars']['category'],
            url: url
          },
          fetch_type: "browser"
    }
end

# cari link halaman selanjutnya
indeks = page['vars']['i']
next_url_ref = nokogiri.at_css('a.s-pagination-item.s-pagination-next.s-pagination-button.s-pagination-separator')["href"] unless nokogiri.css('a.s-pagination-item.s-pagination-next.s-pagination-button.s-pagination-separator').nil?


next_url = "https://www.amazon.com" + next_url_ref
indeks += 1 # increment indeks, ke halaman selanjutnya

if indeks < 6 # ambil 5 halaman dulu
    pages << {
        page_type: "listings",
        method: "GET",
        headers: {"User-Agent" => "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36"},
        url: next_url,
        vars: {
            category: "LED & LCD TVs",
            "i" => indeks 
        },
        fetch_type: "browser"
    }
end
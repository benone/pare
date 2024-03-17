require './book'
require './chapter'
require './proxy_manager'

# book_slug = "21-days-to-a-big-idea-en"
# book = Book.new(book_slug)

# book_slug = "21-days-to-a-big-idea-en"
# get_full_book_data(book_slug)
SLEEP = 0

PM = ProxyManager.from_base_url

FileUtils.rm_f("info.log")

slugs = File.read("slugs.txt").split("\n")
slugs.each do |slug|
  book = Book.new(slug)
  puts slug
  book.get_full_data
end

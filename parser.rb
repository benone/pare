require 'json'
require 'fileutils'

def get_book_data(book_slug)
  request = <<-EOF
    curl 'https://www.blinkist.com/api/books/#{book_slug}/chapters' \
    -H 'authority: www.blinkist.com' \
    -H 'accept: application/json, */*' \
    -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8,ru;q=0.7' \
    -H 'cookie: locale=en; CookieConsent={stamp:%27K/jRzgyJlgrM+VRQVPgiGQk5/AVyxX30+M7eywQWyHYj9e27dSfoFA==%27%2Cnecessary:true%2Cpreferences:true%2Cstatistics:true%2Cmarketing:true%2Cmethod:%27explicit%27%2Cver:1%2Cutc:1710538153326%2Cregion:%27es%27}; FPC=397f9646-8f98-4383-8f17-737ec0b37387; _gcl_au=1.1.916310431.1710538154; _fbp=fb.1.1710538153644.224978218; _gid=GA1.2.471965380.1710538154; _tt_enable_cookie=1; _ttp=1jk0rE0y5lBkZOjb8XTgUhw0C8D; ab.storage.deviceId.79ac57d2-eeda-4fc1-82c8-307cedf36a5f=%7B%22g%22%3A%221b70e281-8d98-d76a-715e-6fcf47de1976%22%2C%22c%22%3A1710538153838%2C%22l%22%3A1710538153838%7D; __pdst=255b8dfeb83e4640b65e4408e2af3daf; _scid=659cccc7-d6e6-4ed7-b4c1-abfb628cd7cd; _pin_unauth=dWlkPU56SmhNR0prWW1RdFlqWmxNUzAwTmpZMkxXSTVObVF0WlRObU5qWmtOalpqTVRnNQ; _dcmn_p=NkWOY2lkPVh4eVd2MlgwdmFuSDYyOGFBN0E; _dcmn_p=NkWOY2lkPVh4eVd2MlgwdmFuSDYyOGFBN0E; _dcmn_p=NkWOY2lkPVh4eVd2MlgwdmFuSDYyOGFBN0E; _hjSession_280033=eyJpZCI6IjYzYzU0OThiLTE5MDctNGEyOC1hODNkLTBhMzFhNTkxYWQ3NCIsImMiOjE3MTA1MzgxNTQxMjUsInMiOjAsInIiOjAsInNiIjowLCJzciI6MCwic2UiOjAsImZzIjoxLCJzcCI6MH0=; _hjHasCachedUserAttributes=true; dicbo_id=%7B%22dicbo_fetch%22%3A1710538154434%7D; visitor_id896901=822443190; visitor_id896901-hash=c76061a22b32bb18ca821dcd6f6b355094e123b3c869d1daf827356c424cf9b03c3ff13f12e768c0350eaf9ce1b8442bb1a7d090; timezone=Europe%2FBerlin; G_ENABLED_IDPS=google; _pk_ses.1.a1f5=1; _hjSessionUser_280033=eyJpZCI6ImEwNzgwNjA2LWNmMTctNTNkZC1iZThmLTc5YjRlYzJmN2I2NiIsImNyZWF0ZWQiOjE3MTA1MzgxNTQxMjUsImV4aXN0aW5nIjp0cnVlfQ==; bk_c_n=78809766-25ad-4231-8fd1-cd52f07dba9f; internal_session=true; _gat_UA-34503481-1=1; __cf_bm=agM930tZbFcUSeU9RshifIFDnzowddQ6_2DC3wJrmfw-1710538367-1.0.1.1-eztURdV6kRmXC7_uAJZdjbDZIEMznZ8oHkcdedmkQ8iUppKPOOItaTbI5Jwk.SrQ0z8fXxzJT6__g9_4ioxoummVjxRFHDu2eJHcO0xqH3U; _cfuvid=sETjXMdJdFNBq7gpjHQb3Du1Xuvpl7C5vExNH9P6av8-1710538367114-0.0.1.1-604800000; cf_clearance=0Dd6YPWdjVFgxucrF8JkPajYVsPCiMb0mq5PXVqnJaU-1710538367-1.0.1.1-cWPY0wReZl5Aox8lcl.gAXfRh_TNmvL_OxY.G7LFvWnYMIqwF9Vd9TjN.Ipz7xB5KRXz90i_dRXQNp19B_nwuQ; _dd_s=rum=1&id=10710a33-2e5d-4d60-8601-820948db6775&created=1710538150666&expire=1710539274584; ab.storage.sessionId.79ac57d2-eeda-4fc1-82c8-307cedf36a5f=%7B%22g%22%3A%220717ea80-5319-4668-7868-c25823f7dc11%22%2C%22e%22%3A1710540175848%2C%22c%22%3A1710538153837%2C%22l%22%3A1710538375848%7D; _uetsid=11c7be60e31311eeb399b9838c3b6fb8; _uetvid=11c7ec40e31311ee96b9117792f331cd; _rdt_uuid=1710538153722.7d8298db-bc8d-4e4b-8f44-0990ee68f1f7; _blinkist-webapp_session=UkJYZGo4cEJaS3pKWWNsSzJvRGpyRTAreTVMdUtjc09LM1BhSlVEZVBYUVV0eXlxSngvV2NIL3Y5RzVheS9CRWw4SkdJbUF4NTR1YVNwWE1GVHI2VTErZDZJejN4ck5IZ0NqU1BsdXlnTEJmczRSdEh5bjlpNVdqRS9LdVJtWmNLd1ZaYSttZnM1a1hPOENGV3lEampWRzVHUjFmM2lraGZyUnNzZE41K0hEd0p6VFVhSTUweWpCeU9FMUo5TzJCYlN3K1UyRWxpTkkwNGp2aFk0YjlwVUVyTndlbWY1aWVOMGNjaFVGMmpyWmJ1MUxxazVSallNSlVqZTJqOHU5YTEwd1JwU0VYN01Ga2FkemxSeVlYeXNZcVpwSHBVcWJpSjNmRFVDazdKMm5keGJtbnJWaDNPblBSdktTZmVQK2tYNXUxOFRJNi90MWN2SGNQNGN4WnAxMmFvTnBLbzhXbGRrdUtyK0FBYkQ3Unl4T1NDRm4zMTFGTnlOVU94TDJXWVNITmlPQSs0cEZLOEllMlRnbWtpdzVSaGhJVGR0SEVuZzd2TlkzN1QzdjFwUC91amVnM25RcXRBa1l1VXVZeUtFb3I2RXZwWkJCQUJJUUI5U1lSUHRER21wMXI0U1BnMHZGTU5BY2lJQTVYeVFLMy9JZ2w0R3ludFdhWWtiVWRjMmNGSDlHMFdSYkg0ZWdEajZZUHdWR0JYL3NoSkR6dDQxd29hS2E4eE9yYXBvZDA5cFgxRng5UXpySHZUZktJZFdmcmpMNzFCT2YrZEZMNHZTNFdyTHlCeVRpMkpvazBXeWNJOVR2Z3U3dEFvR0RSZXFteFd4Ym9wbjVnSDNLSUV5QlorM3Z4S1pxNkh5dVA5L1puVlFVMEx1TGY1Uy9TdVJSRGc3ZGYwWlYyODU4ZlFuaU9lTWk1KysydlVLQ1BIaTJJZFVMZzJXOHJFR3hzQjlwdUgvU1pOUjRjOU9ZK0g1QkZ1NnZHQWdJPS0tNHZDWm1nemhmWDEzVVBkVW1ZQ0xLQT09--29e00d1e7a34135c1929397855da6e322e3ff63b; _tq_id.TV-63729036-1.258b=3d725966394df301.1710538154.0.1710538376..; _scid_r=659cccc7-d6e6-4ed7-b4c1-abfb628cd7cd; _ga=GA1.1.1031598140.1710538154; _dcmn_su4ivnelbvvjf=ym0kc2lkPWJrV0N4bVgwdmFuSDYyOGFBN0UmZXhwPXNhZXQ4eA; _dcmn_su4ivnelbvvjf=ym0kc2lkPWJrV0N4bVgwdmFuSDYyOGFBN0UmZXhwPXNhZXQ4eA; _dcmn_su4ivnelbvvjf=ym0kc2lkPWJrV0N4bVgwdmFuSDYyOGFBN0UmZXhwPXNhZXQ4eA; _ga_1NWHFHB0BN=GS1.1.1710538153.1.1.1710538376.0.0.0; _pk_id.1.a1f5=a96d746806e001e0.1710538163.1.1710538376.1710538163.' \
    -H 'referer: https://www.blinkist.com/en/nc/reader/12-rules-for-life-en' \
    -H 'user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36' \
    -H 'x-csrf-token: NZrdienNhRYtP4Cjelg5k30BHqZcljrZ/qLdwDm66LyCx7hkNBCRkyXojuKbcGLEHB0BjYpXM/yVysSleqgLlA==' \
    -H 'x-requested-with: XMLHttpRequest'
  EOF
  response = JSON.parse(`#{request}`)
  response
end

def get_chapter(book_id, chapter_id)
  request = <<-EOF
    curl 'https://www.blinkist.com/api/books/#{book_id}/chapters/#{chapter_id}' \
    -H 'authority: www.blinkist.com' \
    -H 'accept: application/json, */*' \
    -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8,ru;q=0.7' \
    -H 'cookie: locale=en; CookieConsent={stamp:%27K/jRzgyJlgrM+VRQVPgiGQk5/AVyxX30+M7eywQWyHYj9e27dSfoFA==%27%2Cnecessary:true%2Cpreferences:true%2Cstatistics:true%2Cmarketing:true%2Cmethod:%27explicit%27%2Cver:1%2Cutc:1710538153326%2Cregion:%27es%27}; FPC=397f9646-8f98-4383-8f17-737ec0b37387; _gcl_au=1.1.916310431.1710538154; _fbp=fb.1.1710538153644.224978218; _gid=GA1.2.471965380.1710538154; _tt_enable_cookie=1; _ttp=1jk0rE0y5lBkZOjb8XTgUhw0C8D; ab.storage.deviceId.79ac57d2-eeda-4fc1-82c8-307cedf36a5f=%7B%22g%22%3A%221b70e281-8d98-d76a-715e-6fcf47de1976%22%2C%22c%22%3A1710538153838%2C%22l%22%3A1710538153838%7D; __pdst=255b8dfeb83e4640b65e4408e2af3daf; _scid=659cccc7-d6e6-4ed7-b4c1-abfb628cd7cd; _pin_unauth=dWlkPU56SmhNR0prWW1RdFlqWmxNUzAwTmpZMkxXSTVObVF0WlRObU5qWmtOalpqTVRnNQ; _dcmn_p=NkWOY2lkPVh4eVd2MlgwdmFuSDYyOGFBN0E; _dcmn_p=NkWOY2lkPVh4eVd2MlgwdmFuSDYyOGFBN0E; _dcmn_p=NkWOY2lkPVh4eVd2MlgwdmFuSDYyOGFBN0E; _hjSession_280033=eyJpZCI6IjYzYzU0OThiLTE5MDctNGEyOC1hODNkLTBhMzFhNTkxYWQ3NCIsImMiOjE3MTA1MzgxNTQxMjUsInMiOjAsInIiOjAsInNiIjowLCJzciI6MCwic2UiOjAsImZzIjoxLCJzcCI6MH0=; _hjHasCachedUserAttributes=true; visitor_id896901=822443190; visitor_id896901-hash=c76061a22b32bb18ca821dcd6f6b355094e123b3c869d1daf827356c424cf9b03c3ff13f12e768c0350eaf9ce1b8442bb1a7d090; timezone=Europe%2FBerlin; G_ENABLED_IDPS=google; _pk_ses.1.a1f5=1; _hjSessionUser_280033=eyJpZCI6ImEwNzgwNjA2LWNmMTctNTNkZC1iZThmLTc5YjRlYzJmN2I2NiIsImNyZWF0ZWQiOjE3MTA1MzgxNTQxMjUsImV4aXN0aW5nIjp0cnVlfQ==; bk_c_n=78809766-25ad-4231-8fd1-cd52f07dba9f; internal_session=true; __cf_bm=agM930tZbFcUSeU9RshifIFDnzowddQ6_2DC3wJrmfw-1710538367-1.0.1.1-eztURdV6kRmXC7_uAJZdjbDZIEMznZ8oHkcdedmkQ8iUppKPOOItaTbI5Jwk.SrQ0z8fXxzJT6__g9_4ioxoummVjxRFHDu2eJHcO0xqH3U; _cfuvid=sETjXMdJdFNBq7gpjHQb3Du1Xuvpl7C5vExNH9P6av8-1710538367114-0.0.1.1-604800000; cf_clearance=0Dd6YPWdjVFgxucrF8JkPajYVsPCiMb0mq5PXVqnJaU-1710538367-1.0.1.1-cWPY0wReZl5Aox8lcl.gAXfRh_TNmvL_OxY.G7LFvWnYMIqwF9Vd9TjN.Ipz7xB5KRXz90i_dRXQNp19B_nwuQ; _dd_s=rum=1&id=10710a33-2e5d-4d60-8601-820948db6775&created=1710538150666&expire=1710539274584; ab.storage.sessionId.79ac57d2-eeda-4fc1-82c8-307cedf36a5f=%7B%22g%22%3A%220717ea80-5319-4668-7868-c25823f7dc11%22%2C%22e%22%3A1710540175848%2C%22c%22%3A1710538153837%2C%22l%22%3A1710538375848%7D; _uetsid=11c7be60e31311eeb399b9838c3b6fb8; _uetvid=11c7ec40e31311ee96b9117792f331cd; _rdt_uuid=1710538153722.7d8298db-bc8d-4e4b-8f44-0990ee68f1f7; _tq_id.TV-63729036-1.258b=3d725966394df301.1710538154.0.1710538376..; _scid_r=659cccc7-d6e6-4ed7-b4c1-abfb628cd7cd; _ga=GA1.1.1031598140.1710538154; _dcmn_su4ivnelbvvjf=ym0kc2lkPWJrV0N4bVgwdmFuSDYyOGFBN0UmZXhwPXNhZXQ4eA; _dcmn_su4ivnelbvvjf=ym0kc2lkPWJrV0N4bVgwdmFuSDYyOGFBN0UmZXhwPXNhZXQ4eA; _dcmn_su4ivnelbvvjf=ym0kc2lkPWJrV0N4bVgwdmFuSDYyOGFBN0UmZXhwPXNhZXQ4eA; _ga_1NWHFHB0BN=GS1.1.1710538153.1.1.1710538376.0.0.0; _blinkist-webapp_session=VEpMOVA0R0VScW9KUkRJMWxVc2RGUnI5UkN4WE5KR0xPazJ0YzFvTDdHU0N6clRDdzlva0V1dUcvWnl2Qkh0VmlyV3E2cUJHYVV1V2I0cmdwQUxiTzBLcjdRRWp6VVUvNWY3UDhsY2kwVEpxeFoyeVpzZnlUc0M2bktYTHJDZEpodkhybmhiUWcyQzVFSWc5S1JGbGdDcTdENndGTjJkZ2pHa295WlhrNDhaUy8vZ1IvaXFwRk5YY3RSdWZLOHQxbW1UQ1ltd1UxeGxPN0ZxZExNUkZYQ0hzMEJVR2xzYndzU0l2aFFiY01yL3ZUSTBCQnN6NElBZHBzMDduU1lOOGZ0ZXBPYlQ4dXhSUTR2Vi9EYjZMd2ozZitpQ3dPVEZ5Qk9Gc2JkUDlMUmY5OVRoeTFzUzVyTm5pK2I5cjJ3MFN1d0dOcjhaMGc0Ymx2WWxhQkR2eGJFOCs1S0VrQTFXTVVVSCtjdVU5WDAzQTd6UDUxbUZIMWkraG5QaU9XZE5BTXNiQzZmRzk5SVl1Mm5jSFphMkw5cXQ4NXQ4MG1QTW9Va241UkFYb1NwV3FxQzcyOWpEaHc3T09hY05wc2hmS3RuN2hFTS9ra0tqKzZIT1pad0VBaGxEOFZRYS9mOW1LY2g0QlV2TlNBa3YwdmdMR1lnOUFBR0ZseEtsUC85eGhoUWI0SFV4NHpxT3VCdjVIZkh0VzZpR0NxbkVpbXg5bzgwMjEzMGpmT1YvM1RNRmlMeGgwUlpndnBTNHFETmdtVzlzK3kxY09kV2JQeGs4WkxyM3ZTNW9JQUJSYXgyenFDVEsvN0QzaCs1ZzlpYnQzcWxBQktuY1Qzc2lTa1RYTjVBaTFnSk9HQzJsNXpXVFNaeU9oTVU2eHBvajJtT2lhRENzZzFiSXdQNG5xazRHeTcrY21GcTRaSy9qZzEvUElhK3U0a2svL28zdUpNU09nZHJDME1ZWHVmRjNqSWovaTlZeDJIc0hQMHg4PS0tekJUd0R2ejJLMXd4ZUtPelJMaWMwUT09--47077f60d8001eedf78073cbcef684de6f05c32f; _pk_id.1.a1f5=a96d746806e001e0.1710538163.1.1710538531.1710538163.' \
    -H 'referer: https://www.blinkist.com/en/nc/reader/12-rules-for-life-en' \
    -H 'user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36' \
    -H 'x-csrf-token: NZrdienNhRYtP4Cjelg5k30BHqZcljrZ/qLdwDm66LyCx7hkNBCRkyXojuKbcGLEHB0BjYpXM/yVysSleqgLlA==' \
    -H 'x-requested-with: XMLHttpRequest'
  EOF
  response = JSON.parse(`#{request}`)
  response
end


def get_full_book_data(book_slug)
  FileUtils.mkdir_p("data/#{book_slug}")
  book_data = get_book_data(book_slug)
  book_id = book_data['book']['id']
  book_data['chapters'].each do |chapter_data|
    chapter_id = chapter_data['id']
    chapter_info = get_chapter(book_id, chapter_id)
    File.write("data/#{book_slug}/#{chapter_id}.json", JSON.pretty_generate(chapter_info))
    puts chapter_info
    sleep 5
  end
  File.write("data/#{book_slug}/book.json", JSON.pretty_generate(book_data))
end

book_slug = "21-days-to-a-big-idea-en"
get_full_book_data(book_slug)


slugs = File.read("slugs.txt").split("\n")
slugs.each do |slug|
  next if slug.strip.empty?
  next if File.exist?("data/#{slug}/book.json")
  get_full_book_data(slug)
  sleep 5
end

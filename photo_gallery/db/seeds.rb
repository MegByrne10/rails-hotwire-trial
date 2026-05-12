require "csv"

puts "== Seeding users =="

reviewer = User.find_or_create_by!(email: "reviewer@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
end

sample_users = (1..4).map do |n|
  User.find_or_create_by!(email: "user#{n}@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
end

puts "Reviewer login: #{reviewer.email} / password123"

csv_path = Rails.root.parent.join("photos.csv")
unless File.exist?(csv_path)
  raise <<~MSG
    Missing photos.csv at #{csv_path}.
    Copy the challenge CSV into your app root and run:
      bin/rails db:seed
  MSG
end

puts "== Seeding photos from photos.csv =="

rows = CSV.read(csv_path, headers: true)
fetch = lambda do |row, *keys|
  keys.each do |key|
    value = row[key]
    return value.to_s.strip if value.present?
  end
  nil
end

created_or_updated = 0
skipped = 0

rows.each_with_index do |row, i|
  photographer_name = fetch.call(row, "photographer")
  source_md_url = fetch.call(row, "src.medium")
  source_url = fetch.call(row, "url")
  alt = fetch.call(row, "alt")
  if [ photographer_name, source_md_url, source_url ].any?(&:blank?)
    skipped += 1
    puts "Skipping row #{i + 1}: missing required data"
    next
  end

  photo = Photo.find_or_initialize_by(
    photographer_name: photographer_name,
    source_md_url: source_md_url,
    source_url: source_url,
    alt: alt
  )
  if photo.new_record? || photo.changed?
    photo.save!
    created_or_updated += 1
  end
end

puts "Photos created/updated: #{created_or_updated}"
puts "Rows skipped: #{skipped}"
puts "== Seeding random likes for sample users =="

# Re-randomize likes for sample users on each seed run (reviewer unchanged)
Like.where(user_id: sample_users.map(&:id)).delete_all

all_photos = Photo.all
all_photos.each { |photo| Photo.reset_counters(photo.id, :likes_count) }
# Allways leaving one photo without likes to see a zero like count state
photo_without_likes = all_photos.sample
photos = all_photos - [photo_without_likes]

sample_users.each do |user|
  next if photos.empty?
  # Randomly like between 20% and 60% of photos per sample user
  count = rand((photos.size * 0.2).ceil..(photos.size * 0.6).ceil)
  photos.sample(count).each do |photo|
    Like.find_or_create_by!(user: user, photo: photo)
  end
end

puts "Total photos: #{Photo.count}"
puts "Total likes: #{Like.count}"
puts "== Done =="

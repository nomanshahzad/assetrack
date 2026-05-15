# Admin user — created once, idempotent on re-runs.
# Set credentials via environment variables before seeding:
#   ADMIN_EMAIL=you@example.com ADMIN_PASSWORD=yourpassword bin/rails db:seed
User.find_or_create_by!(email_address: "admin@example.com") do |user|
  user.password = "11111111"
end

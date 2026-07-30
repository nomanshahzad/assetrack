# Admin user — created once, idempotent on re-runs.
# Set credentials via environment variables before seeding:
#   ADMIN_EMAIL=you@example.com ADMIN_PASSWORD=yourpassword bin/rails db:seed
User.find_or_create_by!(email_address: ENV.fetch("ADMIN_EMAIL", "admin@example.com")) do |user|
  user.password = ENV.fetch("ADMIN_PASSWORD", "11111111")
end

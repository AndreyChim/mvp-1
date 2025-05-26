User.create!(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  admin: true
)

User.create!(
  email: "user1@example.com",
  password: "123456",
  password_confirmation: "123456")

User.create!(
  email: "user2@example.com",
  password: "1234567",
  password_confirmation: "1234567")
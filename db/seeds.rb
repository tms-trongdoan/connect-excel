User.create!([
  { name: 'Nguyễn Văn An', age: 28, email: 'nguyenvanan@example.com' },
  { name: 'Trần Thị Bình', age: 32, email: 'tranthibinh@example.com' },
  { name: 'Lê Hoàng Cường', age: 25, email: 'lehoangcuong@example.com' },
  { name: 'Phạm Thị Dung', age: 29, email: 'phamthidung@example.com' },
  { name: 'Vũ Minh Đức', age: 35, email: 'vuminhduc@example.com' },
  { name: 'Đặng Thị Em', age: 26, email: 'dangthiem@example.com' },
  { name: 'Hoàng Văn Phúc', age: 31, email: 'hoangvanphuc@example.com' },
  { name: 'Bùi Thị Giang', age: 27, email: 'buithigiang@example.com' },
  { name: 'Trương Minh Hiếu', age: 33, email: 'truongminhhieu@example.com' },
  { name: 'Lý Thị Hoa', age: 24, email: 'lythihoa@example.com' }
])

puts "Đã tạo #{User.count} người dùng"

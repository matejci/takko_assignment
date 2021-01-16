# frozen_string_literal: true

user = User.first_or_create!(email: 'brucelee@isp.net', name: 'Bruce', password: 'takko123', password_confirmation: 'takko123')
location = Location.first_or_create!(formatted_address: '892 ARLENE WAY, NOVATO, CA, USA',
                                     street_name: 'Arlene Way',
                                     town: 'Novato',
                                     state: 'California',
                                     country: 'USA',
                                     postal_code: '94947-6915',
                                     latitude: '38.07623797858075',
                                     longitude: '-122.55006206663573')

user.locations << location

puts 'Seed finished.'

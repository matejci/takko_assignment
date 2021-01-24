# frozen_string_literal: true

user = User.first_or_create!(email: 'user@isp.net',
                             name: 'User',
                             password: '1234',
                             password_confirmation: '1234',
                             api_token: "#{SecureRandom.urlsafe_base64}#{Digest::SHA1.hexdigest([Time.now, rand].join)}")

location = Location.first_or_create!(formatted_address: '892 ARLENE WAY, NOVATO, CA, USA',
                                     street_name: 'Arlene Way',
                                     town: 'Novato',
                                     state: 'California',
                                     country: 'USA',
                                     postal_code: '94947-6915',
                                     latitude: '38.07623797858075',
                                     longitude: '-122.55006206663573',
                                     location_type: 'seeded')

user.locations << location

puts 'Seed finished.'

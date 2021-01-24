# Takko App

- Upon logging in, user is asked to share his/her location.
- If location is denied, app will fallback to using address that is provided when registering (actual user registration is not implemented, but users are created through seed.rb script), unless search param are not typed.
- If location is allowed, system will record users' location and use that location when getting info about the restaurants.

- So, when searching for restaurants, we have following priority in regards of location:
  - 1) address/postcode that is provided on search form
  - 2) acquired location during login
  - 3) default location, provided when user was created

- Search results contains list of found restaurants, based on location, search term and users preferences (categories).

- As user interacts with search results, app is 'learning'/recording which categories user prefers and use those preferences in future search requests.

- For example, if user click on 'see more' link we gonna record that user is interested in categories that are loaded on that 'restaurant card'.
- On the other hand, if user clicks 'discard', we gonna record that user is not interested in categories displayed on that particular restaurant card.

- Later, when user initiate another search, we gonna calculate top 5 (number of categories can be configured with ENV var) categories that user prefers and pass that to Yelp service in order to get back places with those preferred categories. Note that, if category votes are negative (less than 0), we won't take those in consideration when passing 'categories' to Yelp service.

- User's api_token/'login session' is active for 1 hour.

## Requirements:
- Ruby version: 2.7.1
- Rails version: 6.0.3.2
- MongoDB version: 4.4
- ENV variables: GOOGLE_API_KEY, YELP_API_KEY

## How to run the app locally?
- Cd to app's directory.
- Install dependencies by running: `bundle install`
- Run `bin/rails db:seed` (to seed default data)
- Run `bin/rails server` (or `bundle exec puma -C config/puma.rb` if you want to use special server configuration)

## Deployment
- App is currently deployed on Heroku: https://takkoassignment.herokuapp.com/


## Tests
- bin/rails test

## API Docs
- https://documenter.getpostman.com/view/5727281/TW6tLqDx

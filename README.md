# Local Social Initiative 
Local Social Initiative is a Ruby on Rails-based REST API application with a PostgreSQL database. The app is designed to facilitate the organization and coordination of local events within your city. Inspired by platforms like Meetup.com, the app simplifies event management, enabling users to create, join, and engage with local community events easily. The app uses RSpec tests to make sure everything works correctly.

Features of the application:

1. User Management: The application allows users to sign up and log in. Users can set up their profile with their personal details and a profile picture.
2. Event Management: Users can create events and attend events created by other users. Events have a name, start date, end date, location, description, and a main photo. Users can see all the events they are attending.
3. Group Management: Users can create groups and become a member of existing groups. The groups can have a name, description, and an avatar. Users can see all the groups they are a member of.
4. Attendee Management: Users can join events as attendees. Users can have different roles in an event, such as an organizer,co-organizer or attendee. Users can see all the events they are attending and their role in each event.
5. Member Management: Users can become members of groups, allowing them to  follow the latest events related to the group. Members can view the groups they are a part of and their role within each group.
6. Photo Management: Users who are hosts or co-hosts of an event can upload photos for that event. Photos have a URL and are associated with a user and an event.
7. Tagging: Hosts of events can assign tags to his own events. Events can have multiple tags associated with them.
8.Tests: the application is equipped with comprehensive tests using the RSpec framework. These tests allow to verify the correctness of various functionalities of the application.

## Entity Relationship Diagram (ERD)
In the link below you will find the ER diagram of the database designed for this application. 
https://dbdiagram.io/d/6406f914296d97641d85fefd

## Examples of API responses
Below are examples of responses from endpoints.

## Installing

### Getting started

To run this project you need to have:

Ruby 2.7.4

Rails 6.1.7

PostgreSQL 13.8

### Setup the project
Clone the project:
``` bash
git clone https://github.com/SzymonB77/Local_social_initiative.git
```

Enter project folder:
``` bash
cd Charity_Fundraising_App
```

Next, configure your local database in config/database.yml file. Add your database username and password (unless you don't have any).

Install the gems:
``` bash
bundle install
```

Create and seed the database:
``` bash
rails db:create 
rails db:migrate
rails db:seed
```

### Running the project

Run Rails server:
```bash
rails server
```
Open http://localhost:3000

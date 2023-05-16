# Local Social Initiative 
**Local Social Initiative** is a REST API application based on **Ruby on Rails** with a **PostgreSQL** database. The app is designed to facilitate the organization and coordination of local events within your city. Inspired by platforms like Meetup.com, the app simplifies event management, enabling users to create, join, and engage with local community events easily. The app uses RSpec tests to make sure everything works correctly.

### Features of the application:

- **User Management:** Sign up, log in, and customize profiles.
- **Event Management:** Create and attend events with detailed information and registration.
- **Group Management:** Create and join groups with name, description, and member count.
- **Attendee Management:** Join events with different roles (organizer, co-organizer, attendee).
- **Member Management:** Join groups and view role and events within each group.
- **Photo Management:** Hosts and co-hosts upload event photos associated with users and events.
- **Tagging:** Assign tags to events.
- **Tests:** Comprehensive RSpec tests to ensure functionality.

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

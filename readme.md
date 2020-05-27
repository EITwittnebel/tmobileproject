# T-Mobile GitHub API Parser App

A sample project for displaying results from the GitHub API, done with an MVC architecture.


## Authors

* **John Wittnebel**


## Getting Started

Upon opening the app, there is a search bar and a button to log into your github account. The GitHub API is rate-limited
at a very small rate for unregistered API calls, so it is advised to login using your github credentials.


## Searching

Once text has been entered into the search field, a collection of github users with names corresponding to the input
search will be displayed, as well as their avatar and number of public repositories.


## Details Screen

If the user taps on a user from this table, then they will be brought to a new screen that shows additional details
about the specified user. In particular, it will show the number of users that they are following, number of followers,
as well as their email, location, and bio (if available). There will also be a list of public repositories from the
user, where each entry has the number of forks and stars of the corresponding repository. There is also a search feature
to search the public repositories of the user.


## Linkout

If a public repository is selected, then the app will open the GitHub page for that repository.


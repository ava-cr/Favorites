# Favorites

## Table of Contents
1. Final Product
    a. [Description](#Description)
    b. [Demo](#Demo)
    c. [Credits](#Credits)
    d. [License](#License)
2. Planning Stages
    a. [Overview](#Overview)
    b. [Product Spec](#Product-Spec)
    c. [Wireframes](#Wireframes)
    d. [Schema](#Schema)
    
## Final Product
Favorites is an iOS application inspired by the fact that friends visiting NYC are always asking me for recommendations of where to eat, drink, shop, etc. in the city. With Favorites, you can save all of your favorite locations to your personal map, add your friends, and see their maps and the updates they post from their locations (and add these locations to your own map to visit later). These are the basics, watch the demo for more details!

## Demo

Gif 1: Push Notifications, Map Tab
<img src='https://github.com/ava-cr/Favorites/blob/main/gifs/first30secs.gif' title='First' width='' alt='First' />

Full Demo:
<img src='https://github.com/ava-cr/Favorites/blob/main/gifs/appfull.mp4' title='Demo' width='' alt='Demo' />


## Credits

- 
    [DateTools](https://github.com/MatthewYork/DateTools#time-ago) - library to streamline date and time handling in iOS.
    
- 
    [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD) - activity monitor library
  
  ## License

      Copyright [2021] [Ava Crnkovic-Rubsamen]

      Licensed under the Apache License, Version 2.0 (the "License");
      you may not use this file except in compliance with the License.
      You may obtain a copy of the License at

          http://www.apache.org/licenses/LICENSE-2.0

      Unless required by applicable law or agreed to in writing, software
      distributed under the License is distributed on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      See the License for the specific language governing permissions and
      limitations under the License.
  

## Planning Stages
### Overview
This app will be a cross between a social media and a self-organization app. The first major tab will be a map in which you can drop pins with your favorite places (under the categories - to shop, to eat, to drink) and when you click on the pin you can see details of the place including pictures (from its instagram or google maps), your own notes, and your categorization of the place using emojis - sneaker emojis for sneaker store etc. You will also be able to add and follow your friends on this app so the second tab will be a timeline where you can post where you are currently shopping/eating/drinking either to just you, a specific group of your friends, or all followers. You will be able to interact with other users' posts through commenting and liking as usual. You can click on your friends' profiles to see their own maps of locations or you can add the locations they are at (to your own map) directly from their posts.

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Social Media/Lifestyle
- **Mobile:** Uses camera and location, mobile-only experience.
- **Story:** Allows users to save and organize all their favorite places to shop/eat/drink so that when they are in a specific neighborhood or area, they can open the app and see if they have any saved places (or if any of their friends do!) Also allows users to share what they're doing with their friends and see what everyone else is doing. Creates the potential to see who's out/who could meet up.
- **Market:** Anyone who likes to shop/eat/drink and cares about finding new places and remembering their favorites! Also provides the ability to meet up with friends/keep up with friends who live in different cities.
- **Habit:** Whenever you're going out whether it be shopping in another city or for drinks to a bar -- hopefully very habit forming.
- **Scope:** The map tab, timeline tab, and profile tab should be within the scope. Additional features such as sharing to specific groups and maybe in-app messaging might have to be optional stories.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can view a map of their saved locations
* User can view a timeline of updates from their friends
* User's can view the maps/saved locations of their friends
* User can interact with other's updates (like)
* Profile view where you see your own updates.
* User can post a new update (and photo) to their feed
* User can create a new account
* User can login/logout
* User can add/unadd friends


**Optional Nice-to-have Stories**

* User can add a new location through a friend's post/map
* User can add a comment to an update
* User can message friends within the app
* User can create groups of friends and share only to specific groups
* User can see notifications when their photo is liked/commented on or they are added

### 2. Screen Archetypes

* [Login Screen]
    * User can login
* [Map]
    * User can view a map of their saved locations
* [Pin Details]
    * User can view details of a location
    * User edit or delete a location
* [Create Pin]
    * User can add a new location
* [Timeline]
    * User can view a feed of updates/photos
    * User can double tap an update to like
* [Create Post]
    * User can post a new update to their feed
* [Add Friends]
    * User can add friends from snapchat/contacts
* [Profile]
    * User can view their profile and feed
* [Edit Profile]
    * User can edit their profile photo/bio

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* [Map]
* [Timeline]
* [Profile]

**Flow Navigation** (Screen to Screen)

* [Login Screen]
    * Home Timeline
* [Map]
    * Create a Pin
    * View Pin Details
* [Timeline]
    * Create a Post
* [Creation]
    * Home Timeline
* [Add Friends]
    * Profile
* [Profile]
    * Add Friends
    * Edit Profile

## Wireframes

![Wireframe](https://i.imgur.com/pJ0E8aL.jpg)

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
[This section will be completed in Unit 9]
### Models

1. User (will be a PFUser)

| Property | Type | Description |
| -------- | -------- | -------- |
| objectID     | String     | unique id for the user post (default field)     |
| username     | String     | username for the user     |
| password     | String     | password for the user     |
| profilePic     | File     | user's profile photo     |
| friends     | Array of pointers to User objects     | user's friends on the app     |
| latitude     | Number     | latitude of user's location    |
| longitude     | Number     | longitude of user's location    |

2. Pin

| Property | Type | Description |
| -------- | -------- | -------- |
| objectID     | String     | unique id for the pin (default field)     |
| author     | Pointer to User     | author of the pin     |
| notes     | String     | notes for the pin     |
| link     | String     | link to website? or instagram?     |
| latitude     | Number     | latitude of pin's location    |
| longitude     | Number     | longitude of pin's location    |
| createdAt     | Date     | datetime the pin was created    |
| image     | File     | file for the image in the pin (optional)    |


3. Post

| Property | Type | Description |
| -------- | -------- | -------- |
| objectID     | String     | unique id for the post (default field)     |
| author     | Pointer to User     | author of the post     |
| caption     | String     | caption for the post     |
| createdAt     | Date     | datetime the post was created    |
| image     | File     | file for the image in the post (optional)    |
| likeCount     | Number     | number of likes the post has    |
| commentCount     | Number     | number of comments the post has    |
| latitude     | Number     | latitude of post's location    |
| longitude     | Number     | longitude of post's location    |

4. Comment

| Property | Type | Description |
| -------- | -------- | -------- |
| objectID     | String     | unique id for the comment (default field)     |
| author     | Pointer to User     | author of the comment     |
| post     | Pointer to Post     | post the comment is attached to     |
| test     | String     | test of the comment     |
| createdAt     | Date     | datetime the comment was created    |

5. Like

| Property | Type | Description |
| -------- | -------- | -------- |
| objectID     | String     | unique id for the like (default field)     |
| author     | Pointer to User     | author of the like     |
| post     | Pointer to Post     | post the like is attached to     |
| createdAt     | Date     | datetime the comment was created    |



### Networking
- Profile Tab
    - (Read/GET) Query logged in user object
    - (Update/PUT) Update user profile picture

            PFUser *user = [PFUser currentUser];
                PFFileObject *pfFile = [Post getPFFileFromImage:self.profilePicImageView.image];
                user[@"profilePic"] = pfFile;
    
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
              if (succeeded) {
                  NSLog(@"updated profile picture!");
              } else {
                  NSLog(@"%@", error.localizedDescription);
              }
            }];
    - (Read/GET) Query all posts where user is author

            PFQuery *query = [PFQuery queryWithClassName:@"Post"];
                [query includeKey:@"author"];
                [query includeKey:@"profilePic"];
                [query whereKey:@"author" equalTo:[PFUser currentUser]];
                [query orderByDescending:@"createdAt"];
                query.limit = 20;

                // fetch data asynchronously
                [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
                    if (posts != nil) {
                        self.posts = posts;
                        NSLog(@"got user's posts");
                        [self.collectionView reloadData];
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
        
- Map Tab
    - (Read/GET) Query all pins where user is author

           PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
                [query includeKey:@"author"];
                [query whereKey:@"author" equalTo:[PFUser currentUser]];
                [query orderByDescending:@"createdAt"];
                query.limit = 20;

                // fetch data asynchronously
                [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
                    if (pins != nil) {
                        self.pins = pins;
                        NSLog(@"got user's pins");
                        [self.collectionView reloadData];
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];


- Pin Details Screen
    - (Delete) Delete existing pin
    - (Create/POST) Edit an existing pin 
- Create Pin Screen
    - (Create/POST) Create a new pin 

            [Pin postUserPin:self.picImageView.image withNotes:self.notesTextField.text withLatitude:latitude withLongitude:longitude withCompletion:^(BOOL succeeded, NSError * error) {
                    if (succeeded) {
                        NSLog(@"the pin was created!");
                    } else {
                        NSLog(@"problem saving pin: %@", error.localizedDescription);
                    }
                }];
                
- Timeline Tab
    - (Read/GET) Query all posts from user's friends
    - (Create/POST) Create a new like on a post
    - (Delete) Delete existing like
    - (Create/POST) Create a new comment on a post

            [Comment postUserCommentOnPost:self.commentTextView.text onPost:self.post withCompletion:^(BOOL succeeded, NSError * error) {
                    if (succeeded) {
                        NSLog(@"the comment was posted!");
                    } else {
                        NSLog(@"problem saving comment: %@", error.localizedDescription);
                    }
                }];
    - (Delete) Delete existing comment
- Create Post Screen
    - (Create/POST) Create a new post object

            [Post postUserImage:self.picImageView.image withCaption:self.captionTextField.text withCompletion:^(BOOL succeeded, NSError * error) {
                    if (succeeded) {
                        NSLog(@"the picture was posted!");
                        [self dismissViewControllerAnimated:true completion:nil];
                    } else {
                        NSLog(@"problem saving picture: %@", error.localizedDescription);
                    }
                }];
                
- User's Profile
    - (Read/GET) Query user object
    - (Read/GET) Query all pins where user is author
    - (Read/GET) Query all posts where user is author
- Add Friends
    - (Read/GET) Query all user objects
    - (Create/POST) add a friend to the user object


Endpoints to existing APIs:
- Google Maps (potentially)


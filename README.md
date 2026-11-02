# CheckMeApp
Original App Design Project - README Template
## CheckMe
Table of Contents
Overview
Product Spec
Wireframes
Schema
Overview
Description
This app will allow users to document their day to day lives by checking off simple tasks such as making their beds or eating a healthy breakfast while also being held acocuntable for their tasks by taking photos or sharing their locations with the app while other users sign in and check on their friends progress. 

## App Evaluation


Category:  Social Networking/Lifestyle 
Mobile: Mobile is essential for the instant logging of student behavior. Students use the app to purchase goods from the student store and other rewards. The camera is used to share images with parents.
Story: Increase productivity and accountavblity and self awareness so the user can become the best version of themselves. Takng photos is instilling discipline in their lives with each tasks while other users can also check in on theor progress and and congulate and motivate them.
Market: Any individual who wants to work ont improving their lives.
Habit: Users should be using this on a dailbasis or until they feel like they can comeplte tasks wothout having to use an app to hold them accountable. This is a habit building app. 
Scope: V1 would allow users to create daily taks they feel are important for their day to day lives and be able to check them off. V2 would be to take pictures and share their location so they can hold themselves accoutnable for their completed tasks and the app itself will be able to congratulate users. V3 would allow other users to join the platform using information such as phone numbers and emails so communities can be formed.
## Product Spec
1. User Stories (Required and Optional)
Required Must-have Stories
- Required to create an account
- Required to create and complete a daily checklist
- required to share atleast one achievement with their mutuals
...
Optional Nice-to-have Stories
- Networking with all such as posting for all contacts to see it optional
- Creating more than three tasks a day that need to be completed
- Adding friends or people in their contacts 

...
2. Screen Archetypes
Login Screen 
User Log in 
Pop up to add friends from their contacts
Another screen with an empty checklist 

3. Navigation
First Tab - Home Feed 
Second Tab - Profile 
Third Tab - Dairy entry 
Fourth Tab - Empty checklist 
Fifth Tab - Completed Checklist 
Six Tab - Shared progress


Flow Navigation (Screen to Screen)
Home Feed 
Leads to Profile Page 
Leads to Dairy Entry Input 
Leads to Empty Checklist 
Leads to Completed Checklist 
Leads to Shared progress 


[BONUS] Digital Wireframes & Mockups
[BONUS] Interactive Prototype
## Schema
Models
• id (UUID / Primary Key)
• email (String, Unique)
• password_hash (String)
• full_name (String)
• timezone (String)
• created_at (Timestamp)
• updated_at (Timestamp)
• id (UUID / Primary Key)
• user_id (UUID / Foreign Key -> users.id)
• title (String, e.g., "Morning Walk", "Drink Water")
• category (String, e.g., "Fitness", "Nutrition", "Mental Health")
• frequency (JSON / String, e.g., "daily", "weekdays")
• target_value (Integer, e.g., 8 glasses)
• is_active (Boolean)
• created_at (Timestamp)


Property	Type	Description
username	String	unique id for the user post (default field)
password	String	user's password for login authentication
...	...	...
Networking
[List of network requests by screen]
[Example: [GET] /users - to retrieve user data]
...
[Add list of network requests by screen ]
[Create basic snippets for each Parse network request]
[OPTIONAL: List endpoints if using existing API such as Yelp]

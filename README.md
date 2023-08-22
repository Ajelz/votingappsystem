# Voting Application Project

## 📋 Table of Contents

- [Overview](#overview)
- [Setup and Installation](#setup-and-installation)
- [Technologies Used](#technologies-used)
- [Backend Infrastructure](#backend-infrastructure)
- [Database Design](#database-design)
- [Frontend Development](#frontend-development)
- [Admin Controls](#admin-controls)
- [User Interactions](#user-interactions)
- [Challenges & Solutions](#challenges--solutions)
- [Future Developments](#future-developments)
- [Contributors](#contributors)
- [References](#references)

## 🌐 Overview

The Voting Application Project is designed to digitize the conventional voting process, making it more accessible, efficient, and secure. By allowing users to cast their votes effortlessly, this platform emphasizes the sanctity and privacy of every vote.

![Image 1](assets/1.png)
![Image 2](assets/2.png)
![Image 3](assets/3.png)
![Image 4](assets/4.png)
![Image 5](assets/5.png)
![Image 6](assets/6.png)

## 🔧 Setup and Installation

1. **Clone the repository**:  
   `git clone https://github.com/Ajelz/votingappsystem`

2. **Navigate to the backend folder and install the required dependencies for the backend**:
   `cd backend`
   `npm install bcrypt cors dotenv express express-rate-limit express-validator jsonwebtoken mysql2 sequelize winston --save`

3. **Set up the environment variables** based on the `.env.example` file.

4. **Start the backend server**:  
`node app.js`

5. **For the frontend, ensure you have Flutter SDK installed.**

6. **If running on an Android device, ensure you either have a virtual Android device from Android Studio installed and running or an Android device connected by cable.**

7. **Navigate to the frontend folder and run the Flutter app**:  
`flutter run`

## 💡 Technologies Used

- **Backend**: Node.js, Express.js
- **Frontend**: Dart, Flutter
- **Database**: MySQL with Sequelize ORM
- **Authentication**: JWT
- **Others**: Shared Preferences for token management in Dart

## 🚀 Backend Infrastructure

A set of APIs has been developed to ensure seamless interaction with the frontend. Middleware authentication is integrated to guarantee secure and authenticated data transactions. The application also incorporates error-handling mechanisms to manage unexpected issues gracefully.

## 📦 Database Design

The database is meticulously designed to prioritize data integrity. Relationships between various entities have been clearly defined to ensure efficient data storage and retrieval. Five main models (User, Admin, Poll, Option, User_Vote) form the core of our data structure.

## 🎨 Frontend Development

The frontend journey is optimized from registration to vote casting. Emphasis has been placed on mobile responsiveness, ensuring users can navigate and interact with the platform seamlessly, irrespective of their device.

## 🔑 Admin Controls

Admin functionalities offer comprehensive control over polls. They can create, modify, and manage polls. Admins also have capabilities to manage user profiles, ensuring system integrity.

## 🙋 User Interactions

Regular users experience a streamlined voting procedure. Features allow them to view and even alter their past votes, ensuring transparency and flexibility.

## ❗ Challenges & Solutions

Development was not without its challenges, including guaranteeing vote anonymity and adeptly handling potential API failures. However, with each challenge came a solution, refining the application further.

## 🌱 Future Developments

The project lays a strong foundation for future enhancements. Potential integrations include real-time voting analytics and more.

## 👥 Contributors

- Amjad Elazzabi

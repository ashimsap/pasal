# Pasal - Nepali E-commerce Platform

A feature-rich e-commerce platform for Nepali users, built with Flutter and Firebase.

<p align="center">
  <img src="assets/ss/pasal1.jpg" width="300" alt="Pasal App Screenshot">
</p>

## ✨ Key Features

- **User Authentication**: Secure sign-in and registration using Firebase Auth.
- **Dynamic Product Catalog**: Browse products from a cloud-based Firestore database.
- **Advanced Product Details**: View products with an interactive image gallery, description, and user reviews.
- **Shopping Cart**: Add, remove, and update item quantities.
- **Seamless Checkout**: A multi-step checkout process with address and payment selection.
- **Flexible Payment Options**: Supports both Cash on Delivery and mock online payments (Khalti, eSewa).
- **Order Management**: Users can view their order history with dynamic status updates.
- **Product Reviews & Ratings**: Users can submit reviews and ratings for products they have purchased.

## 🛠️ Tech Stack & Architecture

- **Framework**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Flutter Riverpod
- **Architecture**: Feature-first project structure (`lib/src/features/...`)

## 🚀 Getting Started

### 1. Prerequisites

- Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- You will need a Firebase project.

### 2. Firebase Setup

This project is tightly integrated with Firebase. To run it, you need to connect it to your own Firebase project.

1.  **Create a Firebase Project**: Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2.  **Configure for Flutter**: Follow the instructions from the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup?platform=ios) to configure your project. This will automatically generate your `firebase_options.dart` file.
    ```sh
    flutterfire configure
    ```
3.  **Enable Services**: In the Firebase Console, enable **Authentication** (with Email/Password sign-in) and **Firestore Database**.

### 3. Installation & Running

1.  **Clone the repository**:
    ```sh
    git clone <your-repo-url>
    cd pasal
    ```
2.  **Install dependencies**:
    ```sh
    flutter pub get
    ```
3.  **Run the app**:
    ```sh
    flutter run
    ```

## 📂 Project Structure

The project follows a feature-first architecture to keep the codebase organized and scalable. All core application code resides in the `lib/src` directory.

```
lib/src/
├── core/            # Shared widgets, themes, providers, etc.
└── features/        # Contains all the distinct features of the app.
    ├── auth/        # Authentication logic
    ├── products/    # Product browsing and details
    ├── cart/        # Shopping cart
    ├── checkout/    # Checkout flow
    ├── orders/      # Order history
    └── ...etc
```

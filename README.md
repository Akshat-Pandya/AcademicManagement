# Student Academic Management App

## Overview
The **Student Academic Management App** is a Flutter-based application designed to facilitate the easy collection, display, and sharing of student academic results. This app allows educators to generate Excel files containing student performance data, making it easier to manage and share results with students and parents.

## Features
- **User-Friendly Interface**: The app provides an intuitive and responsive UI that makes it easy for users to navigate and interact with.
- **Dynamic Data Handling**: Supports the input and display of various student details, including enrollment numbers, names, academic years, subjects, and marks for continuous and semester assessments.
- **Excel File Generation**: Users can generate an Excel file containing all student data, which can be easily saved and shared.
- **Seamless Sharing**: Utilizes the `share_plus` package to allow users to share the generated Excel file directly through their preferred applications (e.g., email, messaging apps).
- **Cross-Platform Support**: Built using Flutter, the app is compatible with both Android and iOS devices.

## Technologies Used
- **Flutter**: For building the cross-platform user interface.
- **Excel Package**: For creating and manipulating Excel files.
- **Path Provider**: To access device storage for saving files.
- **Share Plus**: For sharing files through the platform's native share dialog.

## Installation
To install and run the app locally, follow these steps:
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/student-results-sharing-app.git
2. Navigate to the project directory
   ```bash
   cd student-academic-management-app
3. Install the dependencies:
   ```bash
   flutter pub get
4. Run the app:
   ```bash
   flutter run

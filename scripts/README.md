# 🚀 Quotes to Firebase Uploader

This script helps you push your `quotes.csv` data to Firestore in one click.

## 📋 Prerequisites

1.  **Node.js** installed on your machine.
2.  **Service Account Key**:
    -   Go to the [Firebase Console](https://console.firebase.google.com/).
    -   Select your project.
    -   Click the **Gear Icon (Project Settings)** > **Service Accounts**.
    -   Click **Generate New Private Key**.
    -   Save the downloaded JSON file as `.json` inside this `scripts/` folder.

## 🛠️ Usage

1.  Open your terminal in this directory:
    ```bash
    cd flowlife_mobile/scripts
    ```

2.  Install dependencies:
    ```bash
    npm install
    ```

3.  Run the upload script:
    ```bash
    node upload_quotes.js
    ```

## 📝 What this script does
-   It reads directly from `flowlife_mobile/assets/quotes.csv`.
-   It parses the "quote","author" format.
-   It uploads everything to a collection named `quotes` in Firestore.
-   It uses **Batched Writes** (500 docs at a time) to ensure the upload is fast and reliable.

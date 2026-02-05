const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

/**
 * INSTRUCTIONS:
 * 1. Go to Firebase Console > Project Settings > Service Accounts.
 * 2. Click "Generate New Private Key" and save the JSON file as 'service-account.json' in this folder.
 * 3. Run: npm install
 * 4. Run: node upload_quotes.js
 */

const serviceAccount = require('./service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const collectionName = 'quotes';

async function uploadQuotes() {
  const csvPath = path.join(__dirname, '../assets/quotes.csv');
  const csvData = fs.readFileSync(csvPath, 'utf8');

  const lines = csvData.split('\n').filter(line => line.trim() !== '');
  const quotes = [];

  const regex = /"([^"]*)","([^"]*)"/;

  for (const line of lines) {
    const match = regex.exec(line);
    if (match) {
      quotes.push({
        text: match[1],
        author: match[2],
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  }

  console.log(`Parsed ${quotes.length} quotes. Starting upload...`);

  // Batch upload to handle many documents efficiently
  const batchSize = 500;
  for (let i = 0; i < quotes.length; i += batchSize) {
    const batch = db.batch();
    const chunk = quotes.slice(i, i + batchSize);

    chunk.forEach(quote => {
      const docRef = db.collection(collectionName).doc();
      batch.set(docRef, quote);
    });

    await batch.commit();
    console.log(`Uploaded batch ${Math.floor(i / batchSize) + 1} (${chunk.length} quotes)`);
  }

  console.log('✅ Upload complete!');
}

uploadQuotes().catch(console.error);

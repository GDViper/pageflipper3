const express = require('express');
const cors = require('cors');
const multer = require('multer');
const admin = require('firebase-admin');
const path = require('path');

const app = express();
const port = 3000;

// Correctly setting the path to the Firebase Admin SDK JSON file
const serviceAccountPath = path.join(__dirname, '..', 'android', 'app', 'pageflipper2-firebase-adminsdk-5xi43-ff69a42908.json');
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const storage = admin.storage();

app.use(express.json());
app.use(cors());

const upload = multer({
  storage: multer.memoryStorage()
});

// User Login
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
      const userCredential = await admin.auth().getUserByEmail(email);
      if (userCredential.email) {
          res.status(200).json({ message: 'User logged in successfully', uid: userCredential.uid, isAdmin: userCredential.customClaims?.admin ?? false });
      } else {
          res.status(401).json({ message: 'Authentication failed' });
      }
  } catch (error) {
      res.status(500).json({ message: error.message });
  }
});

// User Signup
app.post('/signup', async (req, res) => {
  const { email, password } = req.body;
  try {
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
    });
    res.status(201).json({ userId: userRecord.uid, message: 'User created successfully' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// File Upload
app.post('/upload', upload.single('file'), async (req, res) => {
  if (!req.file) {
    return res.status(400).send('No file uploaded.');
  }
  try {
    const bucket = storage.bucket();
    const file = bucket.file(`${Date.now()}-${req.file.originalname}`);
    const stream = file.createWriteStream({
      metadata: {
        contentType: req.file.mimetype,
      },
    });

    stream.on('error', (e) => res.status(500).send(e.message));
    stream.on('finish', async () => {
      await file.makePublic();
      res.status(200).send('File uploaded successfully');
    });

    stream.end(req.file.buffer);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Fetch User Data
app.get('/balance/:username', async (req, res) => {
  const { username } = req.params;
  try {
    const userDoc = await db.collection('accounts').doc(username).get();
    if (!userDoc.exists) {
      res.status(404).send('Account not found');
    } else {
      res.json({ balance: userDoc.data().balance });
    }
  } catch (error) {
    res.status(500).send(error.message);
  }
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
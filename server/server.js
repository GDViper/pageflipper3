const express = require('express');
const app = express();
const port = 3000;

const { MongoClient, ServerApiVersion } = require('mongodb');
const uri = "mongodb+srv://chaoskiller3182:Delta3812@cluster0.lajgipa.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1
  }
});

app.use(express.json());

app.post('/login', async (req, res) => {
  try {
    await client.connect();
    const database = client.db('accounts');
    const collection = database.collection('accounts');

    const user = await collection.findOne({ username: req.body.username });

    if(user && user.password === req.body.password) {
      res.status(200).json({ message: 'Login successful', isAdmin: user.admin });
    } else {
      res.status(401).json({ message: 'Invalid credentials' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error connecting to the database', error: error });
  } finally {
    await client.close();
  }
});

app.post('/signup', async (req, res) => {
  try {
    await client.connect();
    const database = client.db('accounts');
    const collection = database.collection('accounts');

    const existingUser = await collection.findOne({ username: req.body.username });
    if (existingUser) {
      return res.status(409).json({ message: 'User already exists' });
    }

    await collection.insertOne({
      email: req.body.email,
      username: req.body.username,
      password: req.body.password,
      admin: false
    });

    res.status(201).json({ message: 'User created successfully', isAdmin: false });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error registering new user', error: error });
  } finally {
    await client.close();
  }
});

app.get('/', (req, res) => {
  res.send('Server is running...');
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
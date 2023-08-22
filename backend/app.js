const express = require('express');
const cors = require('cors');
const rateLimit = require("express-rate-limit");
const bcrypt = require('bcrypt');
require('dotenv').config();
const { sequelize, User } = require('./models');
const adminRouter = require('./routes/adminRouter');
const userRouter = require('./routes/userRouter');
const app = express();

app.use(cors());
app.use(express.json());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use(limiter);

app.get('/', (req, res) => {
    res.json({ message: 'Voting app server running!' });
});

app.use('/admin', adminRouter);
app.use('/user', userRouter);

app.use((req, res, next) => {
    //console.log(`${new Date().toISOString()} - ${req.method} ${req.originalUrl}`);
    next();
});

async function createAdminIfNotExist() {
    const admin = await User.findOne({ where: { username: 'admin' } });
    if (!admin) {
      const hashedPassword = await bcrypt.hash('admin', 10);
      await User.create({
        username: 'admin',
        email: 'admin@admin.com',
        role: 'admin',
        first_name: 'Admin',
        last_name: 'Admin',
        phone_number: '1234567890',
        hashed_password: hashedPassword,
      });
      console.log('Admin user created');
    } else console.log("Admin already exists.");
}

sequelize.authenticate()
    .then(() => {
        console.log('Database connected...');
        return sequelize.sync();
    })
    .then(() => {
        console.log('All models were synchronized successfully.');
        createAdminIfNotExist();
        const PORT = process.env.PORT || 3000;
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
        });
    })
    .catch(err => console.log('Error: ' + err));

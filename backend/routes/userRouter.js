const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { User, Poll, Option, User_Vote } = require('../models');
const authMiddleware = require('../middlewares/auth');
const roleCheck = require('../middlewares/roleCheck');


router.post(
    '/register',
    [
      body('firstName').notEmpty().withMessage('First Name is required'),
      body('lastName').notEmpty().withMessage('Last Name is required'),
      body('email').isEmail().withMessage('Valid Email is required'),
      body('username').notEmpty().withMessage('Username is required'),
      body('phone').notEmpty().withMessage('Phone Number is required'),
      body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long')
    ],
    async (req, res) => {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
  
      const { firstName, lastName, email, username, phone, password } = req.body;
      try {
        const existingUserByUsername = await User.findOne({ where: { username } });
        if (existingUserByUsername) {
          return res.status(400).json({ message: 'This username already exists. Please choose something else.' });
        }
  
        const existingUserByEmail = await User.findOne({ where: { email } });
        if (existingUserByEmail) {
          return res.status(400).json({ message: 'This email is already linked to an account. Please log in.' });
        }
  
        const hashedPassword = await bcrypt.hash(password, 12);
  
        const user = await User.create({ 
          first_name: firstName, 
          last_name: lastName, 
          email: email, 
          username: username, 
          phone_number: phone, 
          hashed_password: hashedPassword,
          role: 'user'
        });
  
        const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
  
        res.status(201).json({ success: true, user: user.toSafeObject(), token });
      } catch (error) {
        res.status(500).json({ success: false, message: error.message });
      }
    }
  );
  
router.get('/users', async (req, res) => {
  try {
    const users = await User.findAll();
    res.status(200).json(users);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "An error occurred while fetching the users." });
  }
});


router.post(
    '/login',
    [
      body('email').notEmpty().withMessage('Email is required'),
      body('password').notEmpty().withMessage('Password is required')
    ],
    async (req, res) => {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      const { email, password } = req.body;
      try {
        console.log(`Searching for user with email: ${email}`);
        const user = await User.findOne({ where: { email } });
        if (!user) {
          return res.status(404).json({ message: 'User not found' });
        }
        const passwordMatch = await bcrypt.compare(password, user.hashed_password);
        if (!passwordMatch) {
          return res.status(400).json({ message: 'Invalid password' });
        }
        const token = jwt.sign({ userId: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1h' });
        res.json({ success: true, token, user: user.toSafeObject() });
      } catch (error) {
        res.status(500).json({ success: false, error: error.message });
      }
    }
  );

router.get('/votes', authMiddleware, async (req, res) => {
  const userId = req.userId;
  try {
    const user_votes = await User_Vote.findAll({
      where: { user_id: userId },
      include: [{
        model: Poll,
        as: 'poll',
        include: {
          model: Option,
          as: 'options'
        }
      }]
    });
    if (!user_votes) {
      console.log('No user_votes found');
      return res.status(404).json({ success: false, message: 'No votes found' });
    }
    console.log('user_votes:', JSON.stringify(user_votes, null, 2));
    res.json({ success: true, user_votes });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});



router.post(
  '/:id/vote',
  authMiddleware,
  [
    body('optionId').notEmpty().withMessage('Option ID is required')
  ],
  async (req, res) => {
    console.log('Received request to cast vote');
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    const { optionId } = req.body;
    const userId = req.userId;
    const pollId = req.params.id;

    try {
        const existingVote = await User_Vote.findOne({ where: { user_id: userId, poll_id: pollId } });
        if (existingVote) {
            if (existingVote.option_id === optionId) {
                return res.status(400).json({ success: false, message: 'You have already voted for this option in this poll.' });
            }

            const previousOption = await Option.findByPk(existingVote.option_id);
            previousOption.vote_count--;
            await previousOption.save();

            const newOption = await Option.findByPk(optionId);
            newOption.vote_count++;
            await newOption.save();

            existingVote.option_id = optionId;
            await existingVote.save();
            console.log('Vote successfully updated:', existingVote);
            return res.json({ success: true, existingVote });
        }

        const newOption = await Option.findByPk(optionId);
        newOption.vote_count++;
        await newOption.save();

        const user_vote = await User_Vote.create({ user_id: userId, poll_id: pollId, option_id: optionId });
        console.log('Vote successfully cast:', user_vote);
        res.json({ success: true, user_vote });
    } catch (error) {
        console.log('Error casting vote:', error.message);
        res.status(500).json({ success: false, error: error.message });
    }
  }
);



router.get('/fetch', async (req, res) => {
  try {
    const polls = await Poll.findAll({
      include: [
        {
          model: Option,
          as: 'options',
          attributes: [
            'id',
            'description',
            'poll_id',
            'vote_count'
          ]
        }
      ]
    });
    res.json({ success: true, polls });
  } catch (error) {
    console.error('Error fetching polls:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});



router.get('/polls', authMiddleware, async (req, res) => {
  const userId = req.userId;
  try {
      const polls = await Poll.findAll({ where: { created_by: userId }, include: Option });
      res.json({ success: true, polls });
  } catch (error) {
      res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;

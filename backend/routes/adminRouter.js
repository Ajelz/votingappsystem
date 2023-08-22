const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { User, Admin, Poll, Option } = require('../models');
const { body, validationResult } = require('express-validator');
const authMiddleware = require('../middlewares/auth');
const roleCheck = require('../middlewares/roleCheck');

router.post('/register', async (req, res) => {
    const { username, password } = req.body;
    const hashedPassword = bcrypt.hashSync(password, 10);
    try {
        const admin = await Admin.create({
            username,
            hashed_password: hashedPassword
        });
        res.json({ success: true, admin });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

router.post('/login', async (req, res) => {
    const { username, password } = req.body;
    try {
        const admin = await Admin.findOne({ where: { username } });
        if (!admin) {
            return res.status(400).json({ success: false, message: 'Invalid login credentials' });
        }
        const match = bcrypt.compareSync(password, admin.hashed_password);
        if (!match) {
            return res.status(400).json({ success: false, message: 'Invalid login credentials' });
        }
        const token = jwt.sign({ id: admin.id, username: admin.username, role: 'admin' }, process.env.JWT_SECRET);
        res.json({ success: true, token });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

router.post(
    '/polls',
    authMiddleware,
    roleCheck('admin'),
    [
        body('question').notEmpty().withMessage('Question is required'),
        body('options').isArray({ min: 2 }).withMessage('At least two options are required'),
        body('options.*.description').notEmpty().withMessage('Option description is required')
    ],
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        const { question, options } = req.body;
        try {
            console.log("User ID: ", req.userId);
            const poll = await Poll.create({ question, created_by: req.userId, status: 1 });
            const optionObjects = options.map(option => ({ description: option.description, poll_id: poll.id })); 
            console.log(optionObjects);
            await Option.bulkCreate(optionObjects);
            res.json({ success: true, poll });
        } catch (error) {
            console.error("Poll Creation Error: ", error);
            res.status(500).json({ success: false, error: error.message });
        }
    }
);




router.get('/polls', authMiddleware, async (req, res) => {
    try {
        const polls = await Poll.findAll({ include: Option });
        res.json({ success: true, polls });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

router.put('/polls/:id', authMiddleware, roleCheck('admin'), async (req, res) => {
    const { question } = req.body;
    try {
        const poll = await Poll.findByPk(req.params.id);
        if (!poll) {
            return res.status(404).json({ success: false, message: 'Poll not found' });
        }
        poll.question = question;
        await poll.save();
        res.json({ success: true, poll });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

router.delete('/polls/:id', authMiddleware, roleCheck('admin'), async (req, res) => {
    const pollId = req.params.id;
    try {
        const result = await Poll.destroy({ where: { id: pollId } });
        res.json({ success: true, result });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

router.put('/polls/:id/deactivate', authMiddleware, roleCheck('admin'), async (req, res) => {
    const pollId = req.params.id;
    try {
        const result = await Poll.update({ status: 0 }, { where: { id: pollId } });
        res.json({ success: true, result });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
  });
  
  router.put('/polls/:id/activate', authMiddleware, roleCheck('admin'), async (req, res) => {
    const pollId = req.params.id;
    try {
        const result = await Poll.update({ status: 1 }, { where: { id: pollId } });
        res.json({ success: true, result });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});


router.post('/upgrade', authMiddleware, roleCheck('admin'), async (req, res) => {
    const { username } = req.body;
    try {
        const user = await User.findOne({ where: { username } });
        if (!user) {
            return res.status(400).json({ success: false, message: 'User not found' });
        }

        user.role = 'admin';
        await user.save();

        res.json({ success: true, message: 'User upgraded to admin successfully' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

router.post('/removeAdmin', authMiddleware, roleCheck('admin'), async (req, res) => {
    const { username } = req.body;
    try {
        console.log(`Attempting to remove admin access for user: ${username}`);

        const user = await User.findOne({ where: { username } });
        if (!user) {
            console.error(`User with username ${username} not found`);
            return res.status(400).json({ success: false, message: 'User not found' });
        }

        user.role = 'user';
        await user.save();

        console.log(`Admin access removed successfully for user: ${username}`);
        res.json({ success: true, message: 'Admin access removed successfully' });
    } catch (error) {
        console.error(`Error when trying to remove admin access for user ${username}:`, error);
        res.status(500).json({ success: false, error: error.message });
    }
});

router.post('/ban', authMiddleware, roleCheck('admin'), async (req, res) => {
    const { username } = req.body;
    try {
        console.log(`Attempting to ban user: ${username}`);

        const user = await User.findOne({ where: { username } });
        if (!user) {
            console.error(`User with username ${username} not found`); 
            return res.status(400).json({ success: false, message: 'User not found' });
        }
    
        await user.update({ banned: true });

        console.log(`User ${username} has been banned successfully`);
        res.json({ success: true, message: 'User has been banned successfully' });
    } catch (error) {
        console.error(`Error when trying to ban user ${username}:`, error);
        res.status(500).json({ success: false, error: error.message });
    }
});

router.post('/unban', authMiddleware, roleCheck('admin'), async (req, res) => {
    const { username } = req.body;
    try {
        const user = await User.findOne({ where: { username } });
        if (!user) {
            return res.status(400).json({ success: false, message: 'User not found' });
        }

        await user.update({ banned: false });

        res.json({ success: true, message: 'User has been unbanned successfully' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});


module.exports = router;

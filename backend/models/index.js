const Sequelize = require('sequelize');
const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
    host: process.env.DB_HOST,
    dialect: 'mysql'
});


const User = require('./User')(sequelize, Sequelize);
const Poll = require('./Poll')(sequelize, Sequelize);
const Option = require('./Option')(sequelize, Sequelize);
const Admin = require('./Admin')(sequelize, Sequelize);
const User_Vote = require('./User_Vote')(sequelize, Sequelize);

// Model associations
const associateModels = () => {
  User.hasMany(Poll, { 
    foreignKey: 'created_by', 
    as: 'polls' 
  });

  Poll.belongsTo(User, { 
    foreignKey: 'created_by', 
    as: 'creator' 
  });

  Poll.hasMany(Option, { 
    foreignKey: 'poll_id', 
    as: 'options' 
  });

  Option.belongsTo(Poll, { 
    foreignKey: 'poll_id', 
    as: 'poll' 
  });

  User.hasMany(User_Vote, {
    foreignKey: 'user_id',
    as: 'votes'
  });

  User_Vote.belongsTo(User, {
    foreignKey: 'user_id'
  });

  Poll.hasMany(User_Vote, {
    foreignKey: 'poll_id',
    as: 'poll_votes'
  });

  User_Vote.belongsTo(Poll, {
    foreignKey: 'poll_id',
    as: 'poll'
  });

  Option.hasMany(User_Vote, {
    foreignKey: 'option_id',
    as: 'option_votes'
  });

  User_Vote.belongsTo(Option, {
    foreignKey: 'option_id',
    as: 'option'
  });
}

associateModels();

module.exports = { sequelize, User, Admin, Poll, Option, User_Vote };

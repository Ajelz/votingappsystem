const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    first_name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    last_name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    phone_number: {
      type: DataTypes.STRING,
      allowNull: false
    },
    role: {
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: 'user'
    },
    hashed_password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    avatar_url: {
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: ''
    },
    banned: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false
    }
  }, {
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false
  });

  User.associate = function(models) {
    User.hasMany(models.Poll, {
      foreignKey: 'created_by',
      as: 'creator',
    });
  };

  User.prototype.toSafeObject = function() { 
    const { id, first_name, last_name, email, username, phone_number, role, avatar_url, banned } = this.toJSON();
    return { id, first_name, last_name, email, username, phone_number, role, avatar_url, banned };
}

  return User;
};

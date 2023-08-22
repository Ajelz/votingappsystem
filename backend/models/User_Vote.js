const User = require('./User');
const Poll = require('./Poll');
const Option = require('./Option');
const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    const User_Vote = sequelize.define('User_Vote', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        user_id: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
        poll_id: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
        option_id: {
            type: DataTypes.INTEGER,
            allowNull: false
        }
    }, {
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: false
    });

    return User_Vote;
};

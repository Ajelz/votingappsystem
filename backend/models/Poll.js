const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    const Poll = sequelize.define('Poll', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        question: {
            type: DataTypes.STRING,
            allowNull: false
        },
        created_by: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'users',
                key: 'id',
            }
        },
        status: {
            type: DataTypes.STRING,
            allowNull: false
        },
        created_at: {
            type: DataTypes.DATE,
            allowNull: false
        },
        updated_at: {
            type: DataTypes.DATE,
            allowNull: true
        }
    }, {
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at',
        tableName: 'poll'
    });

    Poll.associate = function(models) {
      Poll.belongsTo(models.User, {foreignKey: 'created_by', as: 'creator'});
      Poll.hasMany(models.Option, {foreignKey: 'poll_Id', as: 'options'});
    };

    return Poll;
};

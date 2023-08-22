module.exports = (sequelize, DataTypes) => {
  const Option = sequelize.define('Option', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    description: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    poll_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Poll',
        key: 'id',
      },
    },
    vote_count: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
  }, {
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  });

  Option.associate = function(models) {
    Option.belongsTo(models.Poll, { foreignKey: 'poll_id', as: 'poll' });
  };    

  return Option;
};

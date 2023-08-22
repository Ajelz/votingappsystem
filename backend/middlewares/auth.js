const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
    console.log("Entering auth middleware");

    const authHeader = req.get('Authorization');

    if (!authHeader) {
        console.log("No Authorization header found");
        req.isAuth = false;
        return next();
    }

    const token = authHeader.split(' ')[1];
    console.log("Token found: ", token);

    if (!token || token === '') {
        console.log("No token found in the Authorization header");
        req.isAuth = false;
        return next();
    }

    let decodedToken;
    try {
        decodedToken = jwt.verify(token, process.env.JWT_SECRET);
        console.log("Decoded token: ", decodedToken);
    } catch (err) {
        console.log("Error decoding token: ", err.message);
        req.isAuth = false;
        return next();
    }

    if (!decodedToken) {
        console.log("No decoded token found after jwt.verify");
        req.isAuth = false;
        return next();
    }

    req.isAuth = true;
    req.userId = decodedToken.userId;
    req.role = decodedToken.role;

    console.log("Authentication and token verification successful. User ID: ", req.userId, " Role: ", req.role);

    next();
};

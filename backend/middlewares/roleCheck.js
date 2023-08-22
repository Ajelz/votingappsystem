module.exports = (requiredRole) => {
    return (req, res, next) => {
        console.log("Entering role check middleware");

        if (!req.isAuth) {
            console.log("Authentication check failed");
            return res.status(403).json({ message: 'Not authenticated' });
        }

        console.log("User is authenticated");

        if (req.role !== requiredRole) {
            console.log("User's role does not match the required role. User role: ", req.role, " Required role: ", requiredRole);
            return res.status(403).json({ message: 'Not authorized' });
        }

        console.log("User's role matches the required role. Proceeding to next middleware/endpoint.");

        next();
    };
};

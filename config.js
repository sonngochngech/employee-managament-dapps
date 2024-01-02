const mongoose = require("mongoose");
require('dotenv').config()

async function dbConnect() {
    mongoose.connect(
        process.env.MONGODB_URL
    ).then(() => {
        console.log("Successfully connected to MongoDB Atlas!");
    }).catch((error) => {
        console.log("Unable to connect to MongoDB Atlas!");
        console.error(error);
    })
}

module.exports = dbConnect;



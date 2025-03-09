const express = require("express");
const fs = require("fs");

const app = express();
const PORT = 3000;

app.use(express.static("public"));
app.use(express.json());

app.post("/location", (req, res) => {
    const { latitude, longitude } = req.body;
    const ip = req.headers["x-forwarded-for"] || req.socket.remoteAddress;

    const logEntry = `IP: ${ip} | Location: https://www.google.com/maps?q=${latitude},${longitude}\n`;

    fs.appendFileSync("logs.txt", logEntry);
    res.sendStatus(200);
});

app.listen(PORT, () => {
    console.log(`[+] Server running on port ${PORT}`);
});
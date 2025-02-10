import http from "http";
import express from "express";
import { Server } from "socket.io";

const app = express();
const server = http.createServer(app);
const io = new Server(server);

const userSockets = new Map();

io.on("connection", (socket) => {
    console.log(`Connected: ${socket.id}`);

    socket.on("user-join", (data) => {
        userSockets.set(data, socket.id);
        io.to(socket.id).emit("session-join", "Your session has been started");
    });

    socket.on("disconnect", () => {
        for(let [userId, socketId] of userSockets.entries()) {
            if(socketId == socket.id){
                userSockets.delete(userId);
                break;
            }
        }
    });
});

app.use(express.json());

app.get('/api/home-widgets', (req, res) => {
    const userId = req.query.userId;

    if(!userId) {
        return res.status(400).json({success: false, messgae: "userId is required"});
    }

    const socketId = userSockets.get(userId);
    if(socketId) {
        io.to(socketId).emit("home-widgets", "Here is home widgets");
        return res.status(200).json({success: true});
    }else {
        return res.status(400).json({success: false, messgae: "No Active session found."});

    }
});

server.listen(3500, () => {
    console.log("Server starter on port 3500");
});
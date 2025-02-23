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
        io.to(socket.id).emit("session-join", "Successfully established a connection to the server.");
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
    const containerColor = req.query.color ?? "";
    const containerRadius = req.query.radius ?? 0;
    const containerWidth = req.query.width ?? 0;
    const containerHeight = req.query.height ?? 0;

    if(!userId) {
        return res.status(400).json({success: false, messgae: "userId is required"});
    }

    const socketId = userSockets.get(userId);
    if(socketId) {
        var data = `{
            "color": "${containerColor}",
            "radius": ${containerRadius},
            "width": ${containerWidth},
            "height": ${containerHeight}
        }`;
        io.to(socketId).emit("home-widgets", data);
        return res.status(200).json({success: true});
    }else {
        return res.status(400).json({success: false, messgae: "No Active session found."});

    }
});

server.listen(3000, () => {
    console.log("Server starter on port 3000");
});
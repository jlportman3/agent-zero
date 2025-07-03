const WebSocket = require("ws");

const server = new WebSocket.Server({ port: 9090 });

server.on("connection", socket => {
  console.log("Client connected");
  socket.send("hello world");

  socket.on("message", message => {
    console.log(`Received: ${message}`);
  });

  socket.on("close", () => {
    console.log("Client disconnected");
  });
});

console.log("MCP mock server running on ws://0.0.0.0:9090");

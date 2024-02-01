let socket;
let userId;
function setEvents()
{
    socket.on('connect', () => onConnect());
    socket.on('disconnect', () => onDisconnect());
    socket.on('queueStatus', (data) => status(data));
    socket.on('startGame', (data) => startGame(data));
    socket.on("receiveBoard", (board, turn, score, otherScore, win) => updateBoard(board, turn, score, otherScore, win));
    socket.on("appendMessage", (msg) => appendMessage(msg));
}

function getSessionData() {
    return fetch('/memoryGame/getSessionData')
        .then(response => response.json())
        .then(data => {
            console.log('Session data:', data);
            if (data) {
                return data
            } else {
                console.error("Data not found in session!")
                return null;
            }
        })
        .catch(error => {
            console.error('Error retrieving session data: ', error);
            return null
        });
}

function onConnect() {
    sessionStorage.setItem('socketId', socket.id);
}
function onDisconnect() { console.log('Connection ended!'); }

async function setup() {
    if (!sessionStorage.getItem("socketId")) {
        socket = io('http://localhost:5678');
        socket.connect();

        try {
            const data = await getSessionData();
            console.log(data)
            let id = data.id
            let username = data.username
            if (id !== null) {
                userId = id;
                sessionStorage.setItem("id", userId);
                console.log("Retrieved userId:", userId);
                socket.emit("saveId", id);
            } else {
                console.log('Id not found in session.');
            }
            if (username !== null) {
                sessionStorage.setItem("username", username);
                console.log("Retrieved username:", username);
            } else {
                console.log('Username not found in session.');
            }
        } catch (error) {
            console.log('Error in setup:', error);
        }

        console.log("First connection");
    } else {
        let socketId = sessionStorage.getItem("socketId");
        socket = io('http://localhost:5678', {query: {socketId: socketId}});
        socket.connect();
        console.log("Connection reestablished");
    }

    setEvents();
}

//join queue
function join(){
    console.log("Join button clicked");
    let joinButton = document.getElementById("join");
    console.log("Button state before: ", joinButton.disabled);

    socket.emit("joinQueue",userId);
    if (joinButton) {
        joinButton.disabled = true;
        console.log("Sent join req!");
        console.log("Button state after: ", joinButton.disabled);
    }
}

//receive queue status
function status(status){ document.getElementById("status").innerHTML = status; }

//start game
function startGame(gameId){
    console.log(gameId);
    sessionStorage.setItem("gameId", gameId);
    window.location.assign("http://localhost:8081/memoryGame/game.jsp?gameId="+gameId);
    //startCountdown(gameId);
}
function startCountdown() {
    if (sessionStorage.getItem("gameId") === undefined) return;

    document.getElementById("countdown").hidden = false;
    let count = 5;

    let countdownInterval = setInterval(function() {
        document.getElementById("countdown").innerHTML = " " + count;
        count--;

        if (count < 0) {
            clearInterval(countdownInterval);
        }
    }, 1000);
}

function getBoard() {
    setup();
    let gameId = sessionStorage.getItem('gameId');
    let id = sessionStorage.getItem("id");
    socket.emit("getBoard", [gameId, id]);
}

function updateBoard(board, turn, score, otherScore, win)
{
    let matrix = JSON.parse(board)
    console.log(matrix)
    console.log(score)
    console.log(otherScore)
    console.log(sessionStorage.getItem("socketId"))
    let gameBoardElement = document.getElementById("gameBoard");
    document.getElementById("score").innerHTML = score;
    document.getElementById("otherScore").innerHTML = otherScore;
    let gameBoard = ""

    for (let i = 0; i < 5; i++){
        gameBoard += `<div class="row align-items-center">`;
        for (let j = 0; j < 6; j++){
            let value = "closed";
            if (matrix[i][j].visible){ value = matrix[i][j].value }

            let cursor = "style='cursor:pointer'";
            let onclick = `onclick="playMove(` + i + `,` + j + `)"`
            if (turn != sessionStorage.getItem("id")) {
                cursor = "style='cursor:default'";
                onclick = onclick="";
            }
            gameBoard += `<div class="col"><div class="d-block mb-4 h-100"` + cursor + `>
                        <img class="img-fluid img-thumbnail" src="images/` + value + `.png" alt="Playing card" ` + onclick + `>
                        </div>
                    </div>`;
        }
        gameBoard += "</div>";
    }

    if (win != 0)
    {
        if (win == sessionStorage.getItem("id"))
        {
            alert("Congratulations! You won.");
        }
        else
        {
            alert("Oh no! You lost.");
        }
    }
    gameBoardElement.innerHTML = gameBoard
}

function playMove(x, y){
    console.log("played move for " + x + ", " + y);
    let gameId = sessionStorage.getItem('gameId');
    let id = sessionStorage.getItem("id")
    socket.emit("playMove", [gameId, id, x, y]);
}

function sendMessage(){
    let input = document.getElementById("chatInput");
    let text = sessionStorage.getItem("username") + ": " + input.value;
    input.value = "";
    let gameId = sessionStorage.getItem("gameId");
    socket.emit("sendMessage", [gameId, text])
    console.log("Message sent!");
}

function appendMessage(msg){
    console.log(msg)
    let container = document.getElementById("chat");
    let msgDiv = document.createElement("div");
    msgDiv.innerText = msg;
    container.append(msgDiv);
    console.log("Message appended!");
}
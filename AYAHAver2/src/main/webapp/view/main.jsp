<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User, dao.MemoDAO, util.DBManager" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
User loginUser = (User) session.getAttribute("loginUser");
if (loginUser == null) {
    response.sendRedirect("../login.jsp");
    return;
}
String dbPath = application.getRealPath("/WEB-INF/db/main_v3.db");
util.DBManager.setRealPath(dbPath);

dao.MemoDAO memoDAO = new dao.MemoDAO();
String currentMemo = memoDAO.getMemo(loginUser.getId());
request.setAttribute("loginUserName", loginUser.getName());
request.setAttribute("currentMemo", currentMemo);
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>メインメニュー - ちょこり</title>
<link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Nunito:wght@200..1000&display=swap">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/memory-game.css">
<style>
/* --- 既存のベーススタイル --- */
* { margin: 0; padding: 0; box-sizing: border-box; font-family: "Nunito", "Meiryo", sans-serif; }
body {
    display: flex; justify-content: center; align-items: center; min-height: 100vh;
    background: #02020a url('${pageContext.request.contextPath}/images/bg-galaxy.jpg') no-repeat center center/cover;
    background-attachment: fixed; color: #fff; overflow: hidden;
}
#canvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 0; pointer-events: none; }

/* --- サイドパネル装飾 --- */
.side-deco {
    position: fixed; top: 50%; transform: translateY(-50%);
    width: 200px; color: rgba(0, 212, 255, 0.4); font-size: 0.7rem;
    letter-spacing: 2px; z-index: 5; pointer-events: none; text-transform: uppercase;
}
.side-left { left: 40px; text-align: left; border-left: 1px solid rgba(0, 212, 255, 0.2); padding-left: 15px; }
.side-right { right: 40px; text-align: right; border-right: 1px solid rgba(0, 212, 255, 0.2); padding-right: 15px; }
.side-deco span { display: block; margin-bottom: 10px; }

/* --- ステータスバー --- */
.status-bar {
    position: fixed; top: 0; left: 0; width: 100%; padding: 15px 40px;
    background: rgba(0, 0, 0, 0.6); backdrop-filter: blur(15px);
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    display: flex; justify-content: space-between; align-items: center; z-index: 100;
}
.user-badge { 
    display: flex; align-items: center; gap: 10px; font-weight: 600; color: #00d4ff; 
    text-shadow: 0 0 10px rgba(0,212,255,0.5); text-decoration: none; transition: 0.3s;
}
.user-badge:hover { opacity: 0.7; transform: scale(1.05); }

.system-right { display: flex; align-items: center; gap: 20px; }
.system-date { font-size: 0.8rem; color: rgba(255,255,255,0.5); letter-spacing: 2px; }

.logout-btn {
    display: flex; align-items: center; gap: 5px; color: rgba(255, 255, 255, 0.7);
    text-decoration: none; font-size: 0.8rem; padding: 6px 12px;
    border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 4px; transition: 0.3s;
}
.logout-btn:hover { background: rgba(244, 63, 94, 0.2); color: #f43f5e; border-color: #f43f5e; }

/* --- コンテナ配置 --- */
.container { 
    position: relative; z-index: 10; width: 95%; max-width: 1200px; 
    text-align: center; margin: 40px auto; 
}
.content-overlay { 
    background: rgba(15, 23, 42, 0.4); padding: 50px 20px; 
    border-radius: 30px; backdrop-filter: blur(8px);
    border: 1px solid rgba(255,255,255,0.05);
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
}
h1 { 
    font-size: 3.2rem; font-weight: 200; margin-bottom: 10px; 
    letter-spacing: 6px; color: #fff;
    text-shadow: 0 0 30px rgba(0, 212, 255, 0.4); 
}
.subtitle { color: rgba(255, 255, 255, 0.5); margin-bottom: 50px; letter-spacing: 4px; font-size: 0.9rem; }

/* --- メニューグリッド --- */
.menu-grid { 
    display: grid; 
    grid-template-columns: repeat(4, 1fr); 
    gap: 20px; 
    max-width: 1100px; 
    margin: 0 auto; 
}
.menu-box { position: relative; height: 300px; display: flex; justify-content: center; align-items: center; transition: 0.5s; cursor: pointer; }
.menu-box::before, .menu-box::after { content: ''; position: absolute; top: 0; left: 30px; width: 50%; height: 100%; border-radius: 12px; transform: skewX(15deg); transition: 0.5s; }
.menu-box::after { filter: blur(35px); }
.menu-box:hover::before, .menu-box:hover::after { transform: skewX(0deg); left: 10px; width: calc(100% - 20px); }

.menu-box:nth-child(1)::before, .menu-box:nth-child(1)::after { background: linear-gradient(315deg, #ffbc00, #ff0058); }
.menu-box:nth-child(2)::before, .menu-box:nth-child(2)::after { background: linear-gradient(315deg, #03a9f4, #ff0058); }
.menu-box:nth-child(3)::before, .menu-box:nth-child(3)::after { background: linear-gradient(315deg, #4dff03, #00d0ff); }
.menu-box:nth-child(4)::before, .menu-box:nth-child(4)::after { background: linear-gradient(315deg, #9c27b0, #03a9f4); }

.menu-box .content { 
    position: relative; padding: 20px 10px; background: rgba(0, 0, 0, 0.7); 
    backdrop-filter: blur(20px); border-radius: 12px; z-index: 1; transition: 0.5s; 
    width: 90%; height: 90%; border: 1px solid rgba(255,255,255,0.1);
    display: flex; flex-direction: column; justify-content: center; align-items: center;
}
.menu-box:hover .content { background: rgba(0,0,0,0.4); border: 1px solid rgba(255,255,255,0.3); transform: translateY(-10px); }
.menu-box .content i { font-size: 3rem; margin-bottom: 10px; color: #fff; }
.menu-box .content h2 { font-size: 1.1rem; margin-bottom: 8px; letter-spacing: 1px; white-space: nowrap; }
.menu-box .content p { font-size: 0.75rem; color: rgba(255,255,255,0.6); margin-bottom: 15px; }
.menu-box .content a { display: inline-block; padding: 6px 15px; background: #fff; color: #000; border-radius: 50px; text-decoration: none; font-weight: 700; font-size: 0.7rem; transition: 0.3s; }
.menu-box .content a:hover { transform: scale(1.1); box-shadow: 0 0 15px #fff; }

/* --- 修正版：ゲームモーダル配置 --- */
#game-modal { 
    display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
    background: rgba(0, 0, 0, 0.9); backdrop-filter: blur(10px); z-index: 2000; 
    justify-content: center; align-items: center; 
}
.modal-content { 
    position: relative; background: rgba(15, 23, 42, 0.8); padding: 40px; 
    border-radius: 20px; border: 1px solid rgba(255,255,255,0.1); 
    max-width: 900px; width: 90%; text-align: center;
}
.close-game { position: absolute; top: 10px; right: 20px; color: #fff; font-size: 2.5rem; cursor: pointer; }

.game-tabs { display: flex; justify-content: center; gap: 10px; margin-bottom: 30px; }
.tab-btn { 
    background: rgba(255,255,255,0.1); color: #fff; border: 1px solid rgba(255,255,255,0.2); 
    padding: 10px 20px; border-radius: 5px; cursor: pointer; transition: 0.3s; 
}
.tab-btn.active { background: #00d4ff; color: #000; border-color: #00d4ff; }

.game-view { display: none; flex-direction: column; align-items: center; justify-content: center; min-height: 400px; }
.game-view.active { display: flex; }

/* ゲームパーツごとの微調整 */
.g2048-grid { width: 300px; height: 300px; background: #bbada0; border-radius: 6px; display: grid; grid-template-columns: repeat(4, 1fr); grid-gap: 10px; padding: 10px; margin: 0 auto; }
.ttt-grid { display: grid; grid-template-columns: repeat(3, 80px); grid-gap: 5px; margin: 20px auto; }
.ttt-box { width: 80px; height: 80px; background: rgba(255,255,255,0.1); border: 1px solid #fff; display: flex; justify-content: center; align-items: center; font-size: 2rem; cursor: pointer; }

#game-trigger { position: fixed; bottom: 30px; left: 30px; background: linear-gradient(135deg, #6563ff, #4341d4); color: white; padding: 12px 24px; border-radius: 50px; cursor: pointer; z-index: 1000; font-weight: bold; box-shadow: 0 10px 20px rgba(0,0,0,0.3); transition: 0.3s; }

@media (max-width: 768px) {
    .menu-grid { grid-template-columns: 1fr; }
    .modal-content { width: 95%; padding: 20px; }
}
</style>
</head>
<body>
<div class="side-deco side-left">
    <span>Navigation System</span>
    <span>ID: <c:out value="${loginUser.id}" /></span>
    <span>Status: Online</span>
    <div style="margin-top: 20px; opacity: 0.5;">
        >> ACCESSING DATABASE...<br>
        >> SYNCING NODES...<br>
        >> READY.
    </div>
</div>

<div class="side-deco side-right">
    <span>Global Timeline</span>
    <span>Update: Stable</span>
    <span>Server: Tokyo-01</span>
    <div style="margin-top: 20px; opacity: 0.5;">
        CORE_LOAD: 24%<br>
        MEM_USED: 12GB<br>
        UPLOADING... DONE.
    </div>
</div>

<div class="status-bar">
    <a href="${pageContext.request.contextPath}/view/MyPageServlet" class="user-badge">
        <i class='bx bxs-user-circle'></i>
        <span><c:out value="${loginUserName}" /></span>
    </a>
    <div class="system-right">
        <div class="system-date" id="live-clock">SYSTEM ACTIVE</div>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="logout-btn">
            <i class='bx bx-log-out'></i> ログアウト
        </a>
    </div>
</div>

<canvas id="canvas"></canvas>

<div class="container" id="main-container">
    <div class="content-overlay">
        <h1>Hello, <c:out value="${loginUserName}" /></h1>
        <p class="subtitle">Exploring the Knowledge Galaxy</p>

        <div class="menu-grid">
            <div class="menu-box" onclick="location.href='SearchServlet'">
                <div class="content"><i class='bx bx-search-alt'></i><h2>問題を解く</h2><p>知識を深めましょう。</p><a href="SearchServlet">Start Quiz</a></div>
            </div>
            <div class="menu-box" onclick="location.href='BookmarkListServlet'">
                <div class="content"><i class='bx bxs-bookmarks'></i><h2>お気に入り</h2><p>保存した問題を確認。</p><a href="BookmarkListServlet">Check Favs</a></div>
            </div>
            <div class="menu-box" onclick="location.href='MyQuestionsServlet'">
                <div class="content"><i class='bx bx-edit'></i><h2>自作管理</h2><p>問題を管理・作成。</p><a href="MyQuestionsServlet">Manage</a></div>
            </div>
            <div class="menu-box" onclick="location.href='TimelineServlet'">
                <div class="content"><i class='bx bx-planet'></i><h2>タイムライン</h2><p>世界の投稿をチェック。</p><a href="TimelineServlet">Timeline</a></div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="memo_popup.jsp" />

<div id="game-trigger" onclick="openGame()"><i class='bx bx-joystick'></i> 息抜きゲーム</div>

<div id="game-modal">
    <div class="modal-content">
        <span class="close-game" onclick="closeGame()">&times;</span>
        <div class="game-tabs">
            <button id="tab-memory" class="tab-btn active" onclick="switchGame('memory')">神経衰弱</button>
            <button id="tab-ttt" class="tab-btn" onclick="switchGame('ttt')">三目並べ</button>
            <button id="tab-2048" class="tab-btn" onclick="switchGame('2048')">2048</button>
        </div>
        <div id="view-memory" class="game-view active">
            <div class="memory-game-section">
                <div class="wrapper"><ul class="cards">
                <% for(int i=0; i<12; i++) { %>
                <li class="card"><div class="view front-view"><img src="${pageContext.request.contextPath}/images/que_icon.svg"></div>
                <div class="view back-view"><img src=""></div></li>
                <% } %>
                </ul><div class="details"><p class="time">Time: <span><b>120</b>s</span></p><p class="flips">Flips: <span><b>0</b></span></p><button id="game-refresh-btn">Try Again</button></div></div>
            </div>
        </div>
        <div id="view-ttt" class="game-view">
            <div class="ttt-container">
                <div id="ttt-message" style="margin-bottom:10px; font-weight:bold; color:#00d4ff;">あなたの番です (O)</div>
                <div class="ttt-grid" id="ttt-grid-element"><% for(int i=0; i<9; i++) { %><div class="ttt-box" data-index="<%=i%>" onclick="handleTTTClick(<%=i%>)"></div><% } %></div>
                <button id="ttt-play-again" onclick="resetTTT()">Play Again</button>
            </div>
        </div>
        <div id="view-2048" class="game-view">
            <div class="g2048-container">
                <div class="g2048-score-container">Score: <span id="g2048-score">0</span></div>
                <div id="g2048-grid" class="g2048-grid"></div>
            </div>
        </div>
    </div>
</div>

<script src="https://unpkg.com/gsap@3/dist/gsap.min.js"></script>

<script>
/* JS部分は既存のまま（省略） */
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
let stars = [];
let shootingStars = [];
let mouse = { x: -1000, y: -1000 };

function resize() { canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
window.addEventListener('resize', resize);
window.addEventListener('mousemove', e => { mouse.x = e.clientX; mouse.y = e.clientY; });
resize();

class Star {
    constructor() { this.reset(); }
    reset() {
        this.x = Math.random() * canvas.width;
        this.y = Math.random() * canvas.height;
        this.baseX = this.x;
        this.baseY = this.y;
        this.size = Math.random() * 1.5;
        this.speedY = Math.random() * 0.1 + 0.05;
        this.brightness = Math.random();
    }
    update() {
        this.y += this.speedY;
        if (this.y > canvas.height) { this.y = 0; this.x = Math.random() * canvas.width; this.baseX = this.x; }
        let dx = mouse.x - this.x;
        let dy = mouse.y - this.y;
        let dist = Math.sqrt(dx*dx + dy*dy);
        if(dist < 100) { this.x -= dx / 20; this.y -= dy / 20; } else { if(this.x !== this.baseX) this.x += (this.baseX - this.x) * 0.05; }
    }
    draw() {
        ctx.fillStyle = `rgba(255, 255, 255, \${this.brightness})`;
        ctx.beginPath(); ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2); ctx.fill();
    }
}

class ShootingStar {
    constructor() { this.init(); }
    init() { this.x = Math.random() * canvas.width; this.y = 0; this.len = Math.random() * 80 + 20; this.speed = Math.random() * 10 + 5; this.active = true; }
    update() { this.x -= this.speed; this.y += this.speed; if (this.y > canvas.height || this.x < 0) this.active = false; }
    draw() { ctx.strokeStyle = "rgba(255, 255, 255, 0.5)"; ctx.lineWidth = 2; ctx.beginPath(); ctx.moveTo(this.x, this.y); ctx.lineTo(this.x + this.len, this.y - this.len); ctx.stroke(); }
}

for (let i = 0; i < 250; i++) stars.push(new Star());

function animateBackground() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    stars.forEach(s => { s.update(); s.draw(); });
    if (Math.random() < 0.01) shootingStars.push(new ShootingStar());
    shootingStars.forEach((s, i) => { s.update(); s.draw(); if (!s.active) shootingStars.splice(i, 1); });
    requestAnimationFrame(animateBackground);
}
animateBackground();

gsap.to(".content-overlay", { y: -15, duration: 4, repeat: -1, yoyo: true, ease: "sine.inOut" });
gsap.to(".side-left", { y: "-=10", duration: 5, repeat: -1, yoyo: true, ease: "sine.inOut" });
gsap.to(".side-right", { y: "+=10", duration: 6, repeat: -1, yoyo: true, ease: "sine.inOut" });

function openGame() { document.getElementById('game-modal').style.display = 'flex'; switchGame('memory'); }
function closeGame() { document.getElementById('game-modal').style.display = 'none'; }
function switchGame(type) {
    document.querySelectorAll('.game-view').forEach(v => v.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.getElementById('view-' + type).classList.add('active');
    document.getElementById('tab-' + type).classList.add('active');
    if(type === 'memory' && typeof shuffleCard === 'function') shuffleCard();
    if(type === 'ttt') resetTTT();
    if(type === '2048' && typeof init2048 === 'function') init2048();
}

let tttBoard = ["", "", "", "", "", "", "", "", ""];
let isGameActive = true;
let currentPlayer = "O"; 
function handleTTTClick(index) {
    if (tttBoard[index] !== "" || !isGameActive || currentPlayer !== "O") return;
    makeMove(index, "O");
    if (isGameActive) { currentPlayer = "X"; document.getElementById("ttt-message").innerText = "CPUが考え中..."; setTimeout(cpuMove, 500); }
}
function makeMove(index, player) {
    tttBoard[index] = player;
    const box = document.querySelector(`.ttt-box[data-index='\${index}']`);
    if(box) { box.innerText = player; box.classList.add("taken"); }
    if (checkWinner(player)) { document.getElementById("ttt-message").innerText = player === "O" ? "あなたの勝ち！" : "CPUの勝ち！"; isGameActive = false; }
    else if (!tttBoard.includes("")) { document.getElementById("ttt-message").innerText = "引き分けです！"; isGameActive = false; }
}
function cpuMove() {
    if (!isGameActive) return;
    let availableMoves = tttBoard.map((val, idx) => val === "" ? idx : null).filter(val => val !== null);
    if (availableMoves.length > 0) { const randomMove = availableMoves[Math.floor(Math.random() * availableMoves.length)]; makeMove(randomMove, "X"); if (isGameActive) { currentPlayer = "O"; document.getElementById("ttt-message").innerText = "あなたの番です (O)"; } }
}
function checkWinner(player) { const winConditions = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]; return winConditions.some(c => c.every(i => tttBoard[i] === player)); }
function resetTTT() { tttBoard = ["", "", "", "", "", "", "", "", ""]; isGameActive = true; currentPlayer = "O"; document.getElementById("ttt-message").innerText = "あなたの番です (O)"; document.querySelectorAll(".ttt-box").forEach(b => { b.innerText = ""; b.classList.remove("taken"); }); }

function updateClock() { const now = new Date(); document.getElementById('live-clock').innerText = now.getFullYear() + '.' + (now.getMonth()+1) + '.' + now.getDate() + ' SYSTEM ACTIVE'; }
setInterval(updateClock, 1000);
updateClock();
</script>

<script>const CONTEXT_PATH = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/memory-game.js"></script>
<script src="${pageContext.request.contextPath}/js/game2048.js"></script>
</body>
</html>
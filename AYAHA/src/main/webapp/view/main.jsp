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
/* --- 既存のスタイル（維持） --- */
* { margin: 0; padding: 0; box-sizing: border-box; font-family: "Nunito", "Meiryo", sans-serif; }
body {
display: flex; justify-content: center; align-items: center; min-height: 100vh;
background: #050510 url('${pageContext.request.contextPath}/images/bg-galaxy.jpg') no-repeat center center/cover;
background-attachment: fixed; color: #fff; overflow-x: hidden;
}
#canvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 0; pointer-events: none; }
.container { position: relative; z-index: 10; width: 95%; max-width: 1100px; text-align: center; margin: 40px auto; }

h1 { font-size: 2rem; font-weight: 300; margin-bottom: 10px; text-shadow: 0 0 15px rgba(0, 212, 255, 0.6); }
p { color: rgba(255, 255, 255, 0.7); margin-bottom: 30px; }

.memo-section { text-align: left; margin: 0 auto 40px; max-width: 500px; }
.memo-section h4 { font-size: 0.85rem; color: #00d4ff; margin-bottom: 8px; display: flex; align-items: center; gap: 5px; }
.memo-display { background: rgba(255, 255, 165, 0.1); border-left: 3px solid #f1c40f; padding: 15px; color: #eee; min-height: 60px; font-size: 0.9rem; white-space: pre-wrap; border-radius: 0 10px 10px 0; backdrop-filter: blur(10px); }

/* --- ネオン＆ガラスカード --- */
.menu-grid { display: flex; justify-content: center; align-items: center; flex-wrap: wrap; padding: 20px 0; gap: 30px; }
.menu-box { position: relative; width: 280px; height: 320px; display: flex; justify-content: center; align-items: center; transition: 0.5s; }
.menu-box::before { content: ' '; position: absolute; top: 0; left: 50px; width: 50%; height: 100%; background: #fff; border-radius: 8px; transform: skewX(15deg); transition: 0.5s; }
.menu-box::after { content: ''; position: absolute; top: 0; left: 50px; width: 50%; height: 100%; background: #fff; border-radius: 8px; transform: skewX(15deg); transition: 0.5s; filter: blur(30px); }
.menu-box:hover::before, .menu-box:hover::after { transform: skewX(0deg); left: 20px; width: calc(100% - 90px); }
.menu-box:nth-child(1)::before, .menu-box:nth-child(1)::after { background: linear-gradient(315deg, #ffbc00, #ff0058); }
.menu-box:nth-child(2)::before, .menu-box:nth-child(2)::after { background: linear-gradient(315deg, #03a9f4, #ff0058); }
.menu-box:nth-child(3)::before, .menu-box:nth-child(3)::after { background: linear-gradient(315deg, #4dff03, #00d0ff); }
.menu-box span { display: block; position: absolute; top: 0; left: 0; right: 0; bottom: 0; z-index: 50; pointer-events: none; }
.menu-box span::before { content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 100%; border-radius: 8px; background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(10px); opacity: 0; transition: 0.5s; animation: box-animate 2s ease-in-out infinite; box-shadow: 0 5px 15px rgba(0,0,0,0.08); }
.menu-box:hover span::before { top: -50px; left: 50px; width: 100px; height: 100px; opacity: 1; }
.menu-box span::after { content: ''; position: absolute; bottom: 0; right: 0; width: 100%; height: 100%; border-radius: 8px; background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(10px); opacity: 0; transition: 0.5s; animation: box-animate 2s ease-in-out infinite; box-shadow: 0 5px 15px rgba(0,0,0,0.08); animation-delay: -1s; }
.menu-box:hover span:after { bottom: -50px; right: 50px; width: 100px; height: 100px; opacity: 1; }
@keyframes box-animate { 0%, 100% { transform: translateY(10px); } 50% { transform: translateY(-10px); } }
.menu-box .content { position: relative; left: 0; padding: 20px; background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1); border-radius: 8px; z-index: 1; transition: 0.5s; color: #fff; width: 240px; }
.menu-box:hover .content { left: -25px; padding: 40px 20px; }
.menu-box .content h2 { font-size: 1.2rem; margin-bottom: 10px; }
.menu-box .content p { font-size: 0.85rem; margin-bottom: 20px; line-height: 1.4; color: #eee; }
.menu-box .content a { display: inline-block; padding: 8px 15px; background: #fff; color: #000; border-radius: 4px; text-decoration: none; font-weight: 600; font-size: 0.9rem; }

/* ナビゲーション */
.nav-holder { margin-bottom: 30px; }
nav.shiny-nav ul { margin: 0; padding: 0; list-style: none; display: flex; gap: 30px; justify-content: center; }
nav.shiny-nav ul li button { -webkit-appearance: none; border: none; cursor: pointer; background: transparent; padding: 10px 5px; color: rgba(255, 255, 255, 0.6); font-weight: 600; }
nav.shiny-nav .active-element { --active-element-show: 0; position: absolute; top: 100%; left: 0; height: 3px; width: 40px; background: #0075ff; opacity: var(--active-element-show); pointer-events: none; }

.logout-link { display: inline-block; margin-top: 25px; color: rgba(255, 255, 255, 0.4); text-decoration: none; font-size: 0.85em; }

/* ゲームモーダル */
#game-modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.85); backdrop-filter: blur(8px); z-index: 2000; justify-content: center; align-items: center; }
.modal-content { position: relative; display: flex; flex-direction: column; align-items: center; }
.close-game { position: absolute; top: -50px; right: 0; color: #fff; font-size: 2.5rem; cursor: pointer; }
.game-tabs { display: flex; gap: 10px; margin-bottom: 15px; }
.tab-btn { padding: 8px 18px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.3); background: rgba(255,255,255,0.1); color: #fff; cursor: pointer; }
.tab-btn.active { background: #6563ff; }
.game-view { display: none; }
.game-view.active { display: block; }
#game-trigger { position: fixed; bottom: 20px; left: 20px; background: linear-gradient(135deg, #6563ff, #4341d4); color: white; padding: 12px 20px; border-radius: 50px; cursor: pointer; z-index: 1000; font-weight: bold; display: flex; align-items: center; gap: 8px; }

/* 2048用追加スタイル */
.g2048-score-container { margin-bottom: 10px; font-size: 1.2rem; font-weight: bold; color: #eee; }
.g2048-grid { width: 300px; height: 300px; background: #bbada0; border-radius: 6px; display: grid; grid-template-columns: repeat(4, 1fr); grid-gap: 10px; padding: 10px; position: relative; }
.g2048-tile { width: 62.5px; height: 62.5px; background: rgba(238, 228, 218, 0.35); border-radius: 3px; display: flex; justify-content: center; align-items: center; font-size: 1.5rem; font-weight: bold; color: #776e65; }
.g2048-tile[data-val="2"] { background: #eee4da; }
.g2048-tile[data-val="4"] { background: #ede0c8; }
.g2048-tile[data-val="8"] { background: #f2b179; color: white; }
/* ...（他数値の色の定義が必要な場合は追加）... */
</style>
</head>
<body>
<canvas id="canvas"></canvas>

<div class="container">
<h1>こんにちは、<c:out value="${loginUserName}" /> さん</h1>
<p>今日は何を学習しますか？</p>

<div class="nav-holder">
  <nav class="shiny-nav" id="top-nav">
    <ul>
      <li class="active"><button onclick="location.href='SearchServlet'">Home</button></li>
      <li><button onclick="location.href='BookmarkListServlet'">Favs</button></li>
      <li><button onclick="location.href='MyQuestionsServlet'">Manage</button></li>
      <li><button onclick="openGame()">Game</button></li>
    </ul>
  </nav>
</div>

<div class="memo-section">
<h4><i class='bx bx-note'></i> 現在のメモ用紙</h4>
<div id="main-memo-display" class="memo-display">
<c:choose>
<c:when test="${empty currentMemo}"><span style="opacity: 0.5; font-style: italic;">メモはまだありません。</span></c:when>
<c:otherwise><c:out value="${currentMemo}" /></c:otherwise>
</c:choose>
</div>
</div>

<div class="menu-grid">
  <div class="menu-box"><span></span><div class="content"><h2>問題を解く</h2><p>最新の学習問題を検索して挑戦しましょう。</p><a href="SearchServlet">Start Quiz</a></div></div>
  <div class="menu-box"><span></span><div class="content"><h2>お気に入り</h2><p>❤️を付けた大切な問題をチェックします。</p><a href="BookmarkListServlet">Check Favs</a></div></div>
  <div class="menu-box"><span></span><div class="content"><h2>自作管理</h2><p>オリジナル問題を作成・編集できます。</p><a href="MyQuestionsServlet">Manage My Quiz</a></div></div>
</div>

<a href="../LogoutServlet" class="logout-link"><i class='bx bx-log-out'></i> ログアウト</a>
</div>

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
    </ul><div class="details">
      <p class="time">Time: <span><b>120</b>s</span></p>
      <p class="flips">Flips: <span><b>0</b></span></p>
      <button id="game-refresh-btn">Try Again</button>
    </div></div>
  </div>
</div>

<div id="view-ttt" class="game-view">
  <div class="ttt-container">
    <div class="ttt-grid">
    <% for(int i=0; i<9; i++) { %><div class="ttt-box" data-index="<%=i%>"></div><% } %>
    </div>
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

<jsp:include page="memo_popup.jsp" />

<script src="https://unpkg.co/gsap@3/dist/gsap.min.js"></script>
<script>
/* 星空アニメーション */
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
let stars = [];
function resize() { canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
window.addEventListener('resize', resize);
resize();
class Star {
constructor() { this.reset(); }
reset() { this.x = Math.random() * canvas.width; this.y = Math.random() * canvas.height; this.size = Math.random() * 1.2 + 0.5; this.speedX = (Math.random() - 0.5) * 0.1; this.speedY = Math.random() * 0.05 + 0.02; this.brightness = Math.random(); this.blinkSpeed = Math.random() * 0.01 + 0.005; }
update() { this.y += this.speedY; this.x += this.speedX; this.brightness += this.blinkSpeed; if (this.y > canvas.height) this.reset(); }
draw() { const alpha = Math.abs(Math.sin(this.brightness)); ctx.fillStyle = `rgba(255, 255, 255, ${alpha})`; ctx.beginPath(); ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2); ctx.fill(); }
}
for (let i = 0; i < 100; i++) stars.push(new Star());
function animate() { ctx.clearRect(0, 0, canvas.width, canvas.height); stars.forEach(star => { star.update(); star.draw(); }); requestAnimationFrame(animate); }
animate();

/* ナビゲーション */
const navElement = document.querySelector("#top-nav");
const activeElement = document.createElement("div");
activeElement.classList.add("active-element");
navElement.appendChild(activeElement);
const getOffsetLeft = (el) => {
  const rect = el.getBoundingClientRect();
  const navRect = navElement.getBoundingClientRect();
  return rect.left - navRect.left + (rect.width - activeElement.offsetWidth) / 2;
};
document.fonts.ready.then(() => {
  const activeBtn = navElement.querySelector("ul li.active button");
  if(activeBtn) {
    gsap.set(activeElement, { x: getOffsetLeft(activeBtn) });
    gsap.to(activeElement, { "--active-element-show": "1", duration: 0.3 });
  }
});

/* ゲーム共通制御 */
function openGame() { document.getElementById('game-modal').style.display = 'flex'; switchGame('memory'); }
function closeGame() { document.getElementById('game-modal').style.display = 'none'; }
function switchGame(type) {
    document.querySelectorAll('.game-view').forEach(v => v.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.getElementById('view-' + type).classList.add('active');
    document.getElementById('tab-' + type).classList.add('active');
    
    if(type === 'memory' && typeof shuffleCard === 'function') shuffleCard();
    if(type === 'ttt' && typeof resetTTT === 'function') resetTTT();
    if(type === '2048' && typeof init2048 === 'function') init2048();
}
</script>

<script>const CONTEXT_PATH = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/memory-game.js"></script>
<script src="${pageContext.request.contextPath}/js/tictactoe.js"></script>
<script>
/** 2048 Logic Bridge & Keyboard Fix **/
window.addEventListener("keydown", (e) => {
    const view2048 = document.getElementById("view-2048");
    const modal = document.getElementById("game-modal");
    if (!view2048.classList.contains("active") || modal.style.display === 'none') return;

    let moved = false;
    if (e.key === "ArrowLeft") moved = moveLeft();
    else if (e.key === "ArrowRight") moved = moveRight();
    else if (e.key === "ArrowUp") moved = moveUp();
    else if (e.key === "ArrowDown") moved = moveDown();

    if (moved) {
        addRandomTile();
        draw2048Grid();
        checkGameOver();
    }
});

// TTTの盤面クリアを明示
function resetTTT() {
    const boxes = document.querySelectorAll(".ttt-box");
    boxes.forEach(box => {
        box.innerText = "";
        box.classList.remove("taken");
    });
    if (typeof initTTT === 'function') initTTT(); 
}
</script>
</body>
</html>
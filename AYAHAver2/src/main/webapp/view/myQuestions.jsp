<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Playlist" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>自作プレイリスト管理 - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Nunito:wght@200..1000&display=swap">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Nunito", "Meiryo", sans-serif; }

        body {
            display: flex; justify-content: center; align-items: center; min-height: 100vh;
            background-color: #050510; 
            background-image: url('${pageContext.request.contextPath}/images/bg-galaxy.jpg');
            background-repeat: no-repeat; background-position: center center;
            background-size: cover; background-attachment: fixed;
            overflow-x: hidden; color: #fff;
        }

        #canvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1; pointer-events: none; }

        /* --- ネオン装飾のコンテナ --- */
        .neon-card-wrapper {
            position: relative;
            z-index: 10;
            width: 95%;
            max-width: 900px;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 40px 10px;
        }

        .neon-card-wrapper::before {
            content: '';
            position: absolute;
            top: -10px; left: 50px;
            width: 50%; height: 100%;
            background: linear-gradient(315deg, #03a9f4, #ff0058);
            border-radius: 25px;
            transform: skewX(15deg);
            transition: 0.5s;
            z-index: 1;
        }

        .neon-card-wrapper::after {
            content: '';
            position: absolute;
            top: -10px; left: 50px;
            width: 50%; height: 100%;
            background: linear-gradient(315deg, #03a9f4, #ff0058);
            border-radius: 25px;
            transform: skewX(15deg);
            transition: 0.5s;
            filter: blur(30px);
            z-index: 1;
        }

        .neon-card-wrapper:hover::before,
        .neon-card-wrapper:hover::after {
            transform: skewX(0deg);
            left: 20px;
            width: calc(100% - 40px);
        }

        /* 浮遊する装飾 */
        .neon-card-wrapper span.float-glass {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            z-index: 15;
            pointer-events: none;
        }

        .neon-card-wrapper span.float-glass::before,
        .neon-card-wrapper span.float-glass::after {
            content: '';
            position: absolute;
            width: 80px; height: 80px;
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            opacity: 0;
            transition: 0.5s;
            animation: float-animate 2.5s ease-in-out infinite;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }

        .neon-card-wrapper:hover span.float-glass::before { top: -40px; left: -20px; opacity: 1; }
        .neon-card-wrapper:hover span.float-glass::after { bottom: -40px; right: -20px; opacity: 1; animation-delay: -1s; }

        @keyframes float-animate {
            0%, 100% { transform: translateY(10px); }
            50% { transform: translateY(-10px); }
        }

        /* コンテナ */
        .container {
            position: relative; z-index: 10; width: 100%;
            background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(20px) saturate(180%); border-radius: 25px;
            padding: 40px; box-shadow: 0 20px 50px rgba(0, 0, 0, 0.4);
            transition: 0.5s;
        }

        .neon-card-wrapper:hover .container {
            transform: translateX(-10px);
        }

        /* --- 統合ボタンスタイル --- */
        .pixel-glass-btn {
            position: relative; width: 100px; height: 45px;
            display: flex; justify-content: center; align-items: center;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 30px; text-decoration: none; border: none;
            cursor: pointer; transition: 0.5s; overflow: visible;
        }

        .pixel-glass-btn span {
            position: relative; z-index: 20; color: #fff; font-weight: bold;
            letter-spacing: 1px; transition: 0.5s; pointer-events: none;
        }

        .pixel-glass-btn:hover span { letter-spacing: 2px; }

        .glass-base {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px); border-radius: 30px;
            border-top: 1px solid rgba(255, 255, 255, 0.2);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            z-index: 10; transition: 0.5s;
        }

        .pixel-glass-btn::before, .pixel-glass-btn::after {
            content: ""; position: absolute; left: 50%; transform: translateX(-50%);
            background: var(--clr); width: 30px; height: 8px; border-radius: 10px;
            transition: 0.5s; z-index: 1;
            box-shadow: 0 0 10px var(--clr), 0 0 20px var(--clr);
        }
        .pixel-glass-btn::before { bottom: -4px; }
        .pixel-glass-btn::after { top: -4px; }
        .pixel-glass-btn:hover::before { bottom: 0; height: 50%; width: 85%; border-radius: 30px; }
        .pixel-glass-btn:hover::after { top: 0; height: 50%; width: 85%; border-radius: 30px; }

        .pixel-container {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            z-index: 5; pointer-events: none;
        }
        .pixel-container .pixel {
            position: absolute; width: 6px; height: 6px;
            background: var(--clr); border-radius: 1px;
            opacity: 0; transition: transform 0.6s ease, opacity 0.6s ease;
        }
        .pixel-glass-btn:hover .pixel {
            opacity: 1;
            transform: translate(var(--tx), var(--ty));
        }

        .btn-new { width: 160px; height: 50px; }
        .button-group { display: flex; gap: 15px; align-items: center; }

        .result-item { border-bottom: 1px solid rgba(255, 255, 255, 0.1); padding: 20px 0; display: flex; justify-content: space-between; align-items: center; }
        .result-title { font-size: 1.2em; color: #00d4ff !important; text-decoration: none; display: block; margin-top: 4px; }
        .result-meta { color: rgba(255, 255, 255, 0.4); font-size: 0.85em; }

        /* --- 息抜きゲーム復旧用の追加CSS --- */
        #game-modal {
            z-index: 9999 !important; /* 最前面へ */
        }
        .game-view, .memory-game, .ttt-board, .grid-container-2048 {
            pointer-events: auto !important; /* クリックを有効化 */
        }
        #game-modal .modal-content {
            z-index: 10000;
        }
    </style>
</head>
<body>
    <canvas id="canvas"></canvas>

    <div class="neon-card-wrapper">
        <span class="float-glass"></span>
        
        <div class="container">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 35px;">
                <h2 style="font-size: 1.6rem; letter-spacing: 1px;">My Playlists</h2>
                <a href="${pageContext.request.contextPath}/view/CreateQuestionServlet" class="pixel-glass-btn btn-new" style="--clr: #00ffe5;">
                    <div class="glass-base"></div>
                    <span><i class='bx bx-plus-circle'></i> 新規作成</span>
                    <div class="pixel-container"></div>
                </a>
            </div>

            <c:choose>
                <c:when test="${not empty myPlaylists}">
                    <c:forEach var="p" items="${myPlaylists}">
                        <div class="result-item">
                            <div class="result-info">
                                <span class="result-meta">ID: <c:out value="${p.id}" /> | <c:out value="${p.questionCount}" /> Questions</span>
                                <a href="${pageContext.request.contextPath}/view/PlaylistDetailServlet?playlistId=${p.id}" class="result-title">
                                    <strong><c:out value="${p.name}" /></strong>
                                </a>
                            </div>
                            <div class="button-group">
                                <a href="${pageContext.request.contextPath}/view/StartPlaylistServlet?id=${p.id}" class="pixel-glass-btn" style="--clr: #2dd9fe;">
                                    <div class="glass-base"></div>
                                    <span>解く</span>
                                    <div class="pixel-container"></div>
                                </a>
                                <a href="${pageContext.request.contextPath}/view/PlaylistDetailServlet?playlistId=${p.id}" class="pixel-glass-btn" style="--clr: #78fd61;">
                                    <div class="glass-base"></div>
                                    <span>管理</span>
                                    <div class="pixel-container"></div>
                                </a>
                                <form action="${pageContext.request.contextPath}/view/MyQuestionsServlet" method="POST" style="margin: 0;">
                                    <input type="hidden" name="id" value="${p.id}">
                                    <input type="hidden" name="action" value="delete">
                                    <button type="submit" class="pixel-glass-btn" style="--clr: #FF53cd;" onclick="return confirm('削除しますか？')">
                                        <div class="glass-base"></div>
                                        <span>削除</span>
                                        <div class="pixel-container"></div>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p style="text-align: center; color: rgba(255,255,255,0.4); padding: 30px;">プレイリストがありません。</p>
                </c:otherwise>
            </c:choose>

            <p style="text-align: center; margin-top: 35px;">
                <a href="${pageContext.request.contextPath}/view/main.jsp" style="color: rgba(255,255,255,0.5); text-decoration: none; font-size: 0.9em; transition: 0.3s;">
                   <i class='bx bx-left-arrow-alt'></i> メインへ戻る
                </a>
            </p>
        </div>
    </div>

    <script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        let stars = [];
        function resize() { canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
        window.addEventListener('resize', resize);
        resize();
        class Star {
            constructor() { this.reset(); }
            reset() { this.x = Math.random() * canvas.width; this.y = Math.random() * canvas.height; this.size = Math.random() * 1.5 + 0.2; this.speedY = Math.random() * 0.1 + 0.05; this.brightness = Math.random(); }
            update() { this.y += this.speedY; if (this.y > canvas.height) this.reset(); }
            draw() { const alpha = Math.abs(Math.sin(this.brightness)); ctx.fillStyle = "rgba(255, 255, 255, " + alpha + ")"; ctx.beginPath(); ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2); ctx.fill(); this.brightness += 0.01; }
        }
        for (let i = 0; i < 100; i++) stars.push(new Star());
        function animate() { ctx.clearRect(0, 0, canvas.width, canvas.height); stars.forEach(s => { s.update(); s.draw(); }); requestAnimationFrame(animate); }
        animate();

        function initPixels() {
            const btns = document.querySelectorAll('.pixel-glass-btn');
            btns.forEach(btn => {
                const container = btn.querySelector('.pixel-container');
                if(!container) return; // コンテナがない場合はスキップ
                const w = btn.offsetWidth, h = btn.offsetHeight;
                const pixSize = 8;
                for (let i = 0; i < Math.floor(w / pixSize); i++) {
                    for (let j = 0; j < Math.floor(h / pixSize); j++) {
                        const pixel = document.createElement('div');
                        pixel.className = 'pixel';
                        pixel.style.left = (i * pixSize) + 'px';
                        pixel.style.top = (j * pixSize) + 'px';
                        pixel.style.transitionDelay = (Math.random() * 0.4) + 's';
                        pixel.style.setProperty('--tx', (Math.random() - 0.5) * 50 + 'px');
                        pixel.style.setProperty('--ty', (Math.random() - 0.5) * 50 + 'px');
                        container.appendChild(pixel);
                    }
                }
            });
        }
        window.addEventListener('load', initPixels);
    </script>
</body>
</html>
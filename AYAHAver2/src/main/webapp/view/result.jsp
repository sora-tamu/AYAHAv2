<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Question, model.User, dao.BookmarkDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    Question question = (Question) request.getAttribute("question");
    if (question != null && loginUser != null) {
        BookmarkDAO bDAO = new BookmarkDAO();
        boolean isLiked = bDAO.isBookmarked(loginUser.getId(), question.getId());
        request.setAttribute("isLiked", isLiked);
    }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>結果発表 - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;500;700&display=swap">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Noto Sans JP', sans-serif;
            display: flex; justify-content: center; align-items: center; min-height: 100vh;
            background-color: #fdfdfd; overflow: hidden; color: #333;
        }

        /* 背景アニメーション用キャンバス */
        #canvas { position: fixed; top: 0; left: 0; z-index: -1; }

        .result-card {
            position: relative;
            background: rgba(255, 255, 255, 0.9);
            padding: 40px;
            border-radius: 30px;
            width: 90%;
            max-width: 550px;
            text-align: center;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.08);
            border: 1px solid #eee;
            animation: cardEntrance 0.7s cubic-bezier(0.2, 0.8, 0.2, 1);
            z-index: 10;
        }

        @keyframes cardEntrance {
            0% { opacity: 0; transform: scale(0.9) rotate(-2deg); }
            100% { opacity: 1; transform: scale(1) rotate(0deg); }
        }

        .result-mark {
            font-size: 5rem;
            margin-bottom: 10px;
            line-height: 1;
        }

        .result-title {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 25px;
        }

        .info-grid {
            display: grid;
            gap: 15px;
            margin-bottom: 30px;
        }

        .info-item {
            background: #fff;
            padding: 20px;
            border-radius: 15px;
            border: 1px solid #f0f0f0;
            transition: 0.3s;
        }

        .info-label { font-size: 0.75rem; color: #999; font-weight: 700; display: block; margin-bottom: 8px; }
        .info-val { font-size: 1.1rem; color: #444; word-break: break-all; }
        .info-val.correct { color: #007aff; font-weight: 700; }

        .explanation {
            background: #fff9e6;
            padding: 20px;
            border-radius: 15px;
            text-align: left;
            font-size: 0.9rem;
            line-height: 1.7;
            margin-bottom: 30px;
            border: 1px solid #ffeeba;
        }

        /* アクションエリア */
        .actions { display: flex; flex-direction: column; gap: 12px; }

        .btn {
            padding: 16px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 700;
            transition: 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-main { background: #333; color: #fff !important; }
        .btn-main:hover { background: #000; transform: translateY(-2px); }

        .btn-sub { background: #fff; border: 1px solid #ddd; color: #666 !important; font-size: 0.9rem; }
        .btn-sub:hover { border-color: #333; color: #333 !important; }

        .fav-link {
            font-size: 1.5rem;
            color: #ddd;
            transition: 0.3s;
            cursor: pointer;
            text-decoration: none;
        }
        .fav-link.active { color: #ff4d94; }
        .fav-link:hover { transform: scale(1.2); }

    </style>
</head>
<body>
    <canvas id="canvas"></canvas>

    <div class="result-card">
        <div style="text-align: right; margin-bottom: -30px;">
            <c:choose>
                <c:when test="${isLiked}">
                    <a href="BookmarkServlet?questionId=${question.id}&action=remove" class="fav-link active" title="お気に入り解除"><i class='bx bxs-heart'></i></a>
                </c:when>
                <c:otherwise>
                    <a href="BookmarkServlet?questionId=${question.id}&action=add" class="fav-link" title="お気に入り登録"><i class='bx bx-heart'></i></a>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="result-mark">
            <c:choose>
                <c:when test="${isCorrect}">
                    <span style="color: #2ecc71;">○</span>
                </c:when>
                <c:otherwise>
                    <span style="color: #e74c3c;">×</span>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="result-title" style="color: ${isCorrect ? '#2ecc71' : '#e74c3c'};">
            ${isCorrect ? '正解です！' : '不正解です'}
        </div>

        <div class="info-grid">
            <div class="info-item">
                <span class="info-label">あなたの回答</span>
                <span class="info-val"><c:out value="${userAnswer}" /></span>
            </div>
            <c:if test="${!isCorrect}">
                <div class="info-item" style="border-color: rgba(0,122,255,0.2);">
                    <span class="info-label">正解</span>
                    <span class="info-val correct"><c:out value="${question.answer}" /></span>
                </div>
            </c:if>
        </div>

        <c:if test="${not empty question.explanation}">
            <div class="explanation">
                <strong style="color: #d4a017;"><i class='bx bxs-info-circle'></i> 解説</strong><br>
                <c:out value="${question.explanation}" />
            </div>
        </c:if>

        <div class="actions">
            <c:if test="${not empty nextQuestionId}">
                <a href="AnswerServlet?id=${nextQuestionId}" class="btn btn-main">次の問題へ</a>
            </c:if>
            <a href="main.jsp" class="btn btn-sub">メニューへ戻る</a>
        </div>
    </div>

    <script>
        /** 舞い散る和紙（紙吹雪）アニメーション **/
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        let particles = [];

        function resize() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        }
        window.addEventListener('resize', resize);
        resize();

        class Particle {
            constructor() { this.init(); }
            init() {
                this.x = Math.random() * canvas.width;
                this.y = -20;
                this.w = Math.random() * 8 + 4;
                this.h = Math.random() * 8 + 4;
                this.velX = (Math.random() - 0.5) * 2;
                this.velY = Math.random() * 1.5 + 1;
                this.rot = Math.random() * 360;
                this.rotVel = (Math.random() - 0.5) * 5;
                // 和風なパステルカラー
                const colors = ['#e1f5fe', '#fff9c4', '#fce4ec', '#f1f8e9', '#e0f2f1'];
                this.color = colors[Math.floor(Math.random() * colors.length)];
                this.opacity = Math.random() * 0.5 + 0.3;
            }
            update() {
                this.x += this.velX + Math.sin(this.y * 0.02);
                this.y += this.velY;
                this.rot += this.rotVel;
                if (this.y > canvas.height) this.init();
            }
            draw() {
                ctx.save();
                ctx.translate(this.x, this.y);
                ctx.rotate(this.rot * Math.PI / 180);
                ctx.globalAlpha = this.opacity;
                ctx.fillStyle = this.color;
                ctx.fillRect(-this.w/2, -this.h/2, this.w, this.h);
                ctx.restore();
            }
        }

        for (let i = 0; i < 40; i++) particles.push(new Particle());

        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            particles.forEach(p => { p.update(); p.draw(); });
            requestAnimationFrame(animate);
        }
        animate();
    </script>
</body>
</html>
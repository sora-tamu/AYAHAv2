<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Question" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% 
    Question q = (Question) request.getAttribute("question"); 
    List<String> shuffledChoices = (List<String>) request.getAttribute("shuffledChoices");
    request.setAttribute("q", q);
    request.setAttribute("shuffledChoices", shuffledChoices);
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>問題に挑戦 - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;500;700&display=swap">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Noto Sans JP', sans-serif;
            display: flex; justify-content: center; align-items: center; min-height: 100vh;
            background-color: #f8f9fa;
            overflow: hidden; color: #333;
        }

        #canvas { position: fixed; top: 0; left: 0; z-index: -1; background: #fff; }

        .container {
            position: relative;
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(10px);
            padding: 50px;
            border-radius: 40px;
            width: 90%;
            max-width: 650px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.3);
            animation: fadeIn 0.8s ease-out;
            z-index: 10;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .header-meta {
            display: flex; justify-content: space-between; align-items: center;
            font-size: 0.85rem; color: #888;
            margin-bottom: 25px; letter-spacing: 0.1em;
            border-bottom: 1px solid #eee; padding-bottom: 15px;
        }

        h2 {
            font-size: 1.5rem; font-weight: 700; margin-bottom: 30px;
            color: #222; line-height: 1.4;
        }

        .question-content {
            background: #fff;
            padding: 40px; border-radius: 20px;
            margin-bottom: 40px; font-size: 1.2rem;
            line-height: 2; color: #444;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.02);
            border-left: 6px solid #007aff;
        }

        input[type="text"] {
            width: 100%; padding: 15px 0; background: transparent;
            border: none; border-bottom: 2px solid #ddd;
            color: #333; font-size: 1.4rem; margin-bottom: 40px;
            transition: 0.3s;
        }
        input[type="text"]:focus {
            outline: none; border-bottom-color: #007aff;
        }

        .btn-submit {
            width: 100%; padding: 18px;
            background: #007aff; border: none; color: #fff;
            font-weight: 700; font-size: 1rem; cursor: pointer;
            border-radius: 50px; transition: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            letter-spacing: 2px;
        }
        .btn-submit:hover {
            background: #0056b3; transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 122, 255, 0.3);
        }

        .choice-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        .btn-choice {
            padding: 20px; background: #fff;
            border: 1px solid #eee; color: #555;
            cursor: pointer; border-radius: 15px;
            font-size: 1rem; transition: 0.3s;
            font-weight: 500;
        }
        .btn-choice:hover {
            border-color: #007aff; color: #007aff;
            background: rgba(0, 122, 255, 0.02);
            transform: scale(1.02);
        }

        .ox-group { display: flex; justify-content: center; gap: 80px; margin-bottom: 40px; }
        .ox-label {
            cursor: pointer; font-size: 3.5rem; color: #ddd;
            transition: 0.4s;
        }
        input[type="radio"]:checked + .ox-label {
            color: #007aff; transform: translateY(-5px); text-shadow: 0 10px 20px rgba(0, 122, 255, 0.2);
        }
        input[type="radio"] { display: none; }
    </style>
</head>
<body>
    <canvas id="canvas"></canvas>

    <div class="container">
        <div class="header-meta">
            <span>正解率: <fmt:formatNumber value="${q.clearRate}" pattern="0.0" />%</span>
            <span>NO: <c:out value="${q.id}" /></span>
        </div>

        <h2><c:out value="${q.title}" /></h2>
        
        <div class="question-content"><c:out value="${q.content}" /></div>

        <form action="AnswerServlet" method="POST">
            <input type="hidden" name="id" value="${q.id}">
            
            <c:choose>
                <c:when test="${q.type == '○×'}">
                    <div class="ox-group">
                        <label>
                            <input type="radio" name="userAnswer" value="○" required>
                            <span class="ox-label">○</span>
                        </label>
                        <label>
                            <input type="radio" name="userAnswer" value="×" required>
                            <span class="ox-label">×</span>
                        </label>
                    </div>
                    <button type="submit" class="btn-submit">回答を送信する</button>
                </c:when>

                <c:when test="${q.type == '複数選択' && not empty shuffledChoices}">
                    <div class="choice-grid">
                        <c:forEach var="choice" items="${shuffledChoices}">
                            <button type="submit" name="userAnswer" value="<c:out value='${choice}' />" class="btn-choice">
                                <c:out value="${choice}" />
                            </button>
                        </c:forEach>
                    </div>
                </c:when>

                <c:otherwise>
                    <input type="text" name="userAnswer" placeholder="答えを入力してください" required autocomplete="off">
                    <button type="submit" class="btn-submit">回答を送信する</button>
                </c:otherwise>
            </c:choose>
        </form>
    </div>

    <jsp:include page="memo_popup.jsp" />

    <script>
        /** 水面の波紋アニメーション（JSPエラー回避版） **/
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        let ripples = [];

        function resize() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        }
        window.addEventListener('resize', resize);
        resize();

        class Ripple {
            constructor() {
                this.init();
            }
            init() {
                this.x = Math.random() * canvas.width;
                this.y = Math.random() * canvas.height;
                this.r = 0;
                this.maxR = Math.random() * 100 + 50;
                this.opacity = 1;
                this.speed = Math.random() * 0.5 + 0.2;
            }
            draw() {
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
                // JSPのEL式エラーを回避するため文字列を連結
                ctx.strokeStyle = 'rgba(0, 122, 255, ' + (this.opacity * 0.2) + ')';
                ctx.lineWidth = 2;
                ctx.stroke();
            }
            update() {
                this.r += this.speed;
                this.opacity -= 0.002;
                if (this.opacity <= 0) this.init();
            }
        }

        for (let i = 0; i < 15; i++) ripples.push(new Ripple());

        function animate() {
            ctx.fillStyle = '#f8f9fa';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            ripples.forEach(r => {
                r.update();
                r.draw();
            });
            requestAnimationFrame(animate);
        }
        animate();
    </script>
</body>
</html>
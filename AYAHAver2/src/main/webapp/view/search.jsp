<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Playlist, model.User, dao.BookmarkDAO, util.DBManager" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    User loginUser = (User) session.getAttribute("loginUser");
    String dbRealPath = application.getRealPath("/WEB-INF/db/main_v3.db");
    DBManager.setRealPath(dbRealPath);
    BookmarkDAO bDAO = new BookmarkDAO();
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SNS問題検索 - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Nunito:wght@200..1000&display=swap">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: "Nunito", "Meiryo", sans-serif;
        }

        body {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            /* 背景を少し暗くして文字を浮かび上がらせる */
            background: linear-gradient(rgba(5, 5, 16, 0.6), rgba(5, 5, 16, 0.6)), 
                        url('${pageContext.request.contextPath}/images/bg-galaxy.jpg') no-repeat center center fixed;
            background-size: cover;
            color: #fff;
            overflow: hidden;
            padding: 20px;
        }

        .container {
            width: 100%;
            max-width: 700px;
            /* 背景画像に馴染む深い色の半透明 */
            background: rgba(10, 10, 30, 0.4);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 30px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.7);
            animation: containerFadeIn 1s ease-out;
        }

        @keyframes containerFadeIn {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }

        h2 {
            font-size: 2.2rem;
            text-align: center;
            margin-bottom: 35px;
            font-weight: 300;
            letter-spacing: 4px;
            color: #fff;
            text-shadow: 0 0 15px rgba(0, 212, 255, 0.6);
        }

        .search-form {
            display: flex;
            gap: 15px;
            margin-bottom: 35px;
        }

        .input-box {
            position: relative;
            flex: 1;
        }

        .input-box input {
            width: 100%;
            padding: 15px 20px 15px 50px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 12px;
            outline: none;
            color: #fff;
            font-size: 1rem;
            transition: 0.3s;
        }

        .input-box input:focus {
            background: rgba(255, 255, 255, 0.1);
            border-color: #00d4ff;
            box-shadow: 0 0 15px rgba(0, 212, 255, 0.2);
        }

        .input-box i {
            position: absolute;
            left: 18px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 1.4rem;
            color: #00d4ff;
        }

        /* 3D Search Button */
        .btn-search {
            padding: 0 30px;
            background: #fff;
            color: #050510;
            border: none;
            border-radius: 12px;
            font-weight: 700;
            cursor: pointer;
            position: relative;
            box-shadow: 0 4px 0 #bbb;
            transition: 0.1s;
        }

        .btn-search:active {
            transform: translateY(3px);
            box-shadow: 0 1px 0 #bbb;
        }

        /* Result Items (Cards) */
        .result-list {
            max-height: 400px;
            overflow-y: auto;
            padding-right: 10px;
        }

        .result-item {
            background: rgba(255, 255, 255, 0.03);
            border-left: 4px solid transparent;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: 0.3s;
        }

        .result-item:hover {
            background: rgba(255, 255, 255, 0.08);
            border-left-color: #00d4ff;
            transform: translateX(5px);
        }

        .result-title {
            font-size: 1.1rem;
            color: #e0e0e0;
            text-decoration: none;
            font-weight: 600;
            display: block;
            margin-bottom: 5px;
        }

        /* 3D Save Button */
        .btn-solve {
            display: inline-block;
            background: linear-gradient(135deg, #00d4ff, #008cff);
            color: #fff;
            padding: 10px 25px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 700;
            position: relative;
            box-shadow: 0 4px 0 #005f99;
            transition: 0.1s;
            border: none;
        }

        .btn-solve:active {
            transform: translateY(3px);
            box-shadow: 0 1px 0 #005f99;
        }

        /* Wave Effect */
        .ripple {
            position: absolute;
            background: rgba(255, 255, 255, 0.4);
            border-radius: 50%;
            transform: scale(0);
            animation: rippleAni 0.6s linear;
            pointer-events: none;
        }

        @keyframes rippleAni {
            to { transform: scale(4); opacity: 0; }
        }

        /* Links */
        .fav-action a { transition: 0.3s; }
        .fav-action a:hover { opacity: 0.7; }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-top: 30px;
            color: rgba(255, 255, 255, 0.5);
            text-decoration: none;
            font-size: 0.9rem;
        }

        .back-link:hover { color: #fff; }

        /* Scrollbar */
        .result-list::-webkit-scrollbar { width: 4px; }
        .result-list::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.2); border-radius: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <h2>SNS問題検索</h2>
        
        <form action="${pageContext.request.contextPath}/view/SearchServlet" method="get" class="search-form">
            <div class="input-box">
                <i class='bx bx-search'></i>
                <input type="text" name="keyword" value="<c:out value='${lastKeyword}' />" placeholder="探索キーワード...">
            </div>
            <button type="submit" class="btn-search ripple-btn">検索</button>
        </form>

        <div class="result-list">
            <c:forEach var="p" items="${searchResults}">
                <%
                    Playlist pVar = (Playlist)pageContext.getAttribute("p");
                    boolean isLiked = (loginUser != null) ? bDAO.isBookmarked(loginUser.getId(), pVar.getId()) : false;
                    request.setAttribute("isLiked", isLiked);
                %>
                <div class="result-item">
                    <div>
                        <a href="PlaylistDetailServlet?playlistId=${p.id}" class="result-title">
                            <c:out value="${p.name}" />
                        </a>
                        <div class="fav-action">
                            <c:choose>
                                <c:when test="${isLiked}">
                                    <a href="BookmarkServlet?questionId=${p.id}&action=remove" style="color: #ff4d94; text-decoration: none; font-size: 0.85rem;">
                                        <i class='bx bxs-heart'></i> お気に入り解除
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a href="BookmarkServlet?questionId=${p.id}&action=add" style="color: rgba(255,255,255,0.4); text-decoration: none; font-size: 0.85rem;">
                                        <i class='bx bx-heart'></i> お気に入りに追加
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <a href="StartPlaylistServlet?id=${p.id}" class="btn-solve ripple-btn">解く</a>
                </div>
            </c:forEach>
        </div>
        
        <div style="text-align: center;">
            <a href="main.jsp" class="back-link">
                <i class='bx bx-arrow-back'></i> メインメニュー
            </a>
        </div>
    </div>

    <script>
        document.querySelectorAll('.ripple-btn').forEach(button => {
            button.addEventListener('click', function(e) {
                let ripple = document.createElement('span');
                ripple.className = 'ripple';
                this.appendChild(ripple);
                let x = e.clientX - e.target.offsetLeft;
                let y = e.clientY - e.target.offsetTop;
                ripple.style.left = x + 'px';
                ripple.style.top = y + 'px';
                setTimeout(() => ripple.remove(), 600);
            });
        });
    </script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>マイページ - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', sans-serif; 
            background: #050510; 
            color: #fff; 
            display: flex; 
            justify-content: center;
            padding-bottom: 70px; /* ボトムナビ用の余白 */
        }
        .feed { width: 100%; max-width: 600px; border-left: 1px solid #333; border-right: 1px solid #333; min-height: 100vh; background: rgba(15,23,42,0.9); }
        .header { padding: 15px; border-bottom: 1px solid #333; display: flex; align-items: center; gap: 20px; position: sticky; top: 0; background: rgba(15,23,42,0.95); z-index: 10; backdrop-filter: blur(10px); }
        .profile-area { padding: 30px 20px; text-align: center; border-bottom: 1px solid #333; }
        .tabs { display: flex; border-bottom: 1px solid #333; }
        .tab { flex: 1; padding: 15px; text-align: center; cursor: pointer; color: #64748b; font-weight: bold; transition: 0.3s; }
        .tab.active { color: #1d9bf0; border-bottom: 3px solid #1d9bf0; }
        
        .content-section { display: none; }
        .content-section.active { display: block; }
        
        /* 投稿カードのデザインをTimelineと統一 */
        .post-card { padding: 15px; border-bottom: 1px solid #333; position: relative; display: flex; gap: 12px; }
        .post-img { width: 100%; border-radius: 12px; margin-top: 10px; border: 1px solid #333; }
        .back-btn { color: #fff; text-decoration: none; font-size: 1.5rem; }
        
        /* 削除ボタン */
        .delete-btn { position: absolute; top: 15px; right: 15px; color: #64748b; text-decoration: none; font-size: 1.2rem; transition: 0.2s; }
        .delete-btn:hover { color: #ef4444; }

        /* プレイリスト枠 */
        .pl-card { background: rgba(29, 155, 240, 0.1); border: 1px solid rgba(29, 155, 240, 0.3); padding: 12px; border-radius: 10px; margin-top: 10px; cursor: pointer; }

        /* ボトムナビゲーション */
        .bottom-nav { position: fixed; bottom: 0; width: 100%; max-width: 600px; background: rgba(15, 23, 42, 0.95); backdrop-filter: blur(10px); display: flex; justify-content: space-around; padding: 10px 0; border-top: 1px solid #333; z-index: 100; }
        .nav-item { color: #64748b; text-decoration: none; display: flex; flex-direction: column; align-items: center; font-size: 0.7rem; }
        .nav-item i { font-size: 1.5rem; margin-bottom: 2px; }
        .nav-item.active { color: #1d9bf0; }
    </style>
</head>
<body>
    <div class="feed">
        <div class="header">
            <a href="TimelineServlet" class="back-btn"><i class='bx bx-left-arrow-alt'></i></a>
            <span style="font-size: 1.2rem; font-weight: bold;">マイページ</span>
        </div>

        <div class="profile-area">
            <div style="width:80px; height:80px; background:#1d9bf0; border-radius:50%; margin:0 auto 15px; display:flex; align-items:center; justify-content:center; font-size:2.5rem; box-shadow: 0 0 20px rgba(29,155,240,0.3);">
                <i class='bx bxs-user'></i>
            </div>
            <h2 style="font-size: 1.4rem;"><c:out value="${loginUser.name}" /></h2>
            <p style="color:#64748b;">@user_${loginUser.id}</p>
        </div>

        <div class="tabs">
            <div class="tab active" onclick="switchTab('my-posts', this)">自分の投稿</div>
            <div class="tab" onclick="switchTab('liked-posts', this)">いいね</div>
        </div>

        <%-- 自分の投稿セクション --%>
        <div id="my-posts" class="content-section active">
            <c:forEach var="p" items="${myPlaylists}">
                <div class="post-card">
                    <div style="width:40px; height:40px; background:#444; border-radius:50%; display:flex; align-items:center; justify-content:center; flex-shrink:0;"><i class='bx bxs-user'></i></div>
                    <div style="flex:1;">
                        <div style="font-weight:bold;"><c:out value="${loginUser.name}" /> <span style="font-weight:normal; color:#64748b;">@user_${loginUser.id}</span></div>
                        
                        <div style="margin-top:5px; white-space: pre-wrap;"><c:out value="${p.description}" /></div>
                        
                        <c:if test="${not empty p.imagePath}">
                            <img src="${pageContext.request.contextPath}/uploads/${p.imagePath}" class="post-img">
                        </c:if>

                        <c:if test="${not empty p.name}">
                            <div class="pl-card" onclick="location.href='StartPlaylistServlet?id=${p.id}'">
                                <i class='bx bx-list-ul'></i> <strong><c:out value="${p.name}" /></strong>
                                <div style="font-size: 0.8rem; color: #64748b;">${p.questionCount} 問の問題が含まれています</div>
                            </div>
                        </c:if>
                        
                        <div style="margin-top:10px; color:#64748b; font-size:0.9rem;">
                            <i class='bx bx-heart'></i> ${p.bookmarkCount}
                        </div>
                    </div>
                    
                    <%-- 削除ボタン --%>
                    <a href="DeletePlaylistServlet?id=${p.id}" class="delete-btn" onclick="return confirm('この投稿を削除しますか？')">
                        <i class='bx bx-trash'></i>
                    </a>
                </div>
            </c:forEach>
            <c:if test="${empty myPlaylists}">
                <div style="padding:40px; text-align:center; color:#64748b;">まだ投稿がありません</div>
            </c:if>
        </div>

        <%-- いいねした投稿セクション --%>
        <div id="liked-posts" class="content-section">
            <c:forEach var="p" items="${bookmarkedPlaylists}">
                <div class="post-card">
                    <div style="width:40px; height:40px; background:#444; border-radius:50%; display:flex; align-items:center; justify-content:center; flex-shrink:0;"><i class='bx bxs-user'></i></div>
                    <div style="flex:1;">
                        <div style="font-weight:bold;"><c:out value="${p.userName}" /> <span style="font-weight:normal; color:#64748b;">@user_${p.userId}</span></div>
                        <div style="margin-top:5px;"><c:out value="${p.description}" /></div>
                        <c:if test="${not empty p.imagePath}">
                            <img src="${pageContext.request.contextPath}/uploads/${p.imagePath}" class="post-img">
                        </c:if>
                        <div style="color:#f43f5e; margin-top:10px;"><i class='bx bxs-heart'></i> ${p.bookmarkCount}</div>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty bookmarkedPlaylists}">
                <div style="padding:40px; text-align:center; color:#64748b;">いいねした投稿はありません</div>
            </c:if>
        </div>
    </div>

    <div class="bottom-nav">
        <a href="TimelineServlet" class="nav-item">
            <i class='bx bxs-home'></i><span>ホーム</span>
        </a>
        <a href="SearchServlet" class="nav-item">
            <i class='bx bx-search'></i><span>探す</span>
        </a>
        <a href="TimelineServlet#top" class="nav-item">
            <i class='bx bxs-plus-square'></i><span>投稿</span>
        </a>
        <a href="MyPageServlet" class="nav-item active">
            <i class='bx bxs-user'></i><span>マイページ</span>
        </a>
    </div>

    <script>
    function switchTab(tabId, el) {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.content-section').forEach(c => c.classList.remove('active'));
        el.classList.add('active');
        document.getElementById(tabId).classList.add('active');
    }
    </script>
</body>
</html>
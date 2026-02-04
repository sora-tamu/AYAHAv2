package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookmarkDAO;
import dao.QuestionDAO;
import model.Playlist;
import model.User;

@WebServlet("/view/MyPageServlet")
public class MyPageServlet extends HttpServlet {
    private QuestionDAO qDAO = new QuestionDAO();
    private BookmarkDAO bDAO = new BookmarkDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");

        // ログインチェック：セッションにユーザーがいれば、ここは無視されます
        if (loginUser == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        // --- ログイン済みの場合はここから下の処理が動く ---
        
        // 自分が作成した投稿
        List<Playlist> myPlaylists = qDAO.getMyPlaylists(loginUser.getId());
        
        // 自分が「いいね」した投稿（BookmarkDAOから取得するように修正済み）
        List<Playlist> bookmarkedPlaylists = bDAO.getBookmarkedPlaylists(loginUser.getId());

        request.setAttribute("myPlaylists", myPlaylists);
        request.setAttribute("bookmarkedPlaylists", bookmarkedPlaylists);
        
        // ログイン画面（login.jsp）ではなく、直接マイページ（mypage.jsp）を表示
        request.getRequestDispatcher("mypage.jsp").forward(request, response);
    }
}
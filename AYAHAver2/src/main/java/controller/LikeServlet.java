package controller;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookmarkDAO;
import dao.QuestionDAO;
import model.User;

@WebServlet("/view/LikeServlet")
public class LikeServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        
        // ログインしていない場合はエラーを返す
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int playlistId = Integer.parseInt(request.getParameter("id"));
        BookmarkDAO bDAO = new BookmarkDAO();
        QuestionDAO qDAO = new QuestionDAO();
        
        boolean isLiked;
        // BookmarkDAOに checkBookmark(userId, playlistId) メソッドがある前提
        if (bDAO.isBookmarked(user.getId(), playlistId)) {
            bDAO.removeBookmark(user.getId(), playlistId);
            isLiked = false;
        } else {
            bDAO.addBookmark(user.getId(), playlistId);
            isLiked = true;
        }
        
        // 最新のカウントを取得
        int newCount = qDAO.getBookmarkCount(playlistId);
        
        // JavaScriptが読み取れる形式（JSON）でレスポンスを生成
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"newCount\":" + newCount + ", \"isLiked\":" + isLiked + "}");
        out.flush();
    }
}
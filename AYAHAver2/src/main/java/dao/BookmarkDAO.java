package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Playlist;
import util.DBManager;

public class BookmarkDAO {

    public BookmarkDAO() {
        try (Connection conn = DBManager.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // カラム名を playlist_id に統一して作成 [cite: 5]
            stmt.execute("CREATE TABLE IF NOT EXISTS bookmark_table (" +
                         "user_id INTEGER, " +
                         "playlist_id INTEGER, " +
                         "PRIMARY KEY (user_id, playlist_id))");
                         
        } catch (SQLException e) {
            System.err.println("BookmarkDAO初期化エラー: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void addBookmark(int userId, int playlistId) {
        String sql = "INSERT OR IGNORE INTO bookmark_table (user_id, playlist_id) VALUES (?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, playlistId);
            pstmt.executeUpdate();
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
    }

    public void removeBookmark(int userId, int playlistId) {
        String sql = "DELETE FROM bookmark_table WHERE user_id = ? AND playlist_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, playlistId);
            pstmt.executeUpdate();
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
    }

    public boolean isBookmarked(int userId, int playlistId) {
        String sql = "SELECT 1 FROM bookmark_table WHERE user_id = ? AND playlist_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, playlistId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) { 
            return false; 
        }
    }

    public List<Playlist> getBookmarkedPlaylists(int userId) {
        List<Playlist> list = new ArrayList<>();
        // playlist_table と結合して、画像パスや説明文も取得できるように修正 
        String sql = "SELECT p.* FROM playlist_table p " +
                     "INNER JOIN bookmark_table b ON p.id = b.playlist_id " +
                     "WHERE b.user_id = ?";
        
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Playlist p = new Playlist();
                    p.setId(rs.getInt("id"));
                    p.setName(rs.getString("name"));
                    p.setDescription(rs.getString("description"));
                    p.setImagePath(rs.getString("image_path"));
                    p.setUserId(rs.getInt("user_id"));
                    list.add(p);
                }
            }
        } catch (SQLException e) { 
            System.err.println("ブックマーク取得エラー: " + e.getMessage());
            e.printStackTrace(); 
        }
        return list;
    }
}
# Tomcat 10（Jakarta EE対応版）を使用
FROM tomcat:10.1-jdk17-temurin

# 1. デフォルトのアプリを削除
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# 2. あなたのプロジェクトのソースをTomcatへコピー
# ※src/main/webapp の部分は、実際のフォルダ名に合わせてください
COPY ./src/main/webapp /usr/local/tomcat/webapps/ROOT

# 3. DBフォルダ（WEB-INF/db）に書き込み権限を与える
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/db && \
    chmod -R 777 /usr/local/tomcat/webapps/ROOT/WEB-INF/db

EXPOSE 8080
CMD ["catalina.sh", "run"]
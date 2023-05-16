<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>

<%
	//ANSI코드
	final String BG_YELLOW = "\u001B[43m";
	final String RESET = "\u001B[0m";
	
	// 1. 컨트롤러 계층
	// 로그인 상관 없이 이 페이지에 접근 가능 -> 세션 유효성 검사 하지 않음
	// 요청값: category(String)
	request.setCharacterEncoding("utf-8");
	
	// 요청값 유효성 검사: 요청값이 null이면 Form으로 리다이렉션
	String msg = null;
	if(request.getParameter("category") == null) {
		msg = URLEncoder.encode("잘못된 접근입니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/category/categoryForm.jsp?msg="+msg);
		return;
	} // 확인완료
	
	String category = request.getParameter("category");
	
	// 2. 모델 계층
	// 삭제하고자 하는 카테고리가 설정된 게시물이 0인 경우 삭제 -> local_name이 category인 board의 수
	// 입력된 값 불러오기
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String sql = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	int boardCnt = 0;
	
	// 해당 카테고리를 사용 중인 게시물의 수
	// SELECT COUNT(*) cnt FROM board WHERE local_name = ?
	sql = "SELECT COUNT(*) cnt FROM board WHERE local_name = ?";
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, category);
	System.out.println(BG_YELLOW + stmt + " <--deleteCategoryAction.jsp" + RESET);
	rs = stmt.executeQuery();
	// ResultSet이 있으면 boardCnt에 대입
	if(rs.next()){
		boardCnt = rs.getInt("cnt");
	}
	System.out.println(boardCnt + " <--deleteCategoryAction boardCnt");
	
	// boardCnt가 0이면 DB에서 해당 데이터 삭제, 0보다 크면 Form으로 리다이렉션
	// 삭제 쿼리실행을 위한 변수 선언
	String deleteSql = null;
	PreparedStatement deleteStmt = null;
	int deleteRow = 0;
	
	deleteSql = "DELETE FROM local WHERE local_name = ?";
	deleteStmt = conn.prepareStatement(deleteSql);
	deleteStmt.setString(1, category);
	
	if(boardCnt > 0){
		msg = URLEncoder.encode("해당 카테고리는 사용 중이므로 삭제할 수 없습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/category/categoryForm.jsp?msg="+msg);
	} else {
		deleteRow = deleteStmt.executeUpdate();
		System.out.println(deleteRow + " <--deleteCategoryAction deleteRow");
		msg = URLEncoder.encode("카테고리가 삭제되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/category/categoryForm.jsp?msg="+msg);
	}
%>
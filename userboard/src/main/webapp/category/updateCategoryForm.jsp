<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>

<%
	//ANSI코드
	final String BG_YELLOW = "\u001B[43m";
	final String RESET = "\u001B[0m";
	
	// 1. 컨트롤러 계층
	// 해당페이지는 로그인 관계없이 접근 가능 -> 세션 유효성 검사 없음
	// 요청값: category(String)
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
	
	// 2. 모델계층
	// 해당 카테고리를 사용중인 게시물이 있다면 수정 불가, Form으로 리다이렉션
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
	System.out.println(BG_YELLOW + stmt + " <--updateCategoryForm.jsp" + RESET);
	rs = stmt.executeQuery();
	// ResultSet이 있으면 boardCnt에 대입
	if(rs.next()){
		boardCnt = rs.getInt("cnt");
	}
	System.out.println(boardCnt + " <--deleteCategoryAction boardCnt");
	
	// boardCnt가 0보다 크면 Form으로 리다이렉션
	if(boardCnt > 0){
		msg = URLEncoder.encode("해당 카테고리는 사용 중이므로 수정할 수 없습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/category/categoryForm.jsp?msg="+msg);
	} 
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>updateCategoryForm</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container-fluid pt-3">
	<!-- 메인메뉴(가로) -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<h1>카테고리 수정</h1>
	
	<!-- 리다이렉션 메시지 -->
	<!-- 리다이렉션 메시지 -->
	<div>
	<%
		if(request.getParameter("msg") != null){
	%>
			<span class="alert alert-danger"><%=request.getParameter("msg")%></span>
	<%
		}
	%>
	</div>
	
	<!-- 수정 폼 -->
	<form action="<%=request.getContextPath()%>/category/updateCategoryAction.jsp" method="post" class="form-group">
		<table>
			<tr>
				<td>
					<input type="hidden" name="category" value="<%=category%>" class="form-item">
					<input type="text" name="newCategory" value="<%=category%>" class="form-item">
				</td>
			</tr>
		</table>
		<div class="my-2">
			<button type="submit" class="btn btn-warning">수정</button>
		</div>
	</form>
	
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div>
		<jsp:include page="/inc/copyright.jsp"></jsp:include><!-- 자주쓰는 자바코드를 jsp에 포함시킴(액션태그) -> 현재는 외부 라이브러리에서 가져와서 사용(커스텀 태그) -->
		<!-- a태그, 리다이렉션은 클라이언트가 호출하는 것, 여기선 내부에서 호출하는 것이므로 request.getContextPat()를 붙일 필요가 없다 -->
	</div>
</div>
</body>
</html>
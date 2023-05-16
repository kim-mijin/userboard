<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>

<%
	// 카테고리 항목인 local를 출력
	// 로그인 여부에 관계없이 카테고리를 수정, 삭제할 수 있으므로 세션 유효성 검사는 하지 않는다
	
	// 뷰에 출력할 데이터 불러오기
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

	sql = "SELECT local_name localName FROM local";
	stmt = conn.prepareStatement(sql);
	rs = stmt.executeQuery();
	
	// ResultSet -> ArrayList로 바꾸기
	ArrayList<String> categoryList = new ArrayList<String>();
	while(rs.next()){
		String c = new String();
		c = rs.getString("localName");
		categoryList.add(c);
	}
	System.out.println(categoryList.size() + " <--categoryForm categoryList.size()"); // 결과: 9
	
%>

<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>categoryForm</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container-fluid pt-3">
	<!-- 메인메뉴(가로) -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<!-- localName항목, 추가, 수정삭제 버튼 -->
	<h1>카테고리 설정</h1>
	
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
	
	<div>
		<form action="<%=request.getContextPath()%>/category/insertCategoryAction.jsp" class="form-group">
			<table class="table">
				<thead class="thead-light">
					<tr>
						<th>카테고리 (<%=categoryList.size()%>개)</th>
						<th colspan="2">설정</th>
						<!-- <th>삭제</th> -->
					</tr>
				</thead>
			<%
				for(String c : categoryList){
			%>
					<tr>
						<td><%=c%></td>
						<td>
							<a href="<%=request.getContextPath()%>/category/updateCategoryForm.jsp?category=<%=c%>" class="badge badge-warning text-white">수정</a>
						</td>
						<td>
							<a href="<%=request.getContextPath()%>/category/deleteCategoryAction.jsp?category=<%=c%>" class="badge badge-warning text-white">삭제</a>
						</td>
					</tr>
			<%
				}
			%>
				<tr>
					<td>
						<input type="text" name="category" class="form-item">
					</td>
					<td colspan="2">
						<button type="submit" class="btn btn-warning">추가</button>
					</td>
					<!-- <td></td> -->
				</tr>
			</table>
		</form>
	</div>
	
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div class="text-center">
		<jsp:include page="/inc/copyright.jsp"></jsp:include><!-- 자주쓰는 자바코드를 jsp에 포함시킴(액션태그) -> 현재는 외부 라이브러리에서 가져와서 사용(커스텀 태그) -->
		<!-- a태그, 리다이렉션은 클라이언트가 호출하는 것, 여기선 내부에서 호출하는 것이므로 request.getContextPat()를 붙일 필요가 없다 -->
	</div>
</div>
</body>
</html>
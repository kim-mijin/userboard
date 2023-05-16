<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="vo.*" %>
<%
	//ANSI코드
	final String BG_YELLOW = "\u001B[43m";
	final String RESET = "\u001B[0m";

	//1. 컨트롤러 계층
	//세션 유효성 검사: 로그인 한 사람만 게시글 작성 가능
	String msg = null;
	if(session.getAttribute("loginMemberId") == null){
		msg = URLEncoder.encode("로그인 후 이용해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		return;
	}
	// 게시글 작성자 변수에 저장
	Object o = session.getAttribute("loginMemberId");
	String loginMemberId = null;
	if(o instanceof String){
		loginMemberId = (String)o; 
	}
	System.out.println(loginMemberId + " <--addBoard loginMemberId");
	
	//2. 모델계층
	// 뷰에서 localName 선택-> localName목록
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String localSql = null;
	PreparedStatement localStmt = null;
	ResultSet localRs = null;
	localSql = "SELECT local_name localName FROM local";
	localStmt = conn.prepareStatement(localSql);
	localRs = localStmt.executeQuery();
	
	//ResultSet -> ArrayList
	ArrayList<String> localList = new ArrayList<String>();
	while(localRs.next()){
		String s = localRs.getString("localName");
		localList.add(s);		
	}
	System.out.println(localList.size() + " <--addBoard localList.size()");
	
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>addBoard</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container-fluid">
	<!-- 메인메뉴(가로) -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<h1>게시글 작성</h1>

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
	
	<!----------------------작성 폼 ------------------------------>
	<div>
	<form action="<%=request.getContextPath()%>/board/addBoardAction.jsp" method="post">
		<table class="table table-bordered">
			<tr><!-- 1행 -->
				<th>카테고리</th>
				<td>
					<select name="localName">
						<option value="" disabled>==선택==</option>
						<%
							for(String s : localList){
						%>
							<option value="<%=s%>"><%=s%></option>
						<%
							}
						%>
					</select>
				</td>
			</tr>
			<tr><!-- 2행 -->
				<th>제목</th>
				<td>
					<input type="text" name="boardTitle">
				</td>
			</tr>
			<tr><!-- 3행 -->
				<th>내용</th>
				<td>
					<textarea rows="10" cols="30" name="boardContent"></textarea>
				</td>
			</tr>
			<tr><!-- 4행 -->
				<th>작성자</th>
				<td>
					<input type="text" value="<%=loginMemberId%>" name="memberId" readonly>
				</td>
			</tr>
		</table>
		<button class="btn btn-warning" type="submit">작성하기</button>
	</form>
	</div>
	
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div class="text-center">
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</div>
</body>
</html>
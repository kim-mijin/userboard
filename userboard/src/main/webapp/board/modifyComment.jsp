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
	// 세션 유효성 검사
	String msg = null;
	if(session.getAttribute("loginMemberId") == null){
		msg = URLEncoder.encode("로그인 후 이용해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		return;
	}
	Object o = session.getAttribute("loginMemberId");
	String loginMemberId = null;
	if(o instanceof String){
		loginMemberId = (String)o;
	}
	System.out.println(loginMemberId + " <--removeComment loginMemberId");
	
	// 요청값: boardNo(int), memberId(String), commentNo(int)
	if(request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")
		|| request.getParameter("memberId") == null || request.getParameter("memberId").equals("")){
		msg = URLEncoder.encode("잘못된 접근입니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		return;
	}
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	String memberId = request.getParameter("memberId");
	System.out.println(boardNo + " <--modifyComment boardNo");
	System.out.println(memberId + " <--modifyComment memberId");
	
	if (request.getParameter("commentNo") == null || request.getParameter("commentNo").equals("")){
		msg = URLEncoder.encode("댓글번호를 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
		return;
	}
	int commentNo = Integer.parseInt(request.getParameter("commentNo"));
	System.out.println(commentNo + " <--modifyComment commentNo");
	
	// loginMeberId와 memberId다르면 수정 불가
	if(!loginMemberId.equals(memberId)){
		msg = URLEncoder.encode("작성자가 아니므로 댓글을 수정할 수 없습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
		return;
	}
	
	// 2. 모델계층
	// 기존 작성된 댓글 내용 불러오기
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String cmtSql = null;
	PreparedStatement cmtStmt = null;
	ResultSet cmtRs = null;

	cmtSql = "SELECT board_no boardNo, comment_no commentNo, comment_content commentContent, member_id memberId "
				+ "FROM comment WHERE comment_no = ?";
	cmtStmt = conn.prepareStatement(cmtSql);
	cmtStmt.setInt(1, commentNo);
	System.out.println(BG_YELLOW + cmtStmt + " <--modifyComment cmtStmt" + RESET);
	cmtRs = cmtStmt.executeQuery();
	
	// ResultSet -> Comment
	Comment comment = null;
	if(cmtRs.next()){
		comment = new Comment();
		comment.setBoardNo(cmtRs.getInt("boardNo"));
		comment.setCommentNo(cmtRs.getInt("commentNo"));
		comment.setCommentContent(cmtRs.getString("commentContent"));
		comment.setMemberId(cmtRs.getString("memberId"));
	}
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>modifyComment</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container-fluid">
	<!-- 메인메뉴(가로) -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
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
	
	<h1>댓글 수정</h1>
	<form action="<%=request.getContextPath()%>/board/modifyCommentAction.jsp" method="post" class="form-group">
		<table>
			<tr><!-- 1행 -->
				<th><label for="boardNo">게시글 번호</label></th>
				<td>
					<input type="text" name="boardNo" value="<%=comment.getBoardNo()%>" readonly id="boardNo" class="form-item">
				</td>
			</tr>
			<tr><!-- 2행 -->
				<th><label for="commentNo">댓글번호</label></th>
				<td>
					<input type="text" name="commentNo" value="<%=comment.getCommentNo()%>" readonly id="commentNo" class="form-item">
				</td>
			</tr>
			<tr><!-- 3행 -->
				<th><label for="commentContent">내용</label></th>
				<td>
					<textarea rows="2" cols="35" name="commentContent" id="commentContent" class="form-item"><%=comment.getCommentContent()%></textarea>
				</td>
			</tr>
			<tr>
				<th><label for="memberId">작성자</label></th>
				<td>
					<input type="text" name="memberId" value="<%=comment.getMemberId()%>" readonly id="memberId" class="form-action">
				</td>
			</tr>
		</table>
		<div class="my-2">
			<button class="btn btn-warning" type="submit">수정하기</button>
		</div>
	</form>
	
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div class="text-center">
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</div>
</body>
</html>
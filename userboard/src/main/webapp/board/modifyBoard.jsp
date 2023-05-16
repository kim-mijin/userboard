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
	//세션 유효성 검사
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
	System.out.println(loginMemberId + " <--modifyBoard loginMemberId");
	
	// 요청값: boardNo(int)
	if(request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")
		|| request.getParameter("memberId") == null || request.getParameter("memberId").equals("")){
		msg = URLEncoder.encode("잘못된 접근입니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		return;
	}
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	String memberId = request.getParameter("memberId");
	System.out.println(boardNo + " <--modifyBoard boardNo");
	System.out.println(memberId + " <--modifyBoard memberId");
	
	// loginMeberId와 memberId다르면 수정 불가
	if(!loginMemberId.equals(memberId)){
		msg = URLEncoder.encode("작성자가 아니므로 수정할 수 없습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
		return;
	}
	
	//2. 모델계층
	// 기존 정보 불러오기
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String boardSql = null;
	PreparedStatement boardStmt = null;
	ResultSet boardRs = null;
	boardSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId "
				+ "FROM board WHERE board_no = ?";
	boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setInt(1, boardNo);
	System.out.println(boardStmt + " <--modifyBoard boardStmt");
	boardRs = boardStmt.executeQuery();
	
	// ResultSet -> Board
	Board board = null;
	if(boardRs.next()){
		board = new Board();
		board.setBoardNo(boardRs.getInt("boardNo"));
		board.setLocalName(boardRs.getString("localName"));
		board.setBoardTitle(boardRs.getString("boardTitle"));
		board.setBoardContent(boardRs.getString("boardContent"));
		board.setMemberId(boardRs.getString("memberId"));
	}
	
	// localName 리스트
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
	System.out.println(localList.size() + " <--modifyBoard localList.size()");
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
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
	
	<!----------------------------------수정폼 -------------------------------------------->
	<h1>게시글 수정</h1>
	<div class="my-2">
	<form action="<%=request.getContextPath()%>/board/modifyBoardAction.jsp" method="post" class="form-group">
		<table class="table">
			<tr><!-- 1행 -->
				<th><label for="boardNo">게시글번호</label></th>
				<td>
					<input type="text" name="boardNo" value=<%=board.getBoardNo()%> readonly id="boardNo" class="form-item">
				</td>
			</tr>
			<tr><!-- 2행 -->
				<th><label for="localName">카테고리</label></th>
				<td>
					<select name="localName" id="localName" class="form-item">
						<option value="" disabled>==선택==</option>
						<%
							for(String s : localList){
								if(board.getLocalName().equals(s)){
						%>
									<option value="<%=s%>" selected><%=s%></option>
						<%
								} else {
						%>
									<option value="<%=s%>"><%=s%></option>
						<%
								}
							}
						%>
					</select>
				</td>
			</tr>
			<tr><!-- 3행 -->
				<th><label for="boardTitle">제목</label></th>
				<td>
					<input type="text" name="boardTitle" value="<%=board.getBoardTitle()%>" id="boardTitle" class="form-item">
				</td>
			</tr>
			<tr><!-- 4행 -->
				<th><label for="boardContent">내용</label></th>
				<td>
					<textarea rows="10" cols="30" name="boardContent" id="boardContent" class="form-item"><%=board.getBoardContent()%></textarea>
				</td>
			</tr>
			<tr><!-- 5행 -->
				<th><label for="memberId">작성자</label></th>
				<td>
					<input type="text" value="<%=board.getMemberId()%>" name="memberId" readonly id="memberId" class="form-item">
				</td>
			</tr>
		</table>
		<div>
			<button class="btn btn-warning" type="submit">수정하기</button>
		</div>
	</form>
	</div>
	
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div class="text-center">
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</div>
</body>
</html>
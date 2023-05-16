<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>

<% 
	// 안시코드
	final String GREEN = "\u001B[32m";
	final String RESET = "\u001B[0m";
	
	// 1. 컨트롤러계층
	// 요청분석: 로그인 여부 관계 없이 상세페이지 read가능
	// 1) 요청값 확인 (boardNo: String->int / )
	System.out.println(request.getParameter("boardNo") + " <--boardOne param boardNo"); 
	System.out.println(request.getParameter("currentPage") + " <--boardOne param currentPage"); 
	
	// 2) 유효성 검사: null이거나 공백이면 home으로 리다이렉션 후 코드진행 종료
	String msg = null;
	if(request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")){
		msg = URLEncoder.encode("잘못된 접근입니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	
	int currentPage = 1;
	int rowPerPage = 10;
	if(request.getParameter("currentPage") != null && !request.getParameter("currentPage").equals("")){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	System.out.println(currentPage + " <--boardOne currentPage");
	int startRow = (currentPage - 1)*rowPerPage;
	
	// 2. 모델 계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 2-1) board one 결과셋
	PreparedStatement boardStmt = null;
	ResultSet boardRs = null;
	String boardSql = null;
	
	/*
		SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate, updatedate
		FROM board
		WHERE board_no = ?
	*/
	boardSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate, updatedate FROM board WHERE board_no = ?";
	boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setInt(1, boardNo);
	System.out.println(GREEN + boardStmt + " <--boardOne boardStmt" + RESET);
	boardRs = boardStmt.executeQuery();
	
	// 모델: 게시글 상세내용->1개->ArrayList가 아닌 Board타입으로 저장
	Board board = null; // Board는 있으면 만들기 때문에 new연산자로 만들어놓지 않는다
	if(boardRs.next()){
		board = new Board();
		board.setBoardNo(boardRs.getInt("boardNo"));
		board.setLocalName(boardRs.getString("localName"));
		board.setBoardTitle(boardRs.getString("boardTitle"));
		board.setBoardContent(boardRs.getString("boardContent"));
		board.setMemberId(boardRs.getString("memberId"));
		board.setCreatedate(boardRs.getString("createdate"));
		board.setUpdatedate(boardRs.getString("updatedate"));
	}
	System.out.println(GREEN + board + " <-- boardOne board" + RESET); // 1개 예상->1개
	
	// 2-2) comment list결과셋
	PreparedStatement commentListStmt = null;
	ResultSet commentListRs = null;
	String commentListSql = null;
	
	/*
		SELECT comment_no commentNo, board_no boardNo, comment_content commentContent
		FROM comment
		WHERE board_no = ?
		ORDER BY createdate DESC
		LIMIT ?, ?
	*/
	commentListSql = "SELECT comment_no commentNo, board_no boardNo, comment_content commentContent, member_id memberId, createdate, updatedate FROM comment WHERE board_no = ? ORDER BY createdate DESC LIMIT ?, ?";
	commentListStmt = conn.prepareStatement(commentListSql);
	commentListStmt.setInt(1, boardNo);
	commentListStmt.setInt(2, startRow);
	commentListStmt.setInt(3, rowPerPage);
	System.out.println(GREEN + commentListStmt + " <-- boardOne commentListStmt" + RESET); 
	commentListRs = commentListStmt.executeQuery(); // 최대 10개 예상(rowPerPage= 10)
	
	// ResultSet -> ArrayList
	ArrayList<Comment> commentList = new ArrayList<Comment>();
	while(commentListRs.next()){
		Comment c = new Comment();
		c.setCommentNo(commentListRs.getInt("commentNo"));
		c.setBoardNo(commentListRs.getInt("boardNo"));
		c.setCommentContent(commentListRs.getString("commentContent"));
		c.setMemberId(commentListRs.getString("memberId"));
		c.setCreatedate(commentListRs.getString("createdate"));
		c.setUpdatedate(commentListRs.getString("updatedate"));
		commentList.add(c);
	}
	System.out.println(commentList.size() + " <--boardOne commentList.size()");
	
	// 2-3)Pagination
	/*
		SELECT COUNT(*) FROM board
		WHERE local_name=?
	*/
	String pageSql = null;
	PreparedStatement pageStmt = null;
	ResultSet pageRs = null;
	
	pageSql = "SELECT COUNT(*) FROM comment where board_no=?";
	pageStmt = conn.prepareStatement(pageSql);
	pageStmt.setInt(1, boardNo);
	System.out.println(GREEN + pageStmt + " <--boardOne pageStmt" + RESET);
	pageRs = pageStmt.executeQuery();
	
	int lastPage = 0;
	int totalCount = 0;
	if(pageRs.next()){
		totalCount=pageRs.getInt("COUNT(*)");
	}
	System.out.println(totalCount + " <--boardOne totalCount");
	
	if(totalCount % rowPerPage == 0){
		lastPage = totalCount / rowPerPage;
	} else {
		lastPage = (totalCount / rowPerPage) + 1;
	}
	System.out.println(lastPage + " <--boardOne lastPage");
	
	/*
	currentPage	1	2	3
	startPage	1	11	21	-> (currentPage-1)*pageLength + 1
	endPage		10	20	30	-> currentPage + pageLength -1
	*/
	int pageLength = 10; // 한 블럭에 들어가는 페이지 개수
	int currentBlock = 1; // 현재 페이지가 속한 블럭
	if(currentPage % pageLength == 0){ // currentPage가 pageLength로 나누어떨어지면 currentBlock은 그 몫
		currentBlock = currentPage / pageLength; 
	} else { // 나누어 떨어지지 않으면 몫+1
		currentBlock = currentPage / pageLength + 1;
	}
	System.out.println(currentBlock + " <-- currentBlock");
	
	int startPage = 1 + (currentBlock-1)*pageLength; // 페이지 블럭의 시작 페이지
	int endPage = startPage + pageLength - 1; // 페이지 블럭의 마지막 페이지
	// 만약 endPage가 총 페이지(lastPage)보다 크면 endPage = lastPage
	int totalPages = 0;
	if(totalCount % rowPerPage == 0){
		totalPages = totalCount / rowPerPage;
	} else {
		totalPages = totalCount / rowPerPage + 1;
	}
	System.out.println(totalPages + " <--boardOne totalPages");
	
	if (endPage > totalPages){
		endPage = totalPages;
	}
	System.out.println(endPage + " <--boardOne endPage");
	
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>boardOne</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>

<body>
<div class="container-fluid pt-3 pb-3">
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
	<!-------------------------------------------------[시작] 게시글------------------------------------------------------------>
	<!-- 3-1) board one 결과셋 -->
	<div class="my-2">
	<h1>상세내용</h1>
		<table class="table table-bordered">
			<tr>
				<th>번호</th><!-- 1행 -->
				<td><%=board.getBoardNo()%></td>
			</tr>
			<tr>
				<th>지역</th><!-- 2행 -->
				<td><%=board.getLocalName()%></td>
			</tr>
			<tr>
				<th>제목</th><!-- 3행 -->
				<td><%=board.getBoardTitle()%></td>
			</tr>
			<tr>
				<th>본문</th><!-- 4행 -->
				<td><%=board.getBoardContent()%></td>
			</tr>
			<tr>
				<th>작성자</th><!-- 5행 -->
				<td><%=board.getMemberId()%></td>
			</tr>
			<tr>
				<th>작성일</th><!-- 6행 -->
				<td><%=board.getCreatedate()%></td>
			</tr>
			<tr>
				<th>수정일</th><!-- 7행 -->
				<td><%=board.getUpdatedate()%></td>
			</tr>
		</table>
	</div>
	
	<!-- 수정, 삭제 버튼 -->
	<div>
		<a href="<%=request.getContextPath()%>/board/modifyBoard.jsp?boardNo=<%=board.getBoardNo()%>&memberId=<%=board.getMemberId()%>" class="btn btn-warning">수정</a>
		<a href="<%=request.getContextPath()%>/board/removeBoardAction.jsp?boardNo=<%=board.getBoardNo()%>&memberId=<%=board.getMemberId()%>" class="btn btn-warning">삭제</a>
	</div>
	<br>
	
	<!-- 3-2) comment 입력 : 세션유무에 따른 분기 -->
	<%
		// 로그인 사용자만 댓글 입력 허용
		if(session.getAttribute("loginMemberId") != null){
			// 현재 로그인 사용자의 ID
			String loginMemberId = (String)session.getAttribute("loginMemberId");
	%>
			<form action="<%=request.getContextPath()%>/board/insertCommentAction.jsp" method="post" class="form-group">
				<!-- boardNo와 memberId는 입력값이 없기 때문에 hidden으로 넘긴다 -->
				<input type="hidden" name="boardNo" value="<%=board.getBoardNo()%>">
				<input type="hidden" name="memberId" value="<%=loginMemberId%>">
				<table>
					<tr>
						<th><label for="commentContent">댓글</label></th>
						<td>
							<textarea rows="2" cols="80" name="commentContent" id="commentContent" class="form-item"></textarea>
						</td>
						<td>
							<button type="submit" class="btn btn-warning">댓글입력</button>
						</td>
					</tr>
				</table>
			</form>
	<%
		}
	%>
	<br>
	
	<!-- 3-3) comment list 결과셋 -->	
	<table class="table table-bordered">
		<thead class="thead-ligth">
			<tr>
				<th>내용</th>
				<th>작성자</th>
				<th>작성일</th>
				<th>수정일</th>
				<th>수정</th>
				<th>삭제</th>
			</tr>
		</thead>
	
	<%
		for(Comment c : commentList){
	%>
			<tr>
				<td><%=c.getCommentContent()%></td>
				<td><%=c.getMemberId()%></td>
				<td><%=c.getCreatedate()%></td>
				<td><%=c.getUpdatedate()%></td>
				<td><a href="<%=request.getContextPath()%>/board/modifyComment.jsp?boardNo=<%=board.getBoardNo()%>&memberId=<%=c.getMemberId()%>&commentNo=<%=c.getCommentNo()%>" class="btn btn-warning btn-sm">수정</a></td>
				<td><a href="<%=request.getContextPath()%>/board/removeCommentAction.jsp?boardNo=<%=board.getBoardNo()%>&memberId=<%=c.getMemberId()%>&commentNo=<%=c.getCommentNo()%>"  class="btn btn-warning btn-sm">삭제</a></td>
			</tr>
	<%
		}
	%>
	</table>
	
	<!------------- 페이지 ----------------->
		<div class="d-flex justify-content-center">
			<ul class="pagination">
				<li class="page-item"><!-- 처음 -->
					<a class="page-link" href="<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=1&boardNo=<%=boardNo%>">처음</a>
				</li>
				<%	
					// 이전
					// startPage가 1인 경우(즉, pageBlock=1) '이전' 비활성화
					if(startPage == 1){
				%>
						<li class="page-item disabled">
							<a class="page-link" href="#" aria-disabled="true">이전</a>
						</li>
				<%
					} else {
				%>
						<li class="page-item">
							<a class="page-link" href="<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=<%=startPage-1%>&boardNo=<%=boardNo%>">이전</a>
						</li>
				<%
					}
				%>
				<%
					// 페이지 번호
					for(int i=startPage; i<=endPage; i+=1){
						if(i == currentPage){ // 현재 페이지 표시하기 (.active)
				%>
						<li class="page-item active"><a class="page-link" href="<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=<%=i%>&boardNo=<%=boardNo%>"><%=i%></a></li>
				<%
						} else{
				%>		
						<li class="page-item"><a class="page-link" href="<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=<%=i%>&boardNo=<%=boardNo%>"><%=i%></a></li>
				<%
						}
					}
				%>
				<%	
					// 다음
					// endPage == totalPages 경우(즉, 마지막페이지블럭) 이전 나오지 않음
					if(endPage == totalPages){
				%>
						<li class="page-item disabled">
							<a class="page-link" href="#" aria-disabled="true">다음</a>
						</li>
				<%
					} else {
				%>
						<li class="page-item">
							<a class="page-link" href="<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=<%=endPage+1%>&boardNo=<%=boardNo%>">다음</a>
						</li>
				<%
					}
				%>
				<li class="page-item"><!-- 마지막 -->
					<a class="page-link" href="<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=<%=lastPage%>&boardNo=<%=boardNo%>">마지막</a>
				</li>
			</ul>
		</div>
	<!-------------------------------------------------[끝] 게시글------------------------------------------------------------>
	
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div class="text-center">
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</div>
</body>
</html>
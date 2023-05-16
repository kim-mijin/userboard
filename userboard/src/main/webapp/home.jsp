<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	// ANSI코드
	final String BG_YELLOW = "\u001B[43m";
	final String RESET = "\u001B[0m";
	
	// 1. 요청분석(컨트롤러 계층)
	// 1) session JSP내장(기본)객체(내장된 객체변수(참조변수): built in object ex)request, response, session, page...)
	
	// 2) request / response JSP 내장(기본)객체
	// 요청값: localName(String), currentPage, rowPerPage
	// 요청값이 잘 들어오는지 확인
	System.out.println(request.getParameter("localName") + " <--home param localName"); // null->null, 광명->광명
	System.out.println(request.getParameter("currentPage") + " <--home param currentPage");
	System.out.println(request.getParameter("rowPerPage") + " <--home param rowPerPage");
		
	// 요청값 유효성 검사
	// currentPage: null이거나 공백이면 1페이지를 보여주고 나머지는 요청값을 변수에 저장한다
	int currentPage = 1;
	if(request.getParameter("currentPage") != null && !request.getParameter("currentPage").equals("")){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	System.out.println(currentPage + " <--home currentPage"); // null->1
	
	// rowPerPage: null이거나 공백이면 기본 10, 나머지는 요청값(5,10,15,30)
	int rowPerPage = 10;
	if(request.getParameter("rowPerPage") != null && !request.getParameter("rowPerPage").equals("")){
		rowPerPage = Integer.parseInt(request.getParameter("rowPerPage"));
	}
	System.out.println(rowPerPage + " <--home rowPerPage"); // null->10
	
	int startRow = (currentPage - 1)*rowPerPage;
	
	// localName: null이면 전체를 보여주고(초기값을 전체로 설정), 나머지는 요청값을 변수에 저장한다
	String localName = "전체"; 
	if(request.getParameter("localName") != null){
		localName = request.getParameter("localName");
	}
	System.out.println(localName + " <--home localName"); // null->전체
	
	// 2. 모델 계층
	// DB에서 데이터 가져오기
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 1) 서브메뉴 결과셋
	/*
		SELECT '전체' localName, COUNT(local_name) cnt FROM board
		UNION all
		SELECT local_name, COUNT(local_name) FROM board GROUP BY local_name
		UNION ALL 
		SELECT local_name, 0 FROM local WHERE local_name NOT IN (SELECT local_name FROM board)
		// 게시물이 없는 카테고리는 local에서 받아서 게시글에 0을 넣는다
	*/
	String subMenuSql = null;
	PreparedStatement subMenuStmt = null;
	ResultSet subMenuRs = null;
	
	subMenuSql = "SELECT '전체' localName, COUNT(local_name) cnt FROM board " 
					+ "UNION All SELECT local_name, COUNT(local_name) FROM board GROUP BY local_name "
					+ "UNION ALL SELECT local_name, 0 FROM local WHERE local_name NOT IN (SELECT local_name FROM board)";
	subMenuStmt = conn.prepareStatement(subMenuSql);
	subMenuRs = subMenuStmt.executeQuery();
	
	// 모델데이터 subMenuList
	ArrayList<HashMap<String, Object>> subMenuList = new ArrayList<HashMap<String, Object>>();
	while(subMenuRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("localName", subMenuRs.getString("localName"));
		m.put("cnt", subMenuRs.getInt("cnt"));
		subMenuList.add(m);	
	}
	System.out.println(subMenuList.size() + " <--home subMenuList.size()");
	
	// 2) 보드리스트 결과셋
	/*
		동적쿼리
		SELECT board_no boardNo, local_name localName, board_title boardTitle, createdate
		FROM board
		WHERE local_name = ?
		ORDER BY board DESC
		LIMIT ?, ?
	*/
	String boardSql = null;
	PreparedStatement boardStmt = null;
	ResultSet boardRs = null;
	
	// localName이 전체인 경우에는 전체 리스트를 보여주고 나머지의 경우는 localName에 따른 리스트를 보여준다
	if(localName.equals("전체")){
		boardSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, createdate FROM board ORDER BY board_no DESC LIMIT ?, ?";
		boardStmt = conn.prepareStatement(boardSql);
		boardStmt.setInt(1, startRow);
		boardStmt.setInt(2, rowPerPage);
	} else {
		boardSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, createdate FROM board WHERE local_name = ? ORDER BY board_no DESC LIMIT ?, ?";
		boardStmt = conn.prepareStatement(boardSql);
		boardStmt.setString(1, localName);
		boardStmt.setInt(2, startRow);
		boardStmt.setInt(3, rowPerPage);
	}
	System.out.println(BG_YELLOW + boardStmt + " <--home boardStmt" + RESET);
	boardRs = boardStmt.executeQuery();
	
	// 모델데이터 boardList
	ArrayList<Board> boardList = new ArrayList<Board>(); 
	// Board타입의 ArrayList를 만든다 -> ArrayList의 사이즈가 중요하기 때문에 null이 아니라 new연산자로 미리 만들어둔다 (사이즈가 0인 ArrayList)
	while(boardRs.next()){
		Board b = new Board();
		b.setBoardNo(boardRs.getInt("boardNo")); // boardNo필드는 private -> boardRs의 boardNo를 읽어와서 b의 boardNo에 넣는다 
		b.setLocalName(boardRs.getString("localName"));
		b.setBoardTitle(boardRs.getString("boardTitle"));
		b.setCreatedate(boardRs.getString("createdate"));
		boardList.add(b);
	}
	System.out.println(boardList + " <--home boardList"); // ArrayList는 각자 참조하는 주소를 보여준다
	System.out.println(BG_YELLOW + boardList.size() + " <--home boardList.size()" + RESET);

	// 3) Pagination
	/*
		SELECT COUNT(*) FROM board
		WHERE local_name=?
	*/
	String pageSql = null;
	PreparedStatement pageStmt = null;
	ResultSet pageRs = null;
	
	if(localName.equals("전체")){
		pageSql = "SELECT COUNT(*) FROM board";
		pageStmt = conn.prepareStatement(pageSql);
	} else{
		pageSql = "SELECT COUNT(*) FROM board WHERE local_name=?";
		pageStmt = conn.prepareStatement(pageSql);
		pageStmt.setString(1, localName);
	}
	System.out.println(BG_YELLOW + pageStmt + " <--home pageStmt" + RESET);
	pageRs = pageStmt.executeQuery();
	
	int lastPage = 0;
	int totalCount = 0;
	if(pageRs.next()){
		totalCount = pageRs.getInt("COUNT(*)");
	}
	System.out.println(totalCount + " <--home totalCount");
	
	if(totalCount % rowPerPage == 0){
		lastPage = totalCount / rowPerPage;
	} else {
		lastPage = (totalCount / rowPerPage) + 1;
	}
	System.out.println(lastPage + " <--home lastPage");
	
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
	System.out.println(currentBlock + " <--home currentBlock");
	
	int startPage = 1 + (currentBlock-1)*pageLength; // 페이지 블럭의 시작 페이지
	int endPage = startPage + pageLength - 1; // 페이지 블럭의 마지막 페이지
	// 만약 endPage가 총 페이지(lastPage)보다 크면 endPage = lastPage
	int totalPages = 0;
	if(totalCount % rowPerPage == 0){
		totalPages = totalCount / rowPerPage;
	} else {
		totalPages = totalCount / rowPerPage + 1;
	}
	System.out.println(totalPages + " <--home totalPages");
	
	if (endPage > totalPages){
		endPage = totalPages;
	}
	System.out.println(endPage + " <--home endPage");
%>

<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>home</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container-fluid pt-3 pb-3">
	<%
		// 원본코드
		// request.getRequestDispatcher(request.getContextPath()+"./inc/copyright.jsp").include(request, response); 
		// jsp파일을 합치는 방법: include(A, B 둘다 보여짐 -> 합칠 때 request, response 공유하게 됨), forward(A, B합치면 A가 숨겨짐)
		// 이 코드를 액션태그로 변경하면 아래와 같다
	%>
	<div class="jumbotron jumbotron-fluid">
	  <div class="container">
	    <h1>User Board 프로젝트</h1>      
	    	<ul>
	    		<li>2023.05.02~2023.05.15</li>
	    		<li>Java17, HTML, CSS, MariaDB</li>
	    		<li>로그인, 로그아웃, 회원가입, 회원정보 수정<br>
	    			게시글, 댓글, 카테고리 CRUD<br>
	    			게시글 목록 페이징
	    		</li>
	    	</ul>
	  </div>
	</div>
	
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
	
	
	<div class="row">
	<div class="col-3">
	<div class="d-flex flex-column">
		<!-- 로그인 폼 -->
		<div class="p-2">
			<%
				if(session.getAttribute("loginMemberId") == null){ // 로그인 전이면 로그인 폼 출력
			%>
					<form action = "<%=request.getContextPath()%>/member/loginAction.jsp" method="post" class="form-signin"><!-- 웹기반의 절대주소  => /web0502/loginAction.jsp-->
						<h2 class="h3 mb-3 font-weight-normal">로그인</h2>
						<table>
							<tr>
								<td><label for="id">아이디</label></td>
								<td><input type="text" name="memberId" id="id" class="form-control"></td>
							</tr>
							<tr>
								<td><label for="pw">패스워드</label></td>
								<td><input type="password" name="memberPw" id="pw" class="form-control"></td>
							</tr>
						</table>
						<div class="my-2">
							<button type="submit" class="btn btn-warning btn-block">로그인</button>
						</div>
					</form>
			<%
				}
			%>		
		</div>
		
		<!-- 서브메뉴(세로): subMenuList모델을 출력 -->
		<div class="p-2">
			<h2 style="font-size: 25px">카테고리</h2>
			<ul class="list-group">
			<%
				for(HashMap<String, Object> m : subMenuList) {
			%>
					<li class="list-group-item">
						<a href="<%=request.getContextPath()%>/home.jsp?localName=<%=(String)m.get("localName")%>">
							<%=(String)m.get("localName")%>(<%=(Integer)m.get("cnt")%>)<!-- Object타입을 String, Integer로 형변환 하는 것 잊지 않기! -->
						</a>
					</li>
			<%
				}
			%>
			</ul>
			
			<!-- 카테고리 설정 버튼 -->
			<div>
				<a href="<%=request.getContextPath()%>/category/categoryForm.jsp" class="btn btn-warning my-2">카테고리 설정</a>
			</div>
		</div>
	</div>
	</div>
	<br>
	<br>
	<!---------------------------------------[시작] 보드리스트 --------------------------------------------------------->
	<div class="col-9">
		<h2>게시판</h2>
		<!----- rowPerPage ------->
		<div class="row">
		<div class="col">
			<form action="<%=request.getContextPath()%>/home.jsp?">
				<!-- currentPage와 localName을 hidden으로 넘긴다 -->
				<input type="hidden" name="currentPage" value="<%=currentPage%>">
				<input type="hidden" name="localName" value="<%=localName%>">
				<select name="rowPerPage">
					<%
						if(rowPerPage == 5){
					%>
							<option selected="selected">5</option>
							<option>10</option>
							<option>15</option>
							<option>30</option>
					<%
						} else if (rowPerPage == 10) {
					%>
							<option>5</option>
							<option selected="selected">10</option>
							<option>15</option>
							<option>30</option>
					<%
						} else if (rowPerPage == 15){
					%>
							<option>5</option>
							<option>10</option>
							<option selected="selected">15</option>
							<option>30</option>
					<%
						} else if (rowPerPage == 30){
					%>
							<option>5</option>
							<option>10</option>
							<option>15</option>
							<option selected="selected">30</option>
					<%
						}
					%>
				</select>
			<button type="submit" class="btn btn-warning btn-sm">확인</button>
			</form>
		</div>
		
		<!---------- 게시글 추가버튼 -------------->
		<div class="col text-right">
			<a href="<%=request.getContextPath()%>/board/addBoard.jsp" class="btn btn-warning">게시글작성</a>
		</div>
		</div>
		
		<!---------- 게시글 목록 -------------->
		<div>
			<table class="table table-striped">
				<thead>
					<tr>
						<th>지역</th>
						<th>제목</th>
						<th>작성일</th>
					</tr>
				</thead>
				<tbody>
			<%
				for(Board b : boardList){
			%>
					<tr>
						<td><%=b.getLocalName()%></td>
						<td><a href="<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=b.getBoardNo()%>"><%=b.getBoardTitle()%></a></td>
						<td><%=b.getCreatedate()%></td>
					</tr>
			<%
				}
			%>
				</tbody>
			</table>
		</div>

		<!------------- 페이지 ----------------->
		<div class="d-flex justify-content-center">
			<ul class="pagination">
				<li class="page-item"><!-- 처음 -->
					<a class="page-link" href="<%=request.getContextPath()%>/home.jsp?currentPage=1&rowPerPage=<%=rowPerPage%>&localName=<%=localName%>">처음</a>
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
							<a class="page-link" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=startPage-1%>&rowPerPage=<%=rowPerPage%>&localName=<%=localName%>">이전</a>
						</li>
				<%
					}
				%>
				<%
					// 페이지 번호
					for(int i=startPage; i<=endPage; i+=1){
						if(i == currentPage){
				%>
						<li class="page-item active"><a class="page-link" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=i%>&rowPerPage=<%=rowPerPage%>&localName=<%=localName%>"><%=i%></a></li>
				<%
						}else{
				%>
						<li class="page-item"><a class="page-link" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=i%>&rowPerPage=<%=rowPerPage%>&localName=<%=localName%>"><%=i%></a></li>
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
							<a class="page-link" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=endPage+1%>&rowPerPage=<%=rowPerPage%>&localName=<%=localName%>">다음</a>
						</li>
				<%
					}
				%>
				<li class="page-item"><!-- 마지막 -->
					<a class="page-link" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=lastPage%>&rowPerPage=<%=rowPerPage%>&localName=<%=localName%>">마지막</a>
				</li>
			</ul>
		</div>
	</div>
	</div>
	<!--------------------------------------[끝] 보드리스트 -------------------------------------------------->
	
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div class="text-center">
		<jsp:include page="/inc/copyright.jsp"></jsp:include><!-- 자주쓰는 자바코드를 jsp에 포함시킴(액션태그) -> 현재는 외부 라이브러리에서 가져와서 사용(커스텀 태그) -->
		<!-- a태그, 리다이렉션은 클라이언트가 호출하는 것, 여기선 내부에서 호출하는 것이므로 request.getContextPat()를 붙일 필요가 없다 -->
	</div>
</div>
</body>
</html>
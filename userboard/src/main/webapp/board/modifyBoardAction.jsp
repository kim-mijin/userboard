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
		
	// 세션 유효성 검사: 로그인 안된 사용자는 접근 불가
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
	
	// 요청값: boardNo(int), localName(String), boardTitle(String), boardContent(String), memberId(String)
	request.setCharacterEncoding("utf-8");
	
	// 요청값 유효성 검사
	if(request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")
		|| request.getParameter("memberId") == null || request.getParameter("memberId").equals("")){
		msg = URLEncoder.encode("잘못된 접근입니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		return;
	} 
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	String memberId = request.getParameter("memberId");
	
	if(request.getParameter("localName") == null || request.getParameter("localName").equals("")
		|| request.getParameter("boardTitle") == null || request.getParameter("boardTitle").equals("")
		|| request.getParameter("boardContent") == null || request.getParameter("boardContent").equals("")){
		msg = URLEncoder.encode("수정할 내용을 작성해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/modifyBoard.jsp?boardNo="+boardNo+"&msg="+msg);
		return;
	}
	String localName = request.getParameter("localName");
	String boardTitle = request.getParameter("boardTitle");
	String boardContent = request.getParameter("boardContent");
	
	// loginMeberId와 memberId다르면 수정 불가
	if(!loginMemberId.equals(memberId)){
		msg = URLEncoder.encode("작성자가 아니므로 수정할 수 없습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
		return;
	}
	
	// 2. 모델계층 // boardNo가 일치하는 게시글 수정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String mdfSql = null;
	PreparedStatement mdfStmt = null;
	int mdfResult = 0;
	
	mdfSql = "UPDATE board SET local_name = ?, board_title = ?, board_content = ?, member_id = ?, updatedate = NOW() "
				+ "WHERE board_no = ?";
	mdfStmt = conn.prepareStatement(mdfSql);
	mdfStmt.setString(1, localName);
	mdfStmt.setString(2, boardTitle);
	mdfStmt.setString(3, boardContent);
	mdfStmt.setString(4, memberId);
	mdfStmt.setInt(5, boardNo);
	System.out.println(mdfStmt + " <--modifyBoardAction mdfStmt");
	mdfResult = mdfStmt.executeUpdate();
	
	if(mdfResult == 1){
		System.out.println(mdfResult + "modifyBoardAction mdfResult: 성공");
		msg = URLEncoder.encode("게시글이 수정되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
	} else {
		System.out.println(mdfResult + "modifyBoardAction mdfResult: 실패");
		msg = URLEncoder.encode("게시글 수정에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
	}
%>

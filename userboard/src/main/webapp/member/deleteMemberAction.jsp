<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.net.*"%>
<%@ page import = "vo.*"%>

<%
	//로그인이 되어있지 않으면 해당 페이지는 접근할 수 없다 -> home으로 리다이렉션 후 코드진행 종료
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	// ANSI코드
	final String BG_YELLOW = "\u001B[43m";
	final String RESET = "\u001B[0m";
	
	// 1. 컨트롤러 계층
	// 요청값: memberPw(String)
	// post방식 요청값 인코딩하기
	request.setCharacterEncoding("utf-8");
	
	// 요청값이 잘 넘어오는지 확인하기
	System.out.println(request.getParameter("memberPw") + " <--changePwAction param memberPw"); // 입력안했을 경우 공백 넘어옴
	
	String memberPw = "";
	String msg = null;
	// 요청값이 null이거나 공백이면 
	if(request.getParameter("memberPw") == null
			|| request.getParameter("memberPw").equals("")){
		msg = URLEncoder.encode("비밀번호를 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/deleteMemberForm.jsp");
		return;
	}
	memberPw = request.getParameter("memberPw");
	String loginId = (String)session.getAttribute("loginMemberId");
	
	// 2. 모델계층
	// DB에서 데이터 가져오기
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 현재 비밀번호와 일치하는 경우 비밀번호 변경
	String sql = null;
	PreparedStatement stmt = null;
	int row = 0;
	
	/*
		delete 
		from member
		where member_id = ? and member_pw = password(?) 
	*/
	sql = "delete from member where member_id = ? and member_pw = password(?)";
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, loginId);
	stmt.setString(2, memberPw);
	System.out.println(BG_YELLOW + stmt + " <--deleteMemberAction stmt" + RESET);
	
	row = stmt.executeUpdate(); // member_id가 외래키 설정되어있어 예외 발생 -> 일단 cascade로 변경
	System.out.println(row + " <--deleteMemberAction row");
	
	if (row == 1){
		msg = URLEncoder.encode("계정이 삭제되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		session.invalidate();
		return;
	} else {
		msg = URLEncoder.encode("비밀번호를 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/deleteMemberForm.jsp?msg="+msg);
	}
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %><!-- 메시지 한글로 보낼 때 인코딩 -->
<%@ page import = "vo.*" %>
<%
	// 세션 유효성 검사 -> 요청값 유효성 검사
	if(session.getAttribute("loginMemberId") != null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	} // 로그인 한 사람은 리다이렉션되므로 이 페이지에 들어오지 못한다
	
	//post방식 encoding
	request.setCharacterEncoding("utf-8");
	
	// 요청값 유효성 검사
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");
	// 디버깅
	System.out.println(memberId + " <--loginAction memberId");
	System.out.println(memberPw + " <--loginAction memberPw");
	
	// 디버깅이 끝나고 Member클래스로 하나로 묶기
	Member paramMember = new Member();
	paramMember.setMemberId(memberId); // Member클래스의 memberId필드는 private으로 정보은닉되어 있고, setMemberId메서드로 쓸수 있다.
	paramMember.setMemberPw(memberPw);

	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	/*
		SELECT member_id memberId FROM member 
		WHERE member_id = ? AND member_pw = PASSWORD(?)
	*/
	
	String sql = "SELECT member_id memberId from member WHERE member_id = ? AND member_pw = PASSWORD(?)";
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, paramMember.getMemberId());
	stmt.setString(2, paramMember.getMemberPw());
	System.out.println(stmt + " <--loginAction stmt");
	
	rs = stmt.executeQuery();
	if(rs.next()) { // 로그인 성공
		// 세션에 로그인 정보(memberId) 저장
		session.setAttribute("loginMemberId", rs.getString("memberId"));
		System.out.println("로그인 성공 세션정보 : " + session.getAttribute("loginMemberId"));
		
	} else { // 로그인 실패
		System.out.println("로그인 실패");
	}
	
	response.sendRedirect(request.getContextPath()+"/home.jsp");
%>
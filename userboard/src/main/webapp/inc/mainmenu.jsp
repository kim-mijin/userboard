<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<nav class="navbar navbar-expand-sm bg-light nav-bar-light">
	<ul class="navbar-nav">
		<li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/home.jsp">목록으로</a></li>
				
		<!-- 
			로그인 전 : 회원가입 
			로그인 후 : 회원정보 / 로그아웃 (로그인정보는 세션에 loginMemberId)
		-->
		<%
			if(session.getAttribute("loginMemberId") == null) { // 로그인 전
		%>
				<li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/member/insertMemberForm.jsp">회원가입</a></li><!-- css로 가로로 바꾸기 -->
		<%
			} else { // 로그인 후
		%>
				<li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/member/memberInfo.jsp">회원정보</a></li>
				<li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/member/logoutAction.jsp">로그아웃</a></li>
		<%
			}
		
			// if~else는 짧은 코드를 메인으로 적는 것이 가독성이 있다
		%>
		
	</ul>
</nav>
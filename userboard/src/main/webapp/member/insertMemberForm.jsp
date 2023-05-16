<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.net.*" %>
<%
	// 세션 유효성 검사
	String msg = null;
	if(session.getAttribute("loginMemberId") != null) { // null인 경우는 세션에 정보가 저장되지 않은 경우
		msg = URLEncoder.encode("이미 로그인 되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg); // 로그인 시 리다이렉션 확인
		return;
	}
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
<div class="container pt-3 pb-3">
	<div><!-- 메인메뉴 페이지 include -->
		<jsp:include page ="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<div class="bg-danger text-white"><!-- 리다이렉션 메시지 -->
		<%
			if(request.getParameter("msg") != null){
		%>
				<%=request.getParameter("msg")%>
		<%
			}
		%>
	</div>
	
	<div><!-- 회원가입 -->
		<h1>회원가입</h1>
		<form action = "<%=request.getContextPath()%>/member/insertMemberAction.jsp" method="post" class="form-group">
			<table>
				<tr>
					<td><label for="id">아이디</label></td>
					<td><input type="text" name="id" id="id" class="form-item"></td>
				</tr>
				<tr>
					<td><label for="id">패스워드</label></td>
					<td><input type="password" name="pw" id="pw" class="form-item"></td>
				</tr>
			</table>
			<div class="mt-2">
				<button type="submit" class="btn btn-warning">회원가입</button>
			</div>
		</form>
	</div>

	<div><!-- 카피라이트 페이지 include -->
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>

</div>
</body>
</html>
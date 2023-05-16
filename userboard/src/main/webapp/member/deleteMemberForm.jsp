<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	// 로그인이 되어있지 않으면 현재 페이지에 접근할 수 없다
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
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
<div class="container-fluid pt-3">
	<!-- 메인메뉴(가로) -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<!-- Action페이지에서 리다이렉션 되면 메시지표시 -->
	<div class="bg-danger text-white">
	<%
		if(request.getParameter("msg") != null){
	%>
			<%=request.getParameter("msg")%>
	<%
		}
	%>
	</div>
	
	<h1>회원탈퇴</h1>
	
	<!-- 회원탈퇴 비밀번호 확인 -->
	<div>
	<form action="<%=request.getContextPath()%>/member/deleteMemberAction.jsp" method="post">
		<table>
			<tr>
				<th><label for="memberPw">비밀번호 확인</label></th>
				<td>
					<input type="password" name="memberPw" id="memberPw">
				</td>
			</tr>
		</table>
		<button type="submit" class="btn btn-warning">탈퇴하기</button>
	</form>
</div>
</div>
</body>
</html>
USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[PERSONAL_FULL_SELECT]
AS
BEGIN	
	SET NOCOUNT ON;
	
	SELECT PersonalShortName, DepartmentName
	FROM dbo.PersonalTable

	UNION ALL

	SELECT ManagerName, '������������ ��������� ������'
	FROM dbo.ManagerTable

	UNION ALL

	SELECT ServiceName, '������-��������'
	FROM dbo.ServiceTable

	UNION ALL

	SELECT TeacherName, '�������������'
	FROM dbo.TeacherTable

	UNION ALL

	SELECT DutyName, '�������� ������'
	FROM dbo.DutyTable

	ORDER BY PersonalShortName
END
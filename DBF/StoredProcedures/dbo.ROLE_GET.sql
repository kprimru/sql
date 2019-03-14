USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[ROLE_GET]
	@roleid INT
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#role') IS NOT NULL
		DROP TABLE #role

	CREATE TABLE #role
		(
			DBRole VARCHAR(100),
			MemberName VARCHAR(100),
			MemberSID VARBINARY(128),
		)

	INSERT INTO #role
		EXEC sp_helprolemember

	DECLARE @rolename VARCHAR(100) 
	DECLARE @rolenote VARCHAR(500)
	DECLARE @group BIT

	SELECT @rolename = ROLE_NAME, @rolenote = ROLE_NOTE
	FROM dbo.RoleTable
	WHERE ROLE_ID = @roleid	

	IF EXISTS
		(
			SELECT * 
			FROM #role
			WHERE MemberName = @rolename
		)
	BEGIN
		--это группа
		SET @group = 1
	END
	ELSE
	BEGIN
		SET @group = 0
	END

	IF OBJECT_ID('tempdb..#role') IS NOT NULL
		DROP TABLE #role

	SELECT @rolename AS ROLE_NAME, @rolenote AS ROLE_NOTE, @group AS ROLE_GROUP
END

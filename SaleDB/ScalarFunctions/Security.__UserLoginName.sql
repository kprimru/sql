USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE FUNCTION [Security].[UserLoginName]
(
)
RETURNS NVARCHAR(128)
AS
BEGIN
	DECLARE @RES NVARCHAR(128)

	SELECT TOP 1 @RES = FLOGIN
	FROM	
		Security.LogonUsers a
		INNER JOIN sys.dm_exec_sessions b ON 
											a.SPID = b.session_id
										AND a.[HOST_NAME] = b.[host_name]
										AND a.LOGIN_NAME = b.login_name
										AND a.LOGIN_TIME = b.login_time
										AND a.HOST_PROCESS_ID = b.host_process_id
	WHERE a.SPID = @@SPID

	IF @RES IS NULL
		SET @RES = ORIGINAL_LOGIN()

	RETURN @RES
END

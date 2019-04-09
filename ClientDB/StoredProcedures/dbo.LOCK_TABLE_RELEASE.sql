USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LOCK_TABLE_RELEASE]	
	@DATA	VARCHAR(64)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.Locks		
	WHERE LC_SPID = @@SPID 
		AND LC_LOGIN = ORIGINAL_LOGIN()		
		AND EXISTS
			(
				SELECT *
				FROM sys.dm_exec_sessions 
				WHERE 
					LC_SPID		=	session_id AND
					LC_HOST		=	host_name AND
					LC_LOGIN		=	original_login_name AND
					LC_LOGIN_TIME	=	login_time
			)
		AND LC_DATA = @DATA
END
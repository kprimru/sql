USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LOCK_CLEAR]
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.Locks
	WHERE NOT EXISTS
		(
			SELECT *
			FROM sys.dm_exec_sessions 
			WHERE	LC_SPID		=	session_id AND
					LC_HOST		=	host_name AND					
					LC_LOGIN		=	original_login_name AND
					LC_LOGIN_TIME	=	login_time  			
		)
END
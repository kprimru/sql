USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[CLEAR_LOGON_USERS]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DELETE a
		FROM Security.LogonUsers a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM sys.dm_exec_sessions b
				WHERE a.SPID = b.session_id
					AND a.[HOST_NAME] = b.[host_name]
					AND a.LOGIN_NAME = b.login_name
					AND a.LOGIN_TIME = b.login_time
					AND a.HOST_PROCESS_ID = b.host_process_id
			)
	END TRY
	BEGIN CATCH
		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT 
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
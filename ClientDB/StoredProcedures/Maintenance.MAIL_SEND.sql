USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Maintenance].[MAIL_SEND]
	@TEXT	NVARCHAR(MAX)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	EXEC msdb.dbo.sp_send_dbmail 
				@profile_name	=	'SQLMail',
				@recipients		=	'denisov@bazis;blohin@bazis',
				@body			=	@TEXT,
				@subject		=	'Уведомление "Досье клиентов"',
				@query_result_header	=	0				
END
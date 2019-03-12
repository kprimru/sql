USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_TECH_WARNING]
AS
BEGIN
	SET NOCOUNT ON;	
	
	SELECT CLientID, ClientFullName, ManagerName, CLM_DATE, CLM_STATUS
	FROM 
		dbo.ClientWriteList()
		INNER JOIN dbo.ClaimTable ON CLM_ID_CLIENT = WCL_ID
		INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = CLM_ID_CLIENT
	WHERE (NOT CLM_STATUS IN  ('Отработана', 'Отклонена ответственным', 'Отменена', 'Отклонена', 'Выполнено успешно'))
		AND (IS_MEMBER('rl_tech_warning') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1)
	ORDER BY CLM_DATE DESC
END
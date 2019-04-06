USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[CLIENT_PERSONAL_SELECT] 
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	
			PER_ID, PER_FAM, PER_NAME, PER_OTCH, (PER_FAM + ' ' + PER_NAME + ' ' + PER_OTCH) AS PER_FULL_NAME, 
			POS_NAME, POS_ID, RP_ID, RP_NAME --, PER_PHONE
	FROM	
			dbo.ClientPersonalTable	cp												LEFT OUTER JOIN
			dbo.PositionTable		pt	ON cp.PER_ID_POS  = pt.POS_ID				LEFT OUTER JOIN
			dbo.ReportPositionTable	prt	ON prt.RP_ID = cp.PER_ID_REPORT_POS
	WHERE	
			PER_ID_CLIENT = @clientid
	ORDER BY
			PER_FAM, PER_NAME, PER_OTCH, POS_NAME

	SET NOCOUNT OFF
END
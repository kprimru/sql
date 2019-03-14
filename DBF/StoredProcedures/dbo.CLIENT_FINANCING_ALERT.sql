USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_FINANCING_ALERT]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT CL_ID, CL_PSEDO
	FROM 
		dbo.ClientTable INNER JOIN dbo.ClientFinancing ON ID_CLIENT = CL_ID		
	WHERE UNKNOWN_FINANCING = 1
	ORDER BY CL_PSEDO
	
END

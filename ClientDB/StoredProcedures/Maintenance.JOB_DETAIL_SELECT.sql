USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[JOB_DETAIL_SELECT]
	@ID			INT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT TOP(100) *, DATEDIFF(ms, START, FINISH) AS EX_TIME
	FROM Maintenance.Jobs
	WHERE	Type_Id=@ID
	ORDER BY START DESC
END;
USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[REG_WEIGHT_REPORT_RESTORE]
	@PR_ID	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM dbo.REG_WEIGHT_REPORT_SELECT(@PR_ID)	
END

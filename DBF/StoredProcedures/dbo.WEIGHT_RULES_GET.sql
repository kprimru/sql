USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WEIGHT_RULES_GET]
	@ID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PR_ID, PR_DATE, SYS_ID, SYS_SHORT_NAME, SST_ID, SST_CAPTION, SNC_ID, SNC_SHORT, WEIGHT
	FROM dbo.WeightRules
	INNER JOIN dbo.PeriodTable ON ID_PERIOD = PR_ID
	INNER JOIN dbo.SystemTable ON ID_SYSTEM = SYS_ID
	INNER JOIN dbo.SystemTypeTable ON ID_TYPE = SST_ID
	INNER JOIN dbo.SystemNetCountTable ON ID_NET = SNC_ID
	WHERE ID = @ID
END

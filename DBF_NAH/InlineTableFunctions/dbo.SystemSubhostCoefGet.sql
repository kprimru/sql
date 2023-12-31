USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[SystemSubhostCoefGet]
(
	@PR_DATE	SMALLDATETIME
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		SYS_ID AS SSC_ID_SYSTEM,
		(
			SELECT TOP 1 SSC_COEF
			FROM
				dbo.SystemSubhostCoef
				INNER JOIN dbo.PeriodTable ON PR_ID = SSC_ID_PERIOD
			WHERE SYS_ID = SSC_ID_SYSTEM
				AND PR_DATE <= @PR_DATE
		) AS SSC_COEF
	FROM dbo.SystemTable
)

GO

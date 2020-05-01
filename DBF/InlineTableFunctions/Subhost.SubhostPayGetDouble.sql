USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Subhost].[SubhostPayGetDouble]
(
	@START		SMALLDATETIME,
	@END		SMALLDATETIME
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		SHC_ID_SUBHOST, SHC_ID_PERIOD, SHP_ID_ORG,
		SHC_TOTAL, SHP_SUM, (SHC_TOTAL - SHP_SUM) AS DEBT
	FROM
		(
			SELECT
				SHC_ID_SUBHOST,
				SHC_ID_PERIOD,
				CASE SHP_ID_ORG
					WHEN (SELECT TOP 1 SCS_ID_ORG_STUDY FROM Subhost.SubhostCalcSettings) THEN SHC_TOTAL_STUDY
					WHEN (SELECT TOP 1 SCS_ID_ORG_SERVICE FROM Subhost.SubhostCalcSettings) THEN SHC_TOTAL
				END AS SHC_TOTAL,
				SUM(SHP_SUM) AS SHP_SUM,
				SHP_ID_ORG
			FROM
				Subhost.SubhostCalc
				INNER JOIN Subhost.SubhostPay ON SHP_ID_SUBHOST = SHC_ID_SUBHOST
				INNER JOIN Subhost.SubhostPayDetail ON SPD_ID_PAY = SHP_ID AND SPD_ID_PERIOD = SHC_ID_PERIOD

			WHERE SHP_DATE BETWEEN @START AND @END
			GROUP BY SHC_ID_SUBHOST, SHC_ID_PERIOD, SHC_TOTAL, SHC_TOTAL_STUDY, SHP_ID_ORG
			--WHERE SHC_ID_PERIOD = @PERIOD
		) AS o_O
)

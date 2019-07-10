USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[REPORT_INCOME_TOTAL]
	@begin	SMALLDATETIME,
	@end	SMALLDATETIME,
	@org	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IN_DATE, SUM(IN_SUM) AS IN_SUM
	FROM dbo.IncomeTable
	WHERE IN_DATE BETWEEN @BEGIN AND @END
		AND IN_ID_ORG = @org
	GROUP BY IN_DATE
	ORDER BY IN_DATE
END

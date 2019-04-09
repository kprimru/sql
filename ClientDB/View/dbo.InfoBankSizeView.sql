USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[InfoBankSizeView]
WITH SCHEMABINDING
AS
	SELECT IBS_DATE, IBF_ID_IB, SUM(IBS_SIZE) AS IBS_SIZE, COUNT_BIG(*) AS IBS_CNT
	FROM 
		dbo.InfoBankSize
		INNER JOIN dbo.InfoBankFile ON IBS_ID_FILE = IBF_ID
	GROUP BY IBS_DATE, IBF_ID_IB

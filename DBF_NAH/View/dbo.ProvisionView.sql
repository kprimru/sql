USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ProvisionView]
AS
	SELECT
		ID, ID_CLIENT, CL_PSEDO, DATE, PRICE, PAY_NUM, ID_ORG, ORG_PSEDO,
		DATEPART(YEAR, DATE) AS YEAR_NUM,
		ROW_NUMBER() OVER(PARTITION BY CASE WHEN PRICE > 0 THEN 1 ELSE 0 END, DATEPART(YEAR, DATE), ID_CLIENT ORDER BY DATEPART(YEAR, DATE), DATE, ID) AS RN_1,
		ROW_NUMBER() OVER(PARTITION BY CASE WHEN PRICE < 0 THEN 1 ELSE 0 END, DATEPART(YEAR, DATE), ID_CLIENT ORDER BY DATEPART(YEAR, DATE), DATE, ID) AS RN_2
	FROM
		dbo.Provision
		INNER JOIN dbo.ClientTable ON CL_ID = ID_CLIENT
		INNER JOIN dbo.OrganizationTable ON ORG_ID = ID_ORG	GO

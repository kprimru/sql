USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientClaimServiceView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientClaimServiceView]  AS SELECT 1')
GO
CREATE OR ALTER VIEW [dbo].[ClientClaimServiceView]
AS
	SELECT
		CLM_ID, CLM_DATE,
			CASE WHEN CLM_DATE >= '20130701' THEN
				(
					SELECT TOP 1 ID_SERVICE
					FROM dbo.ClientServiceView
					WHERE ID_CLIENT = CLM_ID_CLIENT
						AND dbo.DateOf(CLM_DATE) BETWEEN START AND FINISH
					ORDER BY START
				)
			ELSE
				(
					SELECT TOP 1 ID_SERVICE
					FROM dbo.CLientService
					WHERE ID_CLIENT = CLM_ID_CLIENT
					ORDER BY UPD_DATE
				)
		END AS ID_SERVICE
	FROM dbo.ClaimTableGO

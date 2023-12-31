USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[TOView]
AS
	SELECT
		COUR_ID, COUR_NAME, TO_ID, TO_ID_CLIENT, TO_NAME,
		TO_NUM, TO_REPORT, TO_VMI_COMMENT, TO_MAIN, CL_PSEDO, CL_INN, TO_INN, TO_LAST, TO_PARENT, TO_RANGE, TO_DELETED
	FROM
		dbo.ClientTable a INNER JOIN
		dbo.TOTable b ON a.CL_ID = b.TO_ID_CLIENT LEFT OUTER JOIN
		dbo.CourierTable c ON c.COUR_ID = b.TO_ID_COUR
GO

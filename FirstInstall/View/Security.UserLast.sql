USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [Security].[UserLast]
--WITH SCHEMABINDING
AS
	SELECT
		US_ID_MASTER, US_ID, US_NAME,
		US_LOGIN, US_NOTE, US_DATE, US_END, US_REF
	FROM
		Security.UserAll a
	WHERE US_REF IN (1, 3)
GO

USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Security].[UserDeleted]
--WITH SCHEMABINDING
AS
	SELECT
		US_ID_MASTER, US_ID, US_NAME,
		US_LOGIN, US_NOTE, US_DATE, US_END
	FROM
		Security.UserAll a
	WHERE US_REF = 3GO

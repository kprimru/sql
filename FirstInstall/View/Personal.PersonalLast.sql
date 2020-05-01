USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [Personal].[PersonalLast]
--WITH SCHEMABINDING
AS
	SELECT
		PER_ID_MASTER, PER_ID, PER_NAME,
		PER_ID_DEP, PER_ID_TYPE,
		PER_DATE, PER_END
	FROM
		Personal.PersonalAll a
	WHERE PER_REF IN (1, 3)
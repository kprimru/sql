﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [Personal].[PersonalAll]
--WITH SCHEMABINDING
AS
	SELECT
		PER_ID_MASTER, PER_ID, PER_NAME, PER_EMAIL,
		PER_ID_DEP, PER_ID_TYPE,
		PER_DATE, PER_END, PER_REF
	FROM
		Personal.PersonalDetail
GO

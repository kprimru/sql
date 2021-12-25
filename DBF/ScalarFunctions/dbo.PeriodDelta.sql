﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[PeriodDelta]
(
	@PR_ID	SMALLINT,
	@DELTA	SMALLINT
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @RES	SMALLINT

	SELECT @RES = PR_ID
	FROM dbo.PeriodTable
	WHERE PR_DATE =
		(
			SELECT DATEADD(MONTH, @DELTA, PR_DATE)
			FROM dbo.PeriodTable
			WHERE PR_ID = @PR_ID
		)

	RETURN @RES
END
GO

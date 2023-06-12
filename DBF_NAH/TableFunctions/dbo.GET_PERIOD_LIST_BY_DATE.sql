﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_PERIOD_LIST_BY_DATE]', 'TF') IS NULL EXEC('CREATE FUNCTION [dbo].[GET_PERIOD_LIST_BY_DATE] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO


CREATE FUNCTION [dbo].[GET_PERIOD_LIST_BY_DATE]
(@date SMALLDATETIME)
RETURNS @tbl TABLE (ITEM SMALLINT NOT NULL) AS
BEGIN
	INSERT INTO @tbl
  		SELECT PR_ID
		FROM dbo.PeriodTable
		WHERE PR_DATE <= DATEADD(MONTH, -1, @date) AND @date <= DATEADD(MONTH, 1, PR_END_DATE)


	-- Возвращение результата работы функции
	RETURN
END



GO

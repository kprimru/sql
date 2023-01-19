﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Ric].[CrisisCoefValue]', 'FN') IS NULL EXEC('CREATE FUNCTION [Ric].[CrisisCoefValue] () RETURNS Int AS BEGIN RETURN NULL END')
GO
/*
	Получение кризисного коэффициента
*/
CREATE FUNCTION [Ric].[CrisisCoefValue]
(
	@PR_ID	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES DECIMAL(10, 4)

	SET @RES = 1

	RETURN @RES
END
GO

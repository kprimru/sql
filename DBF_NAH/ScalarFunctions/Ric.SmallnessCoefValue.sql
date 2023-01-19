﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Ric].[SmallnessCoefValue]', 'FN') IS NULL EXEC('CREATE FUNCTION [Ric].[SmallnessCoefValue] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Ric].[SmallnessCoefValue]
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

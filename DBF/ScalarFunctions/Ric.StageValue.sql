USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	�����
*/
ALTER FUNCTION [Ric].[StageValue]
(
	@PR_ID	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES DECIMAL(10, 4)

	SET @RES = 2

	RETURN @RES
END
USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	/*
	Показатель нормального роста
*/
CREATE FUNCTION [Ric].[GrowStandard]
(
	@PR_ID	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES DECIMAL(10, 4)

	SET @RES = 3

	RETURN @RES
END
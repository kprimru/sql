USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	����������� ������������
*/
ALTER FUNCTION [Ric].[DepthCoefValue]
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

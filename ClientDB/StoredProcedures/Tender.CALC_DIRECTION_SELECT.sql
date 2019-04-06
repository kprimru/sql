USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[CALC_DIRECTION_SELECT]
	@FILTER	NVARCHAR(128) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME
	FROM Tender.CalcDirection
	ORDER BY NAME
END

USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Tender].[CALC_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID_DIRECTION, NAME, PRICE, NOTE, CALC_DATA
	FROM Tender.Calc
	WHERE ID = @ID
END

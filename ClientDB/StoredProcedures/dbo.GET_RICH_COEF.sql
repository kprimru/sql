USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_RICH_COEF]
AS
BEGIN
	SET NOCOUNT ON

	SELECT RichCoefStart, RichCoefEnd, RichCoefID, RichCoefVal 
	FROM dbo.RichCoefTable 
	ORDER BY RichCoefVal
END
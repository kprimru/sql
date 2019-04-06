USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RICH_COEF_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT RichCoefStart, RichCoefEnd, RichCoefVal
	FROM dbo.RichCoefTable
	WHERE RichCoefID = @ID	
END
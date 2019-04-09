USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RICH_COEF_UPDATE]
	@ID	INT,
	@START	INT,
	@END	INT,
	@VAL	DECIMAL(8, 4)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.RichCoefTable
	SET RichCoefStart = @START,
		RichCoefEnd = @END,
		RichCoefVal = @VAL,
		RichCoefLast = GETDATE()
	WHERE RichCoefID = @ID	
END
USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_WEIGHT_SELECT]
	@SYSTEM	INT,
	@PERIOD	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SystemShortName, NAME, WEIGHT, WEIGHT2, b.ID, c.SystemID
	FROM 
		dbo.SystemWeight a
		INNER JOIN Common.Period b ON a.ID_PERIOD = b.ID
		INNER JOIN dbo.SystemTable c ON a.ID_SYSTEM = c.SystemID
	WHERE (SystemID = @SYSTEM OR @SYSTEM IS NULL)
		AND (ID_PERIOD = @PERIOD OR @PERIOD IS NULL)
		AND START <= DATEADD(MONTH, 3, GETDATE())
	ORDER BY START DESC, SystemOrder
END

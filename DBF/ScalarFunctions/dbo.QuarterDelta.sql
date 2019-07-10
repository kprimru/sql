USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[QUARTER_DELTA]
(
	@QR_ID	SMALLINT,
	@DELTA	SMALLINT
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @RES SMALLINT

	SELECT @RES = QR_ID
	FROM dbo.Quarter
	WHERE QR_BEGIN = 
		(
			SELECT DATEADD(QUARTER, @DELTA, QR_BEGIN)
			FROM dbo.Quarter
			WHERE QR_ID = @QR_ID
		)

	RETURN @RES
END

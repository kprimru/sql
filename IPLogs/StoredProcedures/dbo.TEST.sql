USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TEST]
	@STR	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LEN INT
	
	SET @LEN = LEN(@STR)
	
	DECLARE @LSTR VARCHAR(50)
	
	SET @LSTR = CONVERT(VARCHAR(50), @LEN)
	
	RAISERROR(@LSTR, 16, 1)	
END

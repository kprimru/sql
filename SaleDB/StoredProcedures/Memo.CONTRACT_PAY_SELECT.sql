USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Memo].[CONTRACT_PAY_SELECT]
	@FILTER	NVARCHAR(256),
	@RC		INT	= NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	EXEC [PC275-SQL\ALPHA].ClientDB.dbo.CONTRACT_PAY_SELECT
END

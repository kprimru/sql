USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SYSTEM_BANKS_CLEAR]
	@SYS_LIST			NVARCHAR(MAX),
	@DISTR_TYPE_LIST	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @s	TABLE
	(
		System_Id	VARCHAR(5)
	)
	
	DECLARE @d	TABLE
	(
		DistrType_Id	VARCHAR(5)
	)

	
	INSERT INTO @s(System_Id)
	SELECT *
	FROM dbo.GET_STRING_TABLE_FROM_LIST(@SYS_LIST, ',')
	
	INSERT INTO @d(DistrType_Id)
	SELECT *
	FROM dbo.GET_STRING_TABLE_FROM_LIST(@DISTR_TYPE_LIST, ',')
	
	DELETE
	FROM dbo.SystemsBanks
	WHERE	System_Id IN (SELECT System_Id FROM @s) AND
			DistrType_Id IN (SELECT DistrType_Id FROM @d) 
END

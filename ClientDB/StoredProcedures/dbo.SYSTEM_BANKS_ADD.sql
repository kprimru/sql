USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_BANKS_ADD]
	@SYS_LIST				VARCHAR(MAX),
	@DISTR_TYPE_LIST		VARCHAR(MAX),
	@BANK_LIST				VARCHAR(MAX),
	@REQUIRE				BIT
AS
BEGIN
	DECLARE @s	TABLE
	(
		System_Id	VARCHAR(5)
	)
	
	DECLARE @d	TABLE
	(
		DistrType_Id	VARCHAR(5)
	)
	
	DECLARE @ib	TABLE
	(
		InfoBank_Id	VARCHAR(5)
	)

	
	INSERT INTO @s(System_Id)
	SELECT *
	FROM dbo.GET_STRING_TABLE_FROM_LIST(@SYS_LIST, ',')
	
	INSERT INTO @d(DistrType_Id)
	SELECT *
	FROM dbo.GET_STRING_TABLE_FROM_LIST(@DISTR_TYPE_LIST, ',')
	
	INSERT INTO @ib(InfoBank_Id)
	SELECT *
	FROM dbo.GET_STRING_TABLE_FROM_LIST(@BANK_LIST, ',')
	
	
	INSERT INTO dbo.SystemsBanks(System_Id, DistrType_Id, InfoBank_Id, Required, Start)
	SELECT s.System_Id, d.DistrType_Id, ib.InfoBank_Id, @REQUIRE, GETDATE()
	FROM @s s
	CROSS APPLY @d d
	CROSS APPLY @ib ib
	WHERE NOT EXISTS (
						SELECT * 
						FROM dbo.SystemsBanks sb
						WHERE	sb.System_Id = s.System_Id AND 
								sb.DistrType_Id = d.DistrType_Id AND 
								sb.InfoBank_Id = ib.InfoBank_Id
						)
	
	--SELECT * FROM @s, @d, @ib
END


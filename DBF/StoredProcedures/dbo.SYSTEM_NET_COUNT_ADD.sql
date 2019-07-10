USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[SYSTEM_NET_COUNT_ADD] 
	@systemnetid INT,
	@netcount INT,
	@TECH SMALLINT,
	@ODOFF	SMALLINT,
	@ODON	SMALLINT,
	@SHORT	VARCHAR(50),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.SystemNetCountTable(SNC_ID_SN, SNC_NET_COUNT, SNC_TECH, SNC_ACTIVE, SNC_ODON, SNC_ODOFF, SNC_SHORT) 
	VALUES (@systemnetid, @netcount, @tech, @active, @ODON, @ODOFF, @SHORT)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END








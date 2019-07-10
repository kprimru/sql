USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  */

CREATE PROCEDURE [dbo].[AREA_EDIT] 
	@areaid SMALLINT,
	@areaname VARCHAR(100),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.AreaTable 
	SET AR_NAME = @areaname,
		AR_ACTIVE = @active
	WHERE AR_ID = @areaid

	SET NOCOUNT OFF
END
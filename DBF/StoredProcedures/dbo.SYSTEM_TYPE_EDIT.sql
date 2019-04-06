USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 24.09.2008
Описание:	  Изменить данные о типе системы с 
               указанным кодом в справочнике
*/

CREATE PROCEDURE [dbo].[SYSTEM_TYPE_EDIT] 
	@systemtypeid SMALLINT,
	@systemtypename VARCHAR(20),
	@systemtypecaption VARCHAR(100),
	@systemtypelst VARCHAR(20),
	@systemtypereport BIT,
	@order SMALLINT,
	@mosid SMALLINT,
	@subid SMALLINT,
	@host SMALLINT,
	@dhost SMALLINT,
	@coef BIT,	
	@calc DECIMAL(4, 2),
	@kbu BIT,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.SystemTypeTable
	SET SST_NAME = @systemtypename,
		SST_CAPTION = @systemtypecaption,
		SST_LST = @systemtypelst,
		SST_REPORT = @systemtypereport,
		SST_ACTIVE = @active,
		SST_ORDER = @order,
		SST_ID_MOS = @mosid,
		SST_ID_SUB = @subid,
		SST_ID_HOST = @host,
		SST_ID_DHOST = @dhost,
		SST_COEF = @coef,
		SST_CALC = @calc,
		SST_KBU = @kbu
	WHERE SST_ID = @systemtypeid

	SET NOCOUNT OFF
END
﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[UNIT_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[UNIT_DELETE]  AS SELECT 1')
GO


/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Удалить технологический признак
               с указанным кодом из справочника
*/

ALTER PROCEDURE [dbo].[UNIT_DELETE]
	@unitid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DELETE
		FROM dbo.UnitTable
		WHERE UN_ID = @unitid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[UNIT_DELETE] TO rl_unit_d;
GO

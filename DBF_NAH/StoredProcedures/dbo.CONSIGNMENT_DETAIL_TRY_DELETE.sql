﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONSIGNMENT_DETAIL_TRY_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONSIGNMENT_DETAIL_TRY_DELETE]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[CONSIGNMENT_DETAIL_TRY_DELETE]
	@csdid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @res INT
		DECLARE @txt VARCHAR(1000)

		SET @res = 0
		SET @txt = ''

		SELECT @res AS RES, @txt AS TXT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_DETAIL_TRY_DELETE] TO rl_consignment_d;
GO

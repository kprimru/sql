﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INVOICE_SET_PRIMARY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INVOICE_SET_PRIMARY]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[INVOICE_SET_PRIMARY]
	@prpid INT,
	@invoiceid INT
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

		UPDATE dbo.PrimaryPayTable
		SET PRP_ID_INVOICE = @invoiceid
		WHERE PRP_ID = @prpid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INVOICE_SET_PRIMARY] TO rl_invoice_w;
GO

USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[CONSIGNMENT_DELETE]
	@csgid INT
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

		DELETE
		FROM dbo.SaldoTable
		WHERE SL_ID_CONSIG_DIS IN
				(
					SELECT CSD_ID
					FROM dbo.ConsignmentDetailTable
					WHERE CSD_ID_CONS = @csgid
				)

		DELETE
		FROM dbo.ConsignmentDetailTable
		WHERE CSD_ID_CONS = @csgid

		DELETE
		FROM dbo.ConsignmentTable
		WHERE CSG_ID = @csgid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_DELETE] TO rl_consignment_d;
GO

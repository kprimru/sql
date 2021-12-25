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

ALTER PROCEDURE [dbo].[BILL_DELIVERY]
	@billid INT,
	@clientid INT
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

		UPDATE dbo.BillTable
		SET BL_ID_CLIENT = @clientid,
			BL_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
		WHERE BL_ID = @billid

		UPDATE dbo.SaldoTable
		SET SL_ID_CLIENT = @clientid
		WHERE SL_ID_BILL_DIS IN
			(
				SELECT BD_ID
				FROM dbo.BillDistrTable
				WHERE BD_ID_BILL = @billid
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[BILL_DELIVERY] TO rl_bill_w;
GO

USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

ALTER PROCEDURE [dbo].[CLIENT_MERGE]
	@oldclient INT,
	@newclient INT
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

		-- перенести точку обслуживания к другому клиент	

		IF EXISTS
			(
				SELECT *
				FROM 
					dbo.BillDistrTable INNER JOIN
					dbo.BillTable ON BL_ID = BD_ID_BILL
				WHERE BL_ID_CLIENT = @oldclient
			)
		BEGIN
			INSERT INTO dbo.BillTable(BL_ID_CLIENT, BL_ID_PERIOD, BL_ID_ORG)
				SELECT @newclient, BL_ID_PERIOD, BL_ID_ORG
				FROM dbo.BillTable a
				WHERE BL_ID_CLIENT = @oldclient
					AND NOT EXISTS
					(
						SELECT *
						FROM dbo.BillTable b
						WHERE BL_ID_CLIENT = @newclient
							AND a.BL_ID_PERIOD = b.BL_ID_PERIOD
					)

			UPDATE dbo.BillDistrTable
			SET BD_ID_BILL =
				(
					SELECT BL_ID
					FROM 
						dbo.BillTable a
					WHERE BL_ID_CLIENT = @newclient
						AND BL_ID_PERIOD = 
							(
								SELECT BL_ID_PERIOD
								FROM dbo.BillTable
								WHERE BL_ID = BD_ID_BILL							
							)
				)
			WHERE BD_ID_BILL IN
				(
					SELECT BL_ID
					FROM dbo.BillTable
					WHERE BL_ID = BD_ID_BILL
						AND BL_ID_CLIENT = @oldclient
				)		
		END

		UPDATE dbo.ActTable
		SET ACT_ID_CLIENT = @newclient
		WHERE ACT_ID_CLIENT = @oldclient

		UPDATE dbo.BillFactMasterTable
		SET CL_ID = @newclient
		WHERE CL_ID = @oldclient

		UPDATE dbo.IncomeTable
		SET IN_ID_CLIENT = @newclient
		WHERE IN_ID_CLIENT = @oldclient

		UPDATE dbo.ConsignmentTable
		SET CSG_ID_CLIENT = @newclient
		WHERE CSG_ID_CLIENT = @oldclient
		
		UPDATE dbo.InvoiceSaleTable
		SET INS_ID_CLIENT = @newclient
		WHERE INS_ID_CLIENT = @oldclient

		UPDATE dbo.SaldoTable
		SET SL_ID_CLIENT = @newclient
		WHERE SL_ID_CLIENT = @oldclient

		UPDATE dbo.ContractTable
		SET CO_ID_CLIENT = @newclient
		WHERE CO_ID_CLIENT = @oldclient

		UPDATE dbo.TOTable
		SET TO_ID_CLIENT = @newclient
		WHERE TO_ID_CLIENT = @oldclient

		-- перенести дистрибутивы из ТО к клиенту
		UPDATE dbo.ClientDistrTable 
		SET CD_ID_CLIENT = @newclient
		WHERE CD_ID_CLIENT = @oldclient
	
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_MERGE] TO rl_client_w;
GO
USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[ACT_DELIVERY]
	@actid INT,
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

		DECLARE @OLD	INT
		
		SELECT @OLD = ACT_ID_CLIENT
		FROM dbo.ActTable
		WHERE ACT_ID = @actid
		
		DECLARE @TXT VARCHAR(MAX)
		
		SELECT @TXT = '�� "' + a.CL_FULL_NAME + '" � "' + b.CL_FULL_NAME + '"'
		FROM dbo.ClientTable a, dbo.ClientTable b
		WHERE a.CL_ID = @OLD AND b.CL_ID = @clientid

		EXEC dbo.FINANCING_PROTOCOL_ADD 'ACT', '�������� ����', @TXT, @CLIENTID, @actid
		EXEC dbo.FINANCING_PROTOCOL_ADD 'ACT', '�������� ����', @TXT, @OLD, @actid

		UPDATE dbo.ActTable
		SET ACT_ID_CLIENT = @clientid,
			ACT_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
		WHERE ACT_ID = @actid

		UPDATE dbo.InvoiceSaleTable
		SET INS_ID_CLIENT = @clientid,
			INS_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
		WHERE INS_ID = 
			(
				SELECT ACT_ID_INVOICE 
				FROM dbo.ActTable 
				WHERE ACT_ID = @actid
			)

		UPDATE dbo.SaldoTable
		SET SL_ID_CLIENT = @clientid
		WHERE SL_ID_ACT_DIS IN
			(
				SELECT AD_ID
				FROM dbo.ActDistrTable
				WHERE AD_ID_ACT = @actid
			)
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

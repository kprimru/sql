USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		выбор данных счетов-фактур, сформированных вместе
				по всем клиентам в один момент времени
*/
CREATE PROCEDURE [dbo].[INVOICE_FACT_GET]
	-- Список параметров процедуры
	@date VARCHAR(100)
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
	
		DECLARE @d DATETIME
		SET @d = CONVERT(DATETIME, @date, 121)

		SELECT
			IFM_ID,IFM_DATE,
			INS_ID,
			ORG_ID,ORG_PSEDO,ORG_FULL_NAME,ORG_SHORT_NAME,ORG_ADDRESS,ORG_INN,ORG_KPP,
			INS_DATE,INS_NUM,INS_NUM_YEAR,
			CL_ID,CL_PSEDO,CL_FULL_NAME,CL_SHORT_NAME,CL_INN,CL_KPP,
			INS_CLIENT_ADDR,INS_CONSIG_NAME,INS_CONSIG_ADDR,INS_DOC_STRING,
			INS_STORNO,INS_COMMENT,INS_PREPAY,
			ORG_DIR_SHORT,ORG_BUH_SHORT, INT_PSEDO
		FROM 
			dbo.InvoiceFactMasterTable LEFT OUTER JOIN
			dbo.InvoiceTypeTable ON INT_ID = INS_ID_TYPE
		WHERE IFM_DATE = @d 
		ORDER BY INS_NUM

		SELECT 
			IFD_ID_IFM, 
			INR_GOOD, INR_NAME, SO_INV_UNIT,
			SUM(INR_SUM) AS INR_SUM,
			INR_TNDS,
			SUM(INR_SNDS) AS INR_SNDS, 
			SUM(INR_SALL) AS INR_SALL, INR_COUNT
		FROM 
			dbo.InvoiceFactDetailTable 
		WHERE INR_ID_INVOICE IN (
			SELECT INS_ID
				FROM 
					dbo.InvoiceFactMasterTable 	
				WHERE IFM_DATE = @d 
			)
		GROUP BY 
			IFD_ID_IFM,
			INR_GOOD, INR_NAME, INR_ID_DISTR, SO_INV_UNIT, INR_TNDS, INR_COUNT
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

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

CREATE PROCEDURE [dbo].[BILL_DELETE]
	@billid INT,
	@soid SMALLINT
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
		WHERE SL_ID_BILL_DIS IN 
				(
					SELECT BD_ID 
					FROM 
						dbo.BillDistrTable INNER JOIN
						dbo.DistrView WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR
					WHERE BD_ID_BILL = @billid
						AND SYS_ID_SO = @soid					
				)
		-- Текст процедуры ниже
		DELETE 
		FROM dbo.BillDistrTable
		WHERE BD_ID_BILL = @billid 
			AND BD_ID_DISTR IN
				(
					SELECT DIS_ID
					FROM dbo.DistrView WITH(NOEXPAND)
					WHERE SYS_ID_SO = @soid
				)

		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.BillDistrTable
				WHERE BD_ID_BILL = @billid
			)
			DELETE 
			FROM dbo.BillTable
			WHERE BL_ID = @billid
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

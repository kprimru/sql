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

ALTER PROCEDURE [dbo].[CONSIGNMENT_CREATE_ALL]
	@periodid SMALLINT,
	@consdate SMALLDATETIME,
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

		DECLARE CL CURSOR LOCAL FOR
			SELECT CL_ID
			FROM dbo.ClientTable
			WHERE EXISTS
				(
					SELECT *
					FROM 
						dbo.ClientDistrTable INNER JOIN
						dbo.DistrFinancingTable ON DF_ID_DISTR = CD_ID_DISTR INNER JOIN
						dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE INNER JOIN
						dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR INNER JOIN
						dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID
					WHERE CD_ID_CLIENT = CL_ID
						AND DSS_REPORT = 1
						AND SYS_ID_SO = @soid
						AND DOC_PSEDO = 'CONS'
						AND DD_PRINT = 1
				)

		DECLARE @clid INT

		OPEN CL

		FETCH NEXT FROM CL INTO @clid

		WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC dbo.CONSIGNMENT_CREATE @clid, @periodid, @consdate, @soid

				FETCH NEXT FROM CL INTO @clid
			END

		CLOSE CL
		DEALLOCATE CL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_CREATE_ALL] TO rl_consignment_w;
GO
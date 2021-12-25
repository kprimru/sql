USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[CONSIGNMENT_ALL_PRINT]
	@consdate SMALLDATETIME,
	@courid VARCHAR(MAX),
	@check BIT
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

		DECLARE @curdate DATETIME

		SET @curdate = GETDATE()

		IF OBJECT_ID('tempdb..#cour') IS NOT NULL
			DROP TABLE #cour

		CREATE TABLE #cour
			(
				COUR_ID SMALLINT
			)

		IF @courid IS NULL
			INSERT INTO #cour (COUR_ID)
				SELECT COUR_ID
				FROM dbo.CourierTable
		ELSE
			INSERT INTO #cour
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@courid, ',')

		DECLARE @conslist VARCHAR(MAX)
		SET @conslist = ''

		SELECT @conslist = @conslist + CONVERT(VARCHAR(10), CSG_ID) + ','
		FROM
			(
				SELECT DISTINCT CSG_ID
				FROM
					dbo.ConsignmentTable INNER JOIN
					dbo.ClientTable ON CSG_ID_CLIENT = CL_ID INNER JOIN
					dbo.TOTable ON TO_ID_CLIENT = CL_ID INNER JOIN
					#cour ON COUR_ID = TO_ID_COUR
				WHERE CSG_DATE = @consdate
					AND (CSG_PRINT IS NULL OR CSG_PRINT = 0)
			) AS o_O



		IF LEN(@conslist) > 2
			SET @conslist = LEFT(@conslist, LEN(@conslist) - 1)

		IF OBJECT_ID('tempdb..#cour') IS NOT NULL
			DROP TABLE #cour

		EXEC dbo.CONSIGNMENT_PRINT_BY_ID_LIST @conslist

		IF @check = 1
		BEGIN
			DECLARE @adate DATETIME
			SET @adate = GETDATE()

			UPDATE dbo.ConsignmentTable
			SET CSG_PRINT = 1,
				CSG_PRINT_DATE = @adate
			WHERE CSG_ID IN
				(
					SELECT *
					FROM dbo.GET_TABLE_FROM_LIST(@conslist, ',')
				)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_ALL_PRINT] TO rl_consignment_p;
GO

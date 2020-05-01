USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:		
*/

ALTER PROCEDURE [dbo].[DISTR_LOAD_FROM_REG]
	@count INT OUTPUT,
	@update INT OUTPUT
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

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CREATE TABLE #distr
			(
				SYS_ID SMALLINT, 
				RN_DISTR_NUM INT, 
				RN_COMP_NUM SMALLINT
			)

		INSERT INTO #distr
			SELECT SYS_ID, RN_DISTR_NUM, RN_COMP_NUM
			FROM 
				dbo.RegNodeTable INNER JOIN
				dbo.SystemTable ON SYS_REG_NAME = RN_SYS_NAME 
			WHERE
				NOT EXISTS
					(
						SELECT * 
						FROM dbo.DistrTable 
						WHERE DIS_ID_SYSTEM = SYS_ID 
							AND DIS_NUM = RN_DISTR_NUM
							AND DIS_COMP_NUM = RN_COMP_NUM
					)

		INSERT INTO dbo.DistrTable
			SELECT SYS_ID, RN_DISTR_NUM, RN_COMP_NUM, 1
			FROM #distr

		INSERT INTO dbo.DistrDocumentTable
						(
							DD_ID_DISTR, DD_ID_DOC, DD_PRINT, DD_ID_GOOD, DD_ID_UNIT
						)
			SELECT DIS_ID, DSD_ID_DOC, DSD_PRINT, DSD_ID_GOOD, DSD_ID_UNIT
			FROM 
				dbo.DocumentSaleObjectDefaultTable INNER JOIN
				dbo.SaleObjectTable ON DSD_ID_SO = SO_ID INNER JOIN
				dbo.SystemTable ON SYS_ID_SO = SO_ID CROSS JOIN
				dbo.DistrTable a INNER JOIN
				#distr b ON a.SYS_ID = b.SYS_ID 
						AND a.RN_DISTR_NUM = b.RN_DISTR_NUM 
						AND a.RN_COMP_NUM = b.RN_COMP_NUM		

		

		SELECT @count = @@ROWCOUNT

		--пометить неактивными дистрибутивы, которые были заменены

		UPDATE dbo.DistrTable
		SET DIS_ACTIVE = 0
		WHERE 
			NOT EXISTS
				(
					SELECT * 				
					FROM 
						dbo.RegNodeTable INNER JOIN
						dbo.SystemTable ON SYS_REG_NAME = RN_SYS_NAME
					WHERE RN_DISTR_NUM = DIS_NUM 
						AND RN_COMP_NUM = DIS_COMP_NUM 
						AND DIS_ID_SYSTEM = SYS_ID
				) AND
			EXISTS
				(
					SELECT * 				
					FROM 
						dbo.RegNodeTable INNER JOIN
						dbo.SystemTable a ON SYS_REG_NAME = RN_SYS_NAME
					WHERE RN_DISTR_NUM = DIS_NUM 
						AND RN_COMP_NUM = DIS_COMP_NUM 
						AND DIS_ID_SYSTEM IN 
								(
									SELECT b.SYS_ID 
									FROM dbo.SystemTable  b
									WHERE a.SYS_ID_HOST = b.SYS_ID_HOST	
										AND a.SYS_ID <> b.SYS_ID							
								)
				)

		SELECT @update = @@ROWCOUNT

		SELECT @count AS pcount, @update AS pupdate

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[DISTR_LOAD_FROM_REG] TO rl_distr_financing_w;
GO
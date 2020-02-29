USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_STAT_PROCESS]
	@NAME	VARCHAR(256),
	@SIZE	BIGINT,
	@MD5	VARCHAR(64),
	@DATA	VARBINARY(MAX),
	@DATE	DATETIME
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

		IF @DATE < DATEADD(MONTH, -7, GETDATE()) BEGIN
			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
			
			RETURN
		END
		
		DECLARE @NUM	VARCHAR(10)
		DECLARE @DISTR	VARCHAR(10)
		DECLARE @COMP	VARCHAR(10)
		DECLARE @OTHER	VARCHAR(50)
		
		DECLARE @TMP VARCHAR(256)
		SET @TMP = @NAME
		
		SET @NUM = LEFT(@TMP, CHARINDEX('_', @TMP) - 1)	
		SET @TMP = RIGHT(@TMP, LEN(@TMP) - LEN(@NUM) - 1)
		
		SET @DISTR = LEFT(@TMP, CHARINDEX('_', @TMP) - 1)	
		SET @TMP = RIGHT(@TMP, LEN(@TMP) - LEN(@DISTR) - 1)
		
		/* проверяем, есть ли № comp */
		IF CHARINDEX('_', @TMP) <= 3 AND CHARINDEX('_', @TMP) <> 0
		BEGIN
			SET @COMP = LEFT(@TMP, CHARINDEX('_', @TMP) - 1)	
			SET @TMP = RIGHT(@TMP, LEN(@TMP) - LEN(@COMP) - 1)
		END
		ELSE
		BEGIN
			SET @COMP = '1'
		END
		
		SET @OTHER = REPLACE(@TMP, '.STT', '')
		
		IF EXISTS
			(
				SELECT *
				FROM dbo.ClientStat
				WHERE 
					FL_NAME = @NAME
					AND FL_SIZE = @SIZE
					AND MD5 = @MD5
			)
		BEGIN
			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
			
			RETURN
		END
		
		INSERT INTO dbo.ClientStat(FL_NAME, FL_SIZE, MD5, FL_DATA, FL_DATE, SYS_NUM, DISTR, COMP, OTHER)
			SELECT @NAME, @SIZE, @MD5, @DATA, @DATE, CONVERT(INT, @NUM), CONVERT(INT, @DISTR), CONVERT(TINYINT, @COMP), @OTHER
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END